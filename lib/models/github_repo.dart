class GitHubRepo {
  final int id;
  final String name;
  final String fullName;
  final String htmlUrl;
  final String? description;
  final String? language;
  final int stargazersCount;
  final int forksCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? pushedAt;

  const GitHubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.htmlUrl,
    this.description,
    this.language,
    this.stargazersCount = 0,
    this.forksCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.pushedAt,
  });

  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    return GitHubRepo(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      htmlUrl: json['html_url'] as String,
      description: json['description'] as String?,
      language: json['language'] as String?,
      stargazersCount: json['stargazers_count'] as int? ?? 0,
      forksCount: json['forks_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      pushedAt: json['pushed_at'] == null
          ? null
          : DateTime.parse(json['pushed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'html_url': htmlUrl,
      'description': description,
      'language': language,
      'stargazers_count': stargazersCount,
      'forks_count': forksCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pushed_at': pushedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) => other is GitHubRepo && other.id == id;

  @override
  int get hashCode => id.hashCode;
}