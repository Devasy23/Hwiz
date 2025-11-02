/// Profile Model
/// Represents a person whose blood reports are being tracked
class Profile {
  final int? id;
  final String name;
  final String? dateOfBirth;
  final String? gender;
  final String? relationship;
  final String? photoPath;
  final DateTime createdAt;

  Profile({
    this.id,
    required this.name,
    this.dateOfBirth,
    this.gender,
    this.relationship,
    this.photoPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create Profile from database map
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as int?,
      name: map['name'] as String,
      dateOfBirth: map['date_of_birth'] as String?,
      gender: map['gender'] as String?,
      relationship: map['relationship'] as String?,
      photoPath: map['photo_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert Profile to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      // 'relationship': relationship, // Removed - column doesn't exist in existing databases
      'photo_path': photoPath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Profile copyWith({
    int? id,
    String? name,
    String? dateOfBirth,
    String? gender,
    String? relationship,
    String? photoPath,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      relationship: relationship ?? this.relationship,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Profile(id: $id, name: $name, dateOfBirth: $dateOfBirth)';
  }
}
