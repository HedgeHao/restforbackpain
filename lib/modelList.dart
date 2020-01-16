import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:admin_template/utils.dart';
import 'package:admin_template/global.dart' as Global;

class ModelListScreen extends StatefulWidget {
  final String name;
  final List<dynamic> struct;
  final Map<String, dynamic> endpoints;
  final Function switchModel;

  ModelListScreen(this.name, this.struct, this.endpoints, this.switchModel);

  ModelListScreenState createState() => ModelListScreenState();
}

class ModelListScreenState extends State<ModelListScreen> {
  Future<List<Map<String, dynamic>>> modelData;
  List<Widget> headers = List<Widget>();
  List<String> fields = List<String>();

  @override
  void initState() {
    modelData = null;
    super.initState();
  }

  void dataRowClicked(Map<String, dynamic> pData) {
    widget.switchModel('m_' + widget.name, data:pData);
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    String url = Global.configure['host'] + '/' + Global.configure['models'][widget.name]['endpoints']['name'] + '/' + Global.configure['models'][widget.name]['endpoints']['actions']['readAll'][1];
    http.Response resp = await http.get(url);
    Map<String, dynamic> respObj = json.decode(resp.body);
    List<Map<String, dynamic>> data = List<Map<String, dynamic>>();
    if (respObj['code'] == 200) {
      for (dynamic t in respObj['data']) {
        data.add(t as Map<String, dynamic>);
      }
      return data;
    } else {
      return null;
    }
  }

  List<Widget> buildHeader(BoxConstraints cons) {
    if (headers.length != 0) {
      return this.headers;
    } else {
      int fieldNum = (cons.maxWidth * 0.8 / 100).floor();
      int count = 0;
      for (Map<String, dynamic> field in widget.struct) {
        count += 1;
        fields.add(field['name'].toString());
        if (count > fieldNum) break;
      }

      for (String field in fields) {
        headers.add(Padding(padding: EdgeInsets.only(left: 3, right: 3), child: Container(color: Colors.blue, width: 100, height: 30, child: Text(upperFirst(field), textAlign: TextAlign.center))));
      }
    }

    return headers;
  }

  List<Widget> buildContent(BoxConstraints cons, List<Map<String, dynamic>> data) {
    List<Widget> contents = List<Widget>();

    bool canPress;
    for (Map<String, dynamic> d in data) {
      canPress = true;
      List<Widget> dataRow = List<Widget>();
      for (String field in fields) {
        if (canPress) {
          dataRow.add(Padding(
              padding: EdgeInsets.only(left: 3, right: 3),
              child: Container(
                  color: Colors.yellow,
                  width: 100,
                  height: 30,
                  child: GestureDetector(
                      child: Text(d[field].toString() ?? ""),
                      onTap: () {
                        dataRowClicked(d);
                      }))));
        } else {
          dataRow.add(Padding(padding: EdgeInsets.only(left: 3, right: 3), child: Container(color: Colors.yellow, width: 100, height: 30, child: Text(d[field].toString() ?? ""))));
        }
      }
      contents.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: dataRow));
      contents.add(Padding(padding: EdgeInsets.only(left: 3, right: 3), child: Divider()));
    }

    return contents;
  }

  @override
  Widget build(BuildContext context) {
    modelData = fetchData();
    return LayoutBuilder(builder: (ctx, cons) {
      return Column(
        children: <Widget>[
          Align(alignment: Alignment.centerLeft, child: Text(upperFirst(widget.name), style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold))),
          Divider(
            thickness: 5,
          ),
          Padding(
              padding: EdgeInsets.only(top: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buildHeader(cons),
              )),
          Padding(padding: EdgeInsets.only(left: 30, right: 30), child: Divider(thickness: 3)),
          FutureBuilder(
            future: modelData,
            builder: (ctx, snapshot) {
              if (!snapshot.hasData) {
                return Text('Loading');
              } else if (snapshot.hasError) {
                print('Error:' + snapshot.error.toString());
                return Text('Error');
              } else if (snapshot.hasData) {
                return Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(left: 40, right: 40),
                        child: SingleChildScrollView(
                            child: Column(
                          children: buildContent(cons, snapshot.data),
                        ))));
              }
            },
          )
        ],
      );
    });
  }
}
