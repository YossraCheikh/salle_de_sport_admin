class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'admin' | 'coach' | 'member'
  final bool isActive;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? 'Administrateur',
      email: map['email'] ?? 'admin@gym.tn',
      role: map['role'] ?? 'admin',
      isActive: map['isActive'] ?? true,
    );
  }
}
