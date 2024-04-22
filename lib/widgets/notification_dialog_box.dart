import 'package:flutter/material.dart';

class NotificationDialogBox extends StatelessWidget {
  final String title;
  final String message;

  const NotificationDialogBox({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      ),
      child: Text("Show Dialog"),
    );
  }
}
