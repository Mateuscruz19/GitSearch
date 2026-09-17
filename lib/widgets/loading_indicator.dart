import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String label;

  const LoadingIndicator({super.key, this.label = 'Loading'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: label,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
