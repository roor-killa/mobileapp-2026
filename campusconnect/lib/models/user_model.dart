class UserModel {
  final String id;
  final String nom;
  final String email;
  final String? photoUrl;
  final String? coverPhotoUrl;
  final String? bio;
  final String? filiere;
  final DateTime dateInscription;
  final int followersCount;
  final int followingCount;

  UserModel({
    required this.id,
    required this.nom,
    required this.email,
    this.photoUrl,
    this.coverPhotoUrl,
    this.bio,
    this.filiere,
    required this.dateInscription,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nom: json['nom'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      bio: json['bio'] as String?,
      filiere: json['filiere'] as String?,
      dateInscription: json['date_inscription'] != null
          ? DateTime.parse(json['date_inscription'] as String)
          : DateTime.now(),
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'nom': nom,
        'email': email,
        'photo_url': photoUrl,
        'cover_photo_url': coverPhotoUrl,
        'bio': bio,
        'filiere': filiere,
        'followers_count': followersCount,
        'following_count': followingCount,
      };

  UserModel copyWith({
    String? nom,
    String? photoUrl,
    String? coverPhotoUrl,
    String? bio,
    String? filiere,
    int? followersCount,
    int? followingCount,
  }) =>
      UserModel(
        id: id,
        nom: nom ?? this.nom,
        email: email,
        photoUrl: photoUrl ?? this.photoUrl,
        coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
        bio: bio ?? this.bio,
        filiere: filiere ?? this.filiere,
        dateInscription: dateInscription,
        followersCount: followersCount ?? this.followersCount,
        followingCount: followingCount ?? this.followingCount,
      );
}
