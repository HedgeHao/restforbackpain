import 'package:flutter/material.dart';

class JsonText extends Text {
  JsonText(String data, {int tabs: 1}) : super(formatJson(data, tabs));
}

String formatJson(String s, int numTab) {
  int depth = 0;
  bool inQuote = false;
  bool escape = false;
  StringBuffer buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (s[i] == '}' || s[i] == ']' && !inQuote && !escape) {
      buf.write('\n');
      depth--;
      buf.write('\t' * numTab * depth);
    }

    buf.write(s[i]);

    if (s[i] == '{' || s[i] == '[' && !inQuote && !escape) {
      buf.write('\n');
      depth++;
      buf.write('\t' * numTab * depth);
    } else if (s[i] == '"' && !escape && !inQuote) {
      inQuote = true;
    } else if (s[i] == '"' && !escape && inQuote) {
      inQuote = false;
    } else if (s[i] == ',' && !inQuote) {
      buf.write('\n');
      buf.write('\t' * numTab * depth);
    }
  }
  return buf.toString();
}
