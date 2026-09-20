import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/github_user.dart';
import '../providers/search_provider.dart';
import '../providers/viewed_provider.dart';
import '../routes.dart';
import '../widgets/error_message.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/user_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _searched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      context.read<SearchProvider>().clearSearch();
      setState(() => _searched = false);
      return;
    }

    setState(() => _searched = true);
    final provider = context.read<SearchProvider>();
    await provider.searchUser(query);
    if (!mounted) return;

    // RF08: quando o termo corresponde a um login, vai direto para os detalhes.
    for (final user in provider.users) {
      if (user.login.toLowerCase() == query.toLowerCase()) {
        _openDetails(user);
        return;
      }
    }
  }

  void _openDetails(GitHubUser user) {
    context.read<ViewedProvider>().markViewed(user);
    Navigator.pushNamed(context, AppRoutes.details, arguments: user.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: const InputDecoration(
                labelText: 'Login do GitHub',
                hintText: 'Digite o login do GitHub...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.search),
                label: const Text('Buscar'),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Consumer<SearchProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const LoadingIndicator(label: 'Buscando usuários');
                  }

                  if (provider.errorMessage != null) {
                    return ErrorMessage(message: provider.errorMessage!);
                  }

                  if (provider.users.isEmpty) {
                    return Center(
                      child: Text(
                        _searched
                            ? 'Nenhum usuário encontrado.'
                            : 'Digite um login e toque em Buscar.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 180,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: provider.users.length,
                    itemBuilder: (context, index) {
                      final user = provider.users[index];
                      return UserTile(
                        user: user,
                        onTap: () => _openDetails(user),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
