import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 250),
        Icon(Icons.search_off),
        const SizedBox(height: 15),
        Text(message),
      ],
    ));
  }
}
