import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final String login;

  const DetailsScreen({super.key, required this.login});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(login)),
      body: Center(child: Text('Details of $login')),
    );
  }
}
