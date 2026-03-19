class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    this.email,
    this.birthDate,
    this.photoPath,
  });

  final String id;
  final String displayName;
  final String? email;
  final DateTime? birthDate;
  final String? photoPath;
}
