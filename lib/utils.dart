import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:admin_template/global.dart' as Global;

String upperFirst(String s) {
  return s[0].toUpperCase() + s.substring(1);
}

Widget fetchImageFromUrl(String url, {double size, Color color}) {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return Image.network(url);
  } else if (url.startsWith('icon://')) {
    return Icon(IconData(int.parse(url.substring(7)), fontFamily: 'MaterialIcons'), size: size, color: color);
  } else {
    return Container(width: 0, height: 0);
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
