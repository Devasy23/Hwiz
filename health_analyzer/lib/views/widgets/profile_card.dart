import 'package:flutter/material.dart';
import '../../models/profile.dart';

/// A card widget to display profile information
class ProfileCard extends StatelessWidget {
  final Profile profile;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProfileCard({
    super.key,
    required this.profile,
    this.isSelected = false,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar
              Hero(
                tag: 'profile_avatar_${profile.id}',
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: _getAvatarColor(context),
                  backgroundImage: profile.photoPath != null
                      ? AssetImage(profile.photoPath!)
                      : null,
                  child: profile.photoPath == null
                      ? Text(
                          profile.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Profile info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (profile.gender != null) ...[
                          Icon(
                            profile.gender?.toLowerCase() == 'male'
                                ? Icons.male
                                : profile.gender?.toLowerCase() == 'female'
                                    ? Icons.female
                                    : Icons.person,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile.gender!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                          ),
                        ],
                        if (profile.dateOfBirth != null &&
                            profile.gender != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (profile.dateOfBirth != null)
                          Text(
                            _getAgeText(profile.dateOfBirth!),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action buttons
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(BuildContext context) {
    // Generate color based on name hash
    final hash = profile.name.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[hash.abs() % colors.length];
  }

  String _getAgeText(String dateOfBirth) {
    try {
      final dob = DateTime.parse(dateOfBirth);
      final today = DateTime.now();
      int age = today.year - dob.year;

      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }

      if (age < 2) {
        final months = (today.year - dob.year) * 12 + today.month - dob.month;
        return '$months ${months == 1 ? 'month' : 'months'}';
      }

      return '$age years';
    } catch (e) {
      return dateOfBirth;
    }
  }
}
