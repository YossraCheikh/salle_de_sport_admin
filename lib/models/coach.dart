enum CoachType { gym, private }

class Coach {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String bio;
  final List<String> specialties;
  final bool isActive;
  final int activeSessionsCount;
  final CoachType type;

  Coach({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.bio,
    required this.specialties,
    this.isActive = true,
    this.activeSessionsCount = 0,
    this.type = CoachType.gym,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'C';
  }

  String get typeLabel => type == CoachType.private ? 'Coach Privé' : 'Coach Salle';

  factory Coach.fromMap(Map<String, dynamic> map, String docId) {
    return Coach(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      bio: map['bio'] ?? '',
      specialties: List<String>.from(map['specialties'] ?? []),
      isActive: map['isActive'] ?? true,
      activeSessionsCount: map['activeSessionsCount'] ?? 0,
      type: map['type'] == 'private' ? CoachType.private : CoachType.gym,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'bio': bio,
      'specialties': specialties,
      'isActive': isActive,
      'activeSessionsCount': activeSessionsCount,
      'type': type.name,
    };
  }
}
