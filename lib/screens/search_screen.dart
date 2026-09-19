import 'dart:async';

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
  //inserçao do timer -> debounce para nao chamar a api a cada letra digitada, mas sim 500ms depois da ultima letra digitada
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        context.read<SearchProvider>().searchUser(query);
      } else {
        context.read<SearchProvider>().clearSearch();
      }
    });
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
            SearchBar(
              hintText: 'Digite o login do GitHub...',
              leading: const Icon(Icons.search),
              onChanged: _onSearchChanged,
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
                    return const Center(
                      child: Text('Nenhum usuário encontrado.'),
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
