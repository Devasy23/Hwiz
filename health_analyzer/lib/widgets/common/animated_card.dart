import 'package:flutter/material.dart';

/// A card widget with built-in press and hover animations
/// Provides subtle scale feedback when tapped and elevation changes on hover
/// Enhanced with Material 3 design principles
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool enableHoverEffect;
  final Duration animationDuration;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.elevation,
    this.color,
    this.borderRadius,
    this.padding,
    this.margin,
    this.enableHoverEffect = true,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // Scale animation for press feedback
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Elevation animation for hover effect
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 0,
      end: (widget.elevation ?? 0) + 4,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!mounted) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!mounted) return;
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (!mounted) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onHoverEnter(PointerEvent event) {
    if (!widget.enableHoverEffect || !mounted) return;
    setState(() => _isHovering = true);
    if (!_isPressed) {
      _controller.forward();
    }
  }

  void _onHoverExit(PointerEvent event) {
    if (!widget.enableHoverEffect || !mounted) return;
    setState(() => _isHovering = false);
    if (!_isPressed) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);

    return MouseRegion(
      onEnter: widget.enableHoverEffect ? _onHoverEnter : null,
      onExit: widget.enableHoverEffect ? _onHoverExit : null,
      cursor:
          widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTapDown: widget.onTap != null ? _onTapDown : null,
        onTapUp: widget.onTap != null ? _onTapUp : null,
        onTapCancel: widget.onTap != null ? _onTapCancel : null,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Card(
                elevation:
                    widget.enableHoverEffect && (_isHovering || _isPressed)
                        ? _elevationAnimation.value
                        : widget.elevation,
                color: widget.color,
                margin: widget.margin,
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius,
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: widget.padding != null
                    ? Padding(
                        padding: widget.padding!,
                        child: widget.child,
                      )
                    : widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}
