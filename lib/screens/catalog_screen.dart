import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/github_user.dart';
import '../providers/auth_provider.dart';
import '../providers/viewed_provider.dart';
import '../routes.dart';
import '../services/github_exception.dart';
import '../services/github_service.dart';
import '../widgets/error_message.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/user_tile.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final List<GitHubUser> _users = [];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await context.read<GitHubService>().getPopularUsers(
        page: _page,
      );
      if (!mounted) return;
      setState(() {
        _users.addAll(result.items);
        _page = result.nextPage;
        _hasMore = result.hasMore;
      });
    } on GitHubException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openDetails(GitHubUser user) {
    context.read<ViewedProvider>().markViewed(user);
    Navigator.pushNamed(context, AppRoutes.details, arguments: user.login);
  }

  void _openSearch() {
    Navigator.pushNamed(context, AppRoutes.search);
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final username = context.select<AuthProvider, String?>((auth) {
      return auth.username;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitSearch'),
        actions: [
          if (username != null) _UserBadge(username: username),
          IconButton(
            tooltip: 'Sair',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              hintText: 'Search users',
              leading: const Icon(Icons.search),
              onTap: _openSearch,
              readOnly: true,
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_users.isEmpty && _loading) {
      return const LoadingIndicator(label: 'Loading catalog');
    }
    if (_users.isEmpty && _error != null) {
      return ErrorMessage(message: _error!, onRetry: _loadPage);
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => UserTile(
                user: _users[i],
                onTap: () => _openDetails(_users[i]),
              ),
              childCount: _users.length,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildFooter()),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          if (_loading)
            const LoadingIndicator(label: 'Loading more users')
          else if (_hasMore)
            ElevatedButton.icon(
              onPressed: _loadPage,
              icon: const Icon(Icons.expand_more),
              label: const Text('Load more'),
            )
          else
            Text(
              'No more users',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}

class _UserBadge extends StatelessWidget {
  final String username;

  const _UserBadge({required this.username});

  @override
  Widget build(BuildContext context) {
    final displayName = '${username[0].toUpperCase()}${username.substring(1)}';
    final compact = MediaQuery.sizeOf(context).width < 500;

    return Semantics(
      label: 'Usuário conectado: $displayName',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: compact ? 105 : 150),
          child: Chip(
            avatar: CircleAvatar(child: Text(displayName[0])),
            label: Text(
              compact ? displayName : 'Olá, $displayName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
