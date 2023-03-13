import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showLoadingMessage(BuildContext context) {
  //iOS
  showCupertinoDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => const AlertDialog(
      title: Text('Espere por favor'),
      content: CupertinoActivityIndicator(),
    ),
  );
  return;
}
