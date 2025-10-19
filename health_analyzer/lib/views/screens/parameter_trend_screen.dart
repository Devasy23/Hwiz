import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../services/database_helper.dart';

/// Screen to display parameter trends over time
class ParameterTrendScreen extends StatefulWidget {
  final int profileId;
  final String profileName;
  final String? initialParameter;

  const ParameterTrendScreen({
    super.key,
    required this.profileId,
    required this.profileName,
    this.initialParameter,
  });

  @override
  State<ParameterTrendScreen> createState() => _ParameterTrendScreenState();
}

class _ParameterTrendScreenState extends State<ParameterTrendScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  List<String> _availableParameters = [];
  String? _selectedParameter;
  List<Map<String, dynamic>> _trendData = [];
  bool _isLoading = true;
  bool _showReferenceRange = true;
  String _selectedTimeRange = 'all'; // all, 1year, 6months, 3months

  @override
  void initState() {
    super.initState();
    _selectedParameter = widget.initialParameter;
    _loadAvailableParameters();
  }

  Future<void> _loadAvailableParameters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final parameters = await _databaseHelper.getAvailableParameters(
        widget.profileId,
      );

      setState(() {
        _availableParameters = parameters;
        if (_selectedParameter == null && parameters.isNotEmpty) {
          _selectedParameter = parameters.first;
        }
        _isLoading = false;
      });

      if (_selectedParameter != null) {
        await _loadTrendData();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading parameters: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadTrendData() async {
    if (_selectedParameter == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _databaseHelper.getParameterTrend(
        profileId: widget.profileId,
        parameterName: _selectedParameter!,
      );

      // Filter by time range
      final filteredData = _filterByTimeRange(data);

      setState(() {
        _trendData = filteredData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trend data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _filterByTimeRange(
      List<Map<String, dynamic>> data) {
    if (_selectedTimeRange == 'all') return data;

    final now = DateTime.now();
    DateTime cutoffDate;

    switch (_selectedTimeRange) {
      case '1year':
        cutoffDate = now.subtract(const Duration(days: 365));
        break;
      case '6months':
        cutoffDate = now.subtract(const Duration(days: 180));
        break;
      case '3months':
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      default:
        return data;
    }

    return data.where((item) {
      final date = DateTime.parse(item['test_date'] as String);
      return date.isAfter(cutoffDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.profileName}\'s Trends'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showReferenceRange ? Icons.grid_on : Icons.grid_off),
            onPressed: () {
              setState(() {
                _showReferenceRange = !_showReferenceRange;
              });
            },
            tooltip: 'Toggle Reference Range',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _availableParameters.isEmpty
              ? _buildNoDataView()
              : _buildContent(),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 100,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Data Available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Scan at least 2 reports to view trends',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Parameter selector
        _buildParameterSelector(),

        // Time range selector
        _buildTimeRangeSelector(),

        // Chart
        Expanded(
          child: _trendData.isEmpty ? _buildNoTrendDataView() : _buildChart(),
        ),

        // Statistics summary
        if (_trendData.isNotEmpty) _buildStatisticsSummary(),
      ],
    );
  }

  Widget _buildParameterSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButtonFormField<String>(
            value: _selectedParameter,
            decoration: const InputDecoration(
              labelText: 'Select Parameter',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.analytics),
            ),
            items: _availableParameters.map((param) {
              return DropdownMenuItem(
                value: param,
                child: Text(_formatParameterName(param)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedParameter = value;
              });
              _loadTrendData();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeRangeChip('3M', '3months'),
              _buildTimeRangeChip('6M', '6months'),
              _buildTimeRangeChip('1Y', '1year'),
              _buildTimeRangeChip('All', 'all'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeChip(String label, String value) {
    final isSelected = _selectedTimeRange == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTimeRange = value;
          _loadTrendData();
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildNoTrendDataView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 80,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Trend Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'This parameter needs at least 2 data points\nfrom different reports',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_trendData.length < 2) {
      return _buildNoTrendDataView();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatParameterName(_selectedParameter!),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_trendData.length} data points',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _buildLineChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    // Prepare data points
    final spots = <FlSpot>[];
    final dates = <DateTime>[];

    for (int i = 0; i < _trendData.length; i++) {
      final value = (_trendData[i]['parameter_value'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), value));
      dates.add(DateTime.parse(_trendData[i]['test_date'] as String));
    }

    // Get reference ranges
    final refMin = _trendData.first['reference_range_min'] as num?;
    final refMax = _trendData.first['reference_range_max'] as num?;

    // Calculate chart boundaries
    final values = spots.map((e) => e.y).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    double chartMinY = minValue;
    double chartMaxY = maxValue;

    if (refMin != null && refMax != null) {
      chartMinY = (minValue < refMin.toDouble())
          ? minValue * 0.9
          : refMin.toDouble() * 0.9;
      chartMaxY = (maxValue > refMax.toDouble())
          ? maxValue * 1.1
          : refMax.toDouble() * 1.1;
    } else {
      chartMinY = minValue * 0.9;
      chartMaxY = maxValue * 1.1;
    }

    // Ensure there's always a minimum range to prevent zero interval
    if (chartMaxY - chartMinY < 0.1) {
      final midPoint = (chartMaxY + chartMinY) / 2;
      chartMinY = midPoint - 0.5;
      chartMaxY = midPoint + 0.5;
    }

    return LineChart(
      LineChartData(
        minY: chartMinY,
        maxY: chartMaxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval:
              ((chartMaxY - chartMinY) / 5).clamp(0.1, double.infinity),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dates.length) {
                  return const Text('');
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MMM\ndd').format(dates[index]),
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                // Check if value is abnormal
                bool isAbnormal = false;
                if (refMin != null && refMax != null) {
                  isAbnormal = spot.y < refMin || spot.y > refMax;
                }

                return FlDotCirclePainter(
                  radius: 6,
                  color: isAbnormal ? Colors.red : Colors.white,
                  strokeWidth: 2,
                  strokeColor: isAbnormal
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
        extraLinesData: _showReferenceRange && refMin != null && refMax != null
            ? ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: refMin.toDouble(),
                    color: Colors.orange.withOpacity(0.5),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                      ),
                      labelResolver: (line) => 'Min: ${refMin.toString()}',
                    ),
                  ),
                  HorizontalLine(
                    y: refMax.toDouble(),
                    color: Colors.orange.withOpacity(0.5),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.bottomRight,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                      ),
                      labelResolver: (line) => 'Max: ${refMax.toString()}',
                    ),
                  ),
                ],
              )
            : null,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final date = dates[index];
                final value = spot.y;
                final unit = _trendData[index]['unit'] ?? '';

                return LineTooltipItem(
                  '${DateFormat('MMM dd, yyyy').format(date)}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '${value.toStringAsFixed(2)} $unit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSummary() {
    if (_trendData.isEmpty) return const SizedBox.shrink();

    final values = _trendData
        .map((e) => (e['parameter_value'] as num).toDouble())
        .toList();

    final latest = values.last;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final avg = values.reduce((a, b) => a + b) / values.length;

    final unit = _trendData.first['unit'] ?? '';

    // Calculate trend (comparing latest to first)
    final first = values.first;
    final trendPercent = ((latest - first) / first * 100);
    final isTrendUp = trendPercent > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Latest', latest, unit, Colors.blue),
                  _buildStatItem('Average', avg, unit, Colors.green),
                  _buildStatItem('Min', min, unit, Colors.orange),
                  _buildStatItem('Max', max, unit, Colors.red),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isTrendUp
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isTrendUp ? Icons.trending_up : Icons.trending_down,
                      color: isTrendUp ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Trend: ${trendPercent.abs().toStringAsFixed(1)}% ${isTrendUp ? 'increase' : 'decrease'}',
                      style: TextStyle(
                        color: isTrendUp ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, double value, String unit, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(1),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatParameterName(String name) {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
