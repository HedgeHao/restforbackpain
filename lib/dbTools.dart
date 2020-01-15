import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mysql1/mysql1.dart' as MySQL;
import 'package:postgres/postgres.dart' as Psql;

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
    configJson = "";
    future_structure = null;
    dropdownValue = "mysql";
    super.initState();

    controller_host.text = 'http://127.0.0.1';
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
                items: <DropdownMenuItem<String>>[DropdownMenuItem(child: Text("MySQL"), value: 'mysql'), DropdownMenuItem(child: Text("PostgreSQL"), value: 'psql')],
                onChanged: (String item) {
                  switch (item) {
                    case 'mysql':
                      controller_port.text = "3306";
                      break;
                    case 'psql':
                      controller_port.text = "5432";
                      break;
                  }
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
                          dbUtility = MySQLUtility(connection, title: controller_dbname.text);
                          setState(() {
                            future_structure = null;
                            future_structure = dbUtility.getStructure();
                          });
                        });
                        break;
                      case 'psql':
                        Psql.PostgreSQLConnection connection = Psql.PostgreSQLConnection(controller_host.text, int.parse(controller_port.text), controller_dbname.text,
                            username: controller_user.text, password: controller_password.text);
                        if (!connection.isClosed) {
                          connection.close();
                        }
                        connection.open().then((error) {
                          print(error);
                          dbUtility = PsqlUtility(connection, title: controller_dbname.text);
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
              print('Future Error:' + snapshot.error.toString());
              return Text('Error');
            } else if (snapshot.hasData) {
              configJson = jsonEncode(snapshot.data);
              return Padding(
                  padding: EdgeInsets.only(left: 20), child: Align(alignment: Alignment.topLeft, child: Container(height: 450, child: SingleChildScrollView(child: JsonText(configJson, tabs: 4)))));
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
                }),
            FlatButton(
                child: Text('Load'),
                onPressed: () {
                  setState(() {
                    configJson = File(getConfigFilePath()).readAsStringSync();
                  });
                  answerDialog(context, '', 'File Loaded', null, options: ['OK']);
                }),
          ],
        ),
        // Row(
        //   children: <Widget>[
        //     Container(
        //         width: 300,
        //         child: TextField(
        //           controller: controller_sql,
        //         )),
        //     FlatButton(
        //         child: Text('Test'),
        //         onPressed: () {
        //           dbUtility.getStructure();
        //         }),
        //   ],
        // )
      ],
    );
  }
}

abstract class DatabaseUtility {
  final Map<String, List<String>> defaultEndpointActions = {
    'create': ['POST', '0'],
    'read': ['GET', '\$id'],
    'update': ['PUT', '\$id'],
    'delete': ['DELETE', '\$id'],
    'readAll': ['GET', ''],
  };
  final String defaultHost = "http://127.0.0.1:8080";
  final String defaultIcon = "icon://59505";

  Future<String> query(String sql) async {}
  Future<Map<String, dynamic>> getStructure() async {}
}

class PsqlUtility extends DatabaseUtility {
  Psql.PostgreSQLConnection connection;
  String title;

  PsqlUtility(this.connection, {title});

  @override
  Future<String> query(String sql) async {
    Psql.PostgreSQLResult result = await connection.query(sql);
    return result.toString();
  }

  @override
  Future<Map<String, dynamic>> getStructure() async {
    Map<String, dynamic> configure = Map<String, dynamic>();
    configure['title'] = this.title;
    configure['host'] = this.defaultHost;
    configure['icon'] = this.defaultIcon;
    Map<String, dynamic> models = Map<String, dynamic>();

    List<String> tables = List<String>();
    List<List<dynamic>> result = await this.connection.query("SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';");
    for (List<dynamic> table in result) {
      tables.add(table[0].toString());
    }

    for (String s in tables) {
      Map<String, dynamic> model = Map<String, dynamic>();
      model['endpoints'] = {};
      model['endpoints']['name'] = s;
      model['endpoints']['actions'] = this.defaultEndpointActions;

      List<Map<String, dynamic>> structs = List<Map<String, dynamic>>();

      result = await this.connection.query("select column_name, data_type, column_default,is_nullable from information_schema.columns where table_name='$s'");
      for (List<dynamic> r in result) {
        Map<String, dynamic> struct = Map<String, dynamic>();
        struct['name'] = r[0].toString();
        switch (r[1]) {
          case 'text':
            struct['type'] = 'string';
            break;
          case 'smallint':
          case 'bigint':
            struct['type'] = 'interger';
            break;
          case 'real':
            struct['type'] = 'float';
            break;
          default:
            if (r[1].toString().startsWith('character')) {
              struct['type'] = 'string';
            } else if (r[1].toString().startsWith('time')) {
              struct['type'] = 'time';
            } else {
              struct['type'] = r[1].toString();
            }
        }
        struct['default'] = r[2].toString();
        struct['null'] = r[3] == 'YES';
        structs.add(struct);
      }

      model['struct'] = structs;
      models[s] = model;
    }

    configure['models'] = models;
    return configure;
  }
}

class MySQLUtility extends DatabaseUtility {
  MySQL.MySqlConnection connection;
  String title;

  MySQLUtility(this.connection, {this.title});

  @override
  Future<String> query(String sql) async {
    MySQL.Results result = await this.connection.query(sql);
    result.toString();
    return result.toString();
  }

  @override
  Future<Map<String, dynamic>> getStructure() async {
    Map<String, dynamic> configure = Map<String, dynamic>();
    configure['title'] = this.title;
    configure['host'] = this.defaultHost;
    configure['icon'] = this.defaultIcon;
    Map<String, dynamic> models = Map<String, dynamic>();

    List<String> tables = List<String>();
    MySQL.Results result = await this.connection.query('show tables;');

    result.forEach((MySQL.Row r) {
      tables.add(r.first);
    });

    for (String s in tables) {
      Map<String, dynamic> model = Map<String, dynamic>();
      model['endpoints'] = {};
      model['endpoints']['name'] = s;
      model['endpoints']['actions'] = this.defaultEndpointActions;
      List<Map<String, dynamic>> structs = List<Map<String, dynamic>>();

      result = await this.connection.query('desc ' + s + ';');
      result.forEach((MySQL.Row r) {
        Map<String, dynamic> struct = Map<String, dynamic>();
        Map<String, dynamic> field = r.fields;
        struct['name'] = field['Field'].toString();
        String type = field['Type'].toString();
        if (type.startsWith('int') || type.startsWith('tinyint')) {
          struct['type'] = 'integer';
        } else if (type.startsWith('varchar') || type.startsWith('char')) {
          struct['type'] = 'string';
        } else if (type.startsWith('varchar')) {
          struct['type'] = 'string';
        } else {
          struct['type'] = field['Type'].toString();
        }
        struct['default'] = field['Default'].toString();
        struct['null'] = field['Null'] == 'YES';
        structs.add(struct);
      });

      model['struct'] = structs;
      models[s] = model;
    }

    configure['models'] = models;
    return configure;
  }
}
