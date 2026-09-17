enum GitHubErrorType { notFound, rateLimited, network, unknown }

class GitHubException implements Exception {
  final GitHubErrorType type;
  final int? statusCode;
  final String message;

  const GitHubException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  factory GitHubException.fromStatus(int statusCode) {
    switch (statusCode) {
      case 404:
        return const GitHubException(
          type: GitHubErrorType.notFound,
          statusCode: 404,
          message: 'Not found',
        );
      case 403:
      case 429:
        return GitHubException(
          type: GitHubErrorType.rateLimited,
          statusCode: statusCode,
          message: 'GitHub API rate limit exceeded',
        );
      default:
        return GitHubException(
          type: GitHubErrorType.unknown,
          statusCode: statusCode,
          message: 'GitHub API error ($statusCode)',
        );
    }
  }

  @override
  String toString() => 'GitHubException($type, $statusCode): $message';
}
