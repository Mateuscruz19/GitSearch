import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gitsearch/services/github_exception.dart';
import 'package:gitsearch/services/github_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  GitHubService serviceWith(int status, Object body) {
    return GitHubService(
      client: MockClient(
        (_) async => http.Response(jsonEncode(body), status),
      ),
    );
  }

  group('getUser', () {
    test('parses a user', () async {
      final service = serviceWith(200, {
        'id': 1,
        'login': 'octocat',
        'avatar_url': 'https://a',
        'html_url': 'https://h',
        'name': null,
        'followers': 10,
      });
      final user = await service.getUser('octocat');
      expect(user.login, 'octocat');
      expect(user.displayName, 'octocat');
      expect(user.followers, 10);
    });

    test('throws notFound on 404', () async {
      final service = serviceWith(404, {'message': 'Not Found'});
      expect(
        () => service.getUser('nobody'),
        throwsA(
          isA<GitHubException>()
              .having((e) => e.type, 'type', GitHubErrorType.notFound),
        ),
      );
    });

    test('throws rateLimited on 403', () async {
      final service = serviceWith(403, {'message': 'rate limit'});
      expect(
        () => service.getUser('octocat'),
        throwsA(
          isA<GitHubException>()
              .having((e) => e.type, 'type', GitHubErrorType.rateLimited),
        ),
      );
    });
  });

  group('getPopularUsers', () {
    test('computes hasMore from total_count', () async {
      final service = serviceWith(200, {
        'total_count': 45,
        'items': List.generate(
          30,
          (i) => {
            'id': i,
            'login': 'u$i',
            'avatar_url': 'https://a',
            'html_url': 'https://h',
          },
        ),
      });
      final page1 = await service.getPopularUsers(page: 1);
      expect(page1.items.length, 30);
      expect(page1.hasMore, isTrue);
      final page2 = await service.getPopularUsers(page: 2);
      expect(page2.hasMore, isFalse);
    });
  });

  group('getUserRepos', () {
    test('hasMore is false when page is short', () async {
      final service = serviceWith(200, [
        {
          'id': 1,
          'name': 'r',
          'full_name': 'o/r',
          'html_url': 'https://h',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-02T00:00:00Z',
          'pushed_at': null,
        },
      ]);
      final result = await service.getUserRepos('o');
      expect(result.items.single.name, 'r');
      expect(result.items.single.pushedAt, isNull);
      expect(result.hasMore, isFalse);
    });
  });
}
