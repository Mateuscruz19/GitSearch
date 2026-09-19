import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/github_user.dart';
import '../providers/following_provider.dart';
import '../providers/viewed_provider.dart';
import '../routes.dart';
import '../widgets/user_tile.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key});

  void _openDetails(BuildContext context, GitHubUser user) {
    context.read<ViewedProvider>().markViewed(user);
    Navigator.pushNamed(context, AppRoutes.details, arguments: user.login);
  }

  @override
  Widget build(BuildContext context) {
    final following = context.watch<FollowingProvider>().following;

    return Scaffold(
      appBar: AppBar(title: const Text('Following')),
      body: following.isEmpty
          ? const Center(child: Text('Not following anyone yet'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: following.length,
              itemBuilder: (_, i) => UserTile(
                user: following[i],
                onTap: () => _openDetails(context, following[i]),
              ),
            ),
    );
  }
}
