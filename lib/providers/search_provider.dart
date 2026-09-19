import 'package:flutter/material.dart';

import '../models/github_user.dart';
import '../services/github_service.dart';
import '../services/github_exception.dart';

class SearchProvider extends ChangeNotifier {
  final GitHubService _apiService;
  SearchProvider(this._apiService);

  List<GitHubUser> _users = [];
  List<GitHubUser> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> searchUser(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.searchUsers(query);
      _users = result.items;
    } on GitHubException catch (e) {
      _errorMessage = switch (e.type) {
        GitHubErrorType.notFound => 'Nenhum usuário encontrado.',
        GitHubErrorType.rateLimited =>
          'Muitas buscas seguidas. Espere um minuto.',
        GitHubErrorType.network => 'Sem conexão com a internet.',
        GitHubErrorType.unknown => 'Não foi possível buscar agora.',
      };
      _users = [];
    } catch (e) {
      _errorMessage = 'Não foi possível buscar agora.';
      _users = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _users = [];
    _errorMessage = null;
    notifyListeners();
  }
}
