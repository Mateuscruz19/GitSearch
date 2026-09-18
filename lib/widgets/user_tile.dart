import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/github_user.dart';
import '../providers/favorites_provider.dart';

class UserTile extends StatelessWidget {
  final GitHubUser user;
  final VoidCallback onTap;

  const UserTile({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: 'Open profile of ${user.login}',
      excludeSemantics: true,
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      user.avatarUrl,
                      fit: BoxFit.cover,
                      semanticLabel: 'Avatar of ${user.login}',
                      errorBuilder: (_, _, _) => const _AvatarPlaceholder(),
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : const _AvatarPlaceholder(),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _FavoriteButton(user: user),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  user.login,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.person, size: 48),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final GitHubUser user;

  const _FavoriteButton({required this.user});

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoritesProvider, bool>(
      (favorites) => favorites.isFavorite(user),
    );

    return Semantics(
      label: isFavorite
          ? 'Remove ${user.login} from favorites'
          : 'Add ${user.login} to favorites',
      excludeSemantics: true,
      child: Material(
        color: Colors.black45,
        shape: const CircleBorder(),
        child: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.redAccent : Colors.white,
          ),
          onPressed: () => context.read<FavoritesProvider>().toggle(user),
        ),
      ),
    );
  }
}
