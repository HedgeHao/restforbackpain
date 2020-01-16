import 'package:admin_template/global.dart' as Global;

import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:path/path.dart' as path;

String upperFirst(String s) {
  return s[0].toUpperCase() + s.substring(1);
}

Widget fetchImageFromUrl(String url, {double size, Color color}) {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return Image.network(url);
  } else if (url.startsWith('icon://')) {
    return Icon(IconData(int.parse(url.substring(7)), fontFamily: 'MaterialIcons'), size: size, color: color);
  } else {
    return null;
  }
}

String getFetchUrl(String model, String action) {
  Map<String, dynamic> endpoints = Global.configure['models'][model]['endpoints'];

  if (endpoints.containsKey(action)) {
    return endpoints[action];
  } else {
    switch (action) {
      case 'queryAll':
        return path.join(Global.configure['host'], model);
      default:
        return "";
    }
  }
}

String getConfigFilePath() {
  print(Platform.environment['HOME']);
  return Platform.environment['HOME'] + '/.config.json';
}

void answerDialog(BuildContext context, String title, String msg, Function callback, {List<String> options}) {
  if (options == null) {
    options = ['Close'];
  }

  List<Widget> actions = [];
  for (final s in options) {
    actions.add(FlatButton(
      child: Text(s),
      onPressed: () {
        Navigator.of(context).pop();
        if (callback != null) callback(s);
      },
    ));
  }

  showDialog(
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: actions,
        );
      },
      context: context);
}
