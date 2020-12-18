import 'package:flutter/material.dart';

class DialogLoading {
  static hide(BuildContext context) => Navigator.pop(context);

  static show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          child: Card(
            elevation: 0,
            margin: EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 10.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 15.0,
                ),
                CircularProgressIndicator(),
                SizedBox(
                  width: 15.0,
                ),
                Text(
                  'Loading',
                  style: TextStyle(fontSize: 15),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
