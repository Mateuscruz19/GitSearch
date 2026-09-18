import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/github_user.dart';
import '../providers/viewed_provider.dart';
import '../routes.dart';
import '../widgets/user_tile.dart';

class ViewedScreen extends StatelessWidget {
  const ViewedScreen({super.key});

  void _openDetails(BuildContext context, GitHubUser user) {
    context.read<ViewedProvider>().markViewed(user);
    Navigator.pushNamed(context, AppRoutes.details, arguments: user.login);
  }

  @override
  Widget build(BuildContext context) {
    final viewed = context.watch<ViewedProvider>().viewed;

    return Scaffold(
      appBar: AppBar(title: const Text('Viewed')),
      body: viewed.isEmpty
          ? const Center(child: Text('No viewed profiles yet'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: viewed.length,
              itemBuilder: (_, i) => UserTile(
                user: viewed[i],
                onTap: () => _openDetails(context, viewed[i]),
              ),
            ),
    );
  }
}
