import 'package:flutter/material.dart';

import '../models/github_user.dart';

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
                child: Image.network(
                  user.avatarUrl,
                  fit: BoxFit.cover,
                  semanticLabel: 'Avatar of ${user.login}',
                  errorBuilder: (_, _, _) => const _AvatarPlaceholder(),
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : const _AvatarPlaceholder(),
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
