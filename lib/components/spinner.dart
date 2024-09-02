import 'package:flutter/material.dart';

void showLoadingSpinner(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );
}

void hideLoadingSpinner(BuildContext context) {
  Navigator.pop(context);
}
