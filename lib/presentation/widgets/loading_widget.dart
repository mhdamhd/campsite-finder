import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  const LoadingWidget({super.key, this.message = "loading"});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 250),
        Text(message),
        const SizedBox(height: 8),
        const CircularProgressIndicator(),
      ],
    ));
  }
}
