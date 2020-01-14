import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mysql1/mysql1.dart' as MySQL;

import 'package:admin_template/utils.dart';
import 'package:admin_template/jsonText.dart';

class DBToolScreen extends StatefulWidget {
  DBToolScreenState createState() => DBToolScreenState();
}

class DBToolScreenState extends State<DBToolScreen> {
  TextEditingController controller_host = TextEditingController();
  TextEditingController controller_user = TextEditingController();
  TextEditingController controller_password = TextEditingController();
  TextEditingController controller_port = TextEditingController();
  TextEditingController controller_dbname = TextEditingController();
  TextEditingController controller_sql = TextEditingController();
  String dropdownValue;

  Future<Map<String, dynamic>> future_structure;

  DatabaseUtility dbUtility;

  String configJson;

  @override
  void initState() {
    future_structure = null;
    dropdownValue = "mysql";
    super.initState();

    controller_host.text = '127.0.0.1';
    controller_port.text = '3306';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Align(alignment: Alignment.centerLeft, child: Text("Setting", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold))),
        Row(children: <Widget>[
          Flexible(flex: 1, child: Padding(padding: EdgeInsets.only(right: 10, left: 10), child: Text("Host:"))),
          Flexible(flex: 1, child: Padding(padding: EdgeInsets.only(right: 10), child: TextField(controller: controller_host))),
          Flexible(flex: 1, child: Padding(padding: EdgeInsets.only(right: 10, left: 10), child: Text("Port:"))),
          Flexible(flex: 1, child: Padding(padding: EdgeInsets.only(right: 10), child: TextField(controller: controller_port))),
          Flexible(flex: 1, child: Padding(padding: EdgeInsets.only(right: 10, left: 10), child: Text("Database Name:"))),
          Flexible(flex: 1, child: Padding(padding: EdgeInsets.only(right: 10), child: TextField(controller: controller_dbname))),
          Flexible(
              flex: 1,
              child: DropdownButton(
                value: dropdownValue,
                items: <DropdownMenuItem<String>>[DropdownMenuItem(child: Text("MySQL"), value: 'mysql'), DropdownMenuItem(child: Text("PostgreSQL"), value: 'postgresql')],
                onChanged: (String item) {
                  print(item);
                  setState(() {
                    dropdownValue = item;
                  });
                },
              )),
        ]),
        Row(
          children: <Widget>[
            Flexible(flex: 1, child: Padding(padding: EdgeInsets.only(right: 10, left: 10), child: Text("User:"))),
            Flexible(flex: 3, child: Padding(padding: EdgeInsets.only(right: 10), child: TextField(controller: controller_user))),
            Flexible(flex: 1, child: Padding(padding: EdgeInsets.only(right: 10), child: Text("Password:"))),
            Flexible(
                flex: 3,
                child: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: TextField(
                      controller: controller_password,
                      keyboardType: TextInputType.visiblePassword,
                    ))),
            Flexible(
                flex: 1,
                child: FlatButton(
                  child: Text("Connect"),
                  onPressed: () {
                    switch (dropdownValue) {
                      case 'mysql':
                        MySQL.MySqlConnection.connect(MySQL.ConnectionSettings(
                                host: controller_host.text, port: int.parse(controller_port.text), user: controller_user.text, password: controller_password.text, db: controller_dbname.text))
                            .then((connection) {
                          dbUtility = MySQLUtility(connection);
                          setState(() {
                            future_structure = null;
                            future_structure = dbUtility.getStructure();
                          });
                        });
                        break;
                    }
                  },
                )),
          ],
        ),
        FutureBuilder(
          future: future_structure,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && !snapshot.hasData) {
              return Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error');
            } else if (snapshot.hasData) {
              String json = jsonEncode(snapshot.data);
              return Padding(padding:EdgeInsets.only(left:20),child:Align(alignment: Alignment.topLeft, child: Container(height: 450, child: SingleChildScrollView(child: JsonText(json, tabs:4)))));
            } else {
              return Container();
            }
          },
        ),
        Row(
          children: <Widget>[
            FlatButton(
                child: Text('Copy'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: configJson));
                }),
            FlatButton(
                child: Text('Save'),
                onPressed: () {
                  File(getConfigFilePath()).writeAsStringSync(configJson);
                  answerDialog(context, '', 'File saved', null, options: ['OK']);
                  print('File wrote');
                }),
            FlatButton(
                child: Text('Load'),
                onPressed: () {
                  setState(() {
                    configJson = File(getConfigFilePath()).readAsStringSync();
                  });
                  answerDialog(context, '', 'File Loaded', null, options: ['OK']);
                  print('File loaded');
                }),
          ],
        ),
      ],
    );
  }
}

abstract class DatabaseUtility {
  Future<String> query(String sql) async {}
  Future<Map<String, dynamic>> getStructure() async {}
}

class MySQLUtility extends DatabaseUtility {
  MySQL.MySqlConnection connection;

  MySQLUtility(this.connection);

  @override
  Future<String> query(String sql) async {
    MySQL.Results result = await this.connection.query(sql);
    print('+Query');
    print(result);
    result.toString();
    return result.toString();
  }

  @override
  Future<Map<String, dynamic>> getStructure() async {
    Map<String, dynamic> configure = Map<String, dynamic>();
    configure['title'] = '';
    configure['host'] = '';
    configure['icon'] = '';
    Map<String, dynamic> models = Map<String, dynamic>();

    List<String> tables = List<String>();
    MySQL.Results result = await this.connection.query('show tables;');

    result.forEach((MySQL.Row r) {
      tables.add(r.first);
    });

    for (String s in tables) {
      Map<String, dynamic> model = Map<String, dynamic>();
      model['endpoints'] = {};
      List<Map<String, dynamic>> structs = List<Map<String, dynamic>>();

      result = await this.connection.query('desc ' + s + ';');
      result.forEach((MySQL.Row r) {
        Map<String, dynamic> struct = Map<String, dynamic>();
        Map<String, dynamic> field = r.fields;
        struct['name'] = field['Field'].toString();
        struct['type'] = field['Type'].toString();
        struct['default'] = field['Default'].toString();
        struct['null'] = field['Null'] == 'YES';
        structs.add(struct);
      });

      model['struct'] = structs;
      models[s] = model;
    }

    configure['models'] = models;
    print('-GetStructure');
    return configure;
  }
}
