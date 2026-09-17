class GitHubUser {
  final int id;
  final String login;
  final String avatarUrl;
  final String htmlUrl;
  final String? name;
  final String? bio;
  final String? location;
  final int followers;
  final int following;
  final int publicRepos;

  const GitHubUser({
    required this.id,
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
    this.name,
    this.bio,
    this.location,
    this.followers = 0,
    this.following = 0,
    this.publicRepos = 0,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      id: json['id'] as int,
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
      htmlUrl: json['html_url'] as String,
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      publicRepos: json['public_repos'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
      'name': name,
      'bio': bio,
      'location': location,
      'followers': followers,
      'following': following,
      'public_repos': publicRepos,
    };
  }

  String get displayName => name ?? login;

  @override
  bool operator ==(Object other) => other is GitHubUser && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
