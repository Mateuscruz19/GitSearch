import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/github_repo.dart';
import '../models/github_user.dart';
import '../models/paginated_result.dart';
import 'github_exception.dart';

class GitHubService {
  static const String baseUrl = 'https://api.github.com';
  static const int defaultPerPage = 30;
  static const String _token = String.fromEnvironment('GITHUB_TOKEN');

  final http.Client _client;

  GitHubService({http.Client? client}) : _client = client ?? http.Client();

  Future<GitHubUser> getUser(String login) async {
    final json = await _getJson('/users/$login');
    return GitHubUser.fromJson(json as Map<String, dynamic>);
  }

  Future<PaginatedResult<GitHubRepo>> getUserRepos(
    String login, {
    int page = 1,
    int perPage = defaultPerPage,
  }) async {
    final json = await _getJson(
      '/users/$login/repos',
      query: {'page': '$page', 'per_page': '$perPage', 'sort': 'updated'},
    );
    final items = _parseList(json, GitHubRepo.fromJson);
    return PaginatedResult(
      items: items,
      page: page,
      hasMore: items.length == perPage,
    );
  }

  Future<PaginatedResult<GitHubUser>> getPopularUsers({
    int page = 1,
    int perPage = defaultPerPage,
    int minFollowers = 10000,
  }) async {
    final json = await _getJson(
      '/search/users',
      query: {
        'q': 'followers:>$minFollowers',
        'sort': 'followers',
        'order': 'desc',
        'page': '$page',
        'per_page': '$perPage',
      },
    ) as Map<String, dynamic>;
    final items = _parseList(json['items'], GitHubUser.fromJson);
    final totalCount = json['total_count'] as int;
    return PaginatedResult(
      items: items,
      page: page,
      hasMore: page * perPage < totalCount,
      totalCount: totalCount,
    );
  }

  Future<PaginatedResult<GitHubUser>> searchUsers(
    String term, {
    int page = 1,
    int perPage = defaultPerPage,
  }) async {
    final json = await _getJson(
      '/search/users',
      query: {'q': term, 'page': '$page', 'per_page': '$perPage'},
    ) as Map<String, dynamic>;

    final items = _parseList(json['items'], GitHubUser.fromJson);
    final totalCount = json['total_count'] as int;

    return PaginatedResult(
      items: items,
      page: page,
      hasMore: page * perPage < totalCount,
      totalCount: totalCount,
    );
  }

  List<T> _parseList<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return (json as List<dynamic>)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<dynamic> _getJson(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final http.Response response;
    try {
      response = await _client.get(uri, headers: _headers);
    } on http.ClientException catch (e) {
      throw GitHubException(type: GitHubErrorType.network, message: e.message);
    }
    if (response.statusCode != 200) {
      throw GitHubException.fromStatus(response.statusCode);
    }
    return jsonDecode(response.body);
  }

  Map<String, String> get _headers => {
    'Accept': 'application/vnd.github+json',
    if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
  };

  void dispose() => _client.close();
}
