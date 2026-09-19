import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/github_repo.dart';
import '../models/github_user.dart';
import '../providers/favorites_provider.dart';
import '../providers/following_provider.dart';
import '../services/github_exception.dart';
import '../services/github_service.dart';
import '../widgets/error_message.dart';
import '../widgets/loading_indicator.dart';

class DetailsScreen extends StatefulWidget {
  final String login;

  const DetailsScreen({super.key, required this.login});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  GitHubUser? _user;
  String? _userError;
  bool _loadingUser = false;

  final List<GitHubRepo> _repos = [];
  int _reposPage = 1;
  bool _hasMoreRepos = true;
  bool _loadingRepos = false;
  String? _reposError;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _loadingUser = true;
      _userError = null;
    });

    try {
      final user = await context.read<GitHubService>().getUser(widget.login);
      if (!mounted) return;
      setState(() => _user = user);
    } on GitHubException catch (e) {
      if (mounted) setState(() => _userError = e.message);
    } finally {
      if (mounted) setState(() => _loadingUser = false);
    }

    if (mounted && _user != null) _loadRepos();
  }

  Future<void> _loadRepos() async {
    if (_loadingRepos || !_hasMoreRepos) return;
    setState(() {
      _loadingRepos = true;
      _reposError = null;
    });

    try {
      final result = await context.read<GitHubService>().getUserRepos(
        widget.login,
        page: _reposPage,
      );
      if (!mounted) return;
      setState(() {
        _repos.addAll(result.items);
        _reposPage = result.nextPage;
        _hasMoreRepos = result.hasMore;
      });
    } on GitHubException catch (e) {
      if (mounted) setState(() => _reposError = e.message);
    } finally {
      if (mounted) setState(() => _loadingRepos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.login)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final user = _user;

    if (user == null && _loadingUser) {
      return const LoadingIndicator(label: 'Loading profile');
    }
    if (user == null) {
      return ErrorMessage(
        message: _userError ?? 'Profile not available',
        onRetry: _loadUser,
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _ProfileHeader(user: user)),
        SliverList.builder(
          itemCount: _repos.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _RepoTile(repo: _repos[i]),
          ),
        ),
        SliverToBoxAdapter(child: _buildReposFooter()),
      ],
    );
  }

  Widget _buildReposFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Builder(
        builder: (context) {
          if (_reposError != null) {
            return Column(
              children: [
                Text(
                  _reposError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _loadRepos,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            );
          }

          if (_loadingRepos || (_repos.isEmpty && _hasMoreRepos)) {
            return const LoadingIndicator(label: 'Loading repositories');
          }

          if (_hasMoreRepos) {
            return ElevatedButton.icon(
              onPressed: _loadRepos,
              icon: const Icon(Icons.expand_more),
              label: const Text('Load more'),
            );
          }

          return Text(
            _repos.isEmpty ? 'No public repositories' : 'No more repositories',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final GitHubUser user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Image.network(
                  user.avatarUrl,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  semanticLabel: 'Avatar of ${user.login}',
                  errorBuilder: (_, _, _) => const _AvatarPlaceholder(),
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : const _AvatarPlaceholder(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        user.displayName,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '@${user.login}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (user.location != null) ...[
                      const SizedBox(height: 4),
                      _IconLine(
                        icon: Icons.place_outlined,
                        text: user.location!,
                        semanticLabel: 'Location',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (user.bio != null) ...[
            const SizedBox(height: 16),
            Text(user.bio!, style: theme.textTheme.bodyLarge),
          ],
          const SizedBox(height: 16),
          _StatsRow(user: user),
          const SizedBox(height: 16),
          _ActionButtons(user: user),
          const SizedBox(height: 12),
          _IconLine(
            icon: Icons.link,
            text: user.htmlUrl,
            semanticLabel: 'Profile address',
            selectable: true,
          ),
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text(
              'Public repositories',
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final GitHubUser user;

  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat(label: 'Followers', value: user.followers),
        _Stat(label: 'Following', value: user.following),
        _Stat(label: 'Repositories', value: user.publicRepos),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;

  const _Stat({required this.label, required this.value});

  static String _format(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Semantics(
        label: '$value $label',
        excludeSemantics: true,
        child: Column(
          children: [
            Text(_format(value), style: theme.textTheme.titleMedium),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final GitHubUser user;

  const _ActionButtons({required this.user});

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoritesProvider, bool>(
      (favorites) => favorites.isFavorite(user),
    );
    final isFollowing = context.select<FollowingProvider, bool>(
      (following) => following.isFollowing(user),
    );

    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () => context.read<FavoritesProvider>().toggle(user),
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            label: Text(isFavorite ? 'Favorited' : 'Favorite'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.read<FollowingProvider>().toggle(user),
            icon: Icon(
              isFollowing ? Icons.person_remove_outlined : Icons.person_add_alt,
            ),
            label: Text(isFollowing ? 'Unfollow' : 'Follow'),
          ),
        ),
      ],
    );
  }
}

class _RepoTile extends StatelessWidget {
  final GitHubRepo repo;

  const _RepoTile({required this.repo});

  static String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(repo.name, style: theme.textTheme.titleSmall),
            if (repo.description != null) ...[
              const SizedBox(height: 4),
              Text(
                repo.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                if (repo.language != null)
                  _IconLine(
                    icon: Icons.code,
                    text: repo.language!,
                    semanticLabel: 'Language',
                  ),
                _IconLine(
                  icon: Icons.star_border,
                  text: '${repo.stargazersCount}',
                  semanticLabel: 'Stars',
                ),
                _IconLine(
                  icon: Icons.call_split,
                  text: '${repo.forksCount}',
                  semanticLabel: 'Forks',
                ),
                _IconLine(
                  icon: Icons.history,
                  text: _formatDate(repo.updatedAt),
                  semanticLabel: 'Last update',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final String semanticLabel;
  final bool selectable;

  const _IconLine({
    required this.icon,
    required this.text,
    required this.semanticLabel,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Semantics(
      label: '$semanticLabel: $text',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: selectable
                ? SelectableText(text, style: style)
                : Text(text, overflow: TextOverflow.ellipsis, style: style),
          ),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.person, size: 40),
    );
  }
}
