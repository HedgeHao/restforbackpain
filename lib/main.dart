import 'dart:convert';
import 'dart:io';

import 'package:admin_template/dbTools.dart';
import 'package:admin_template/modelList.dart';
import 'package:flutter/material.dart';

import 'package:admin_template/global.dart' as Global;
import 'package:admin_template/ui.dart';
import 'package:admin_template/utils.dart';
import 'package:admin_template/model.dart';

Widget blankTab = BlankTab();
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: Scaffold(body: MyHome()));
  }
}

class MyHome extends StatefulWidget {
  MyHomeState createState() => MyHomeState();
}

class MyHomeState extends State<MyHome> {
  Future _future;
  Map<String, ModelListScreen> modelLists = Map<String, ModelListScreen>();
  Map<String, ModelScreen> modelScreens = Map<String, ModelScreen>();
  int tabIndex;
  List<String> routeMap = List<String>();

  // Future<String> loadConfigFile() async => await rootBundle.loadString('assets/data/config.json');
  Future<String> loadConfigFile() async {
    return File(getConfigFilePath()).readAsString();
  }

  @override
  void initState() {
    tabIndex = 0;
    _future = loadConfigFile();
    super.initState();
  }

  final List<String> availabelTabs = ['dashboard', 'users'];
  List<Widget> tabInstances = List<Widget>();
  Widget currentTab;

  void switchTab(String name, {Map<String, dynamic> data}) {
    setState(() {
      if (name.startsWith('m_')) {
        (tabInstances[routeMap.indexOf(name)] as ModelScreen).stateObj.update(data['id']);
      }
      this.tabIndex = routeMap.indexOf(name);
    });
  }

  void refreshConfigure() {
    tabInstances.removeRange(2, tabInstances.length);
    routeMap.removeRange(2, routeMap.length);
    setState(() {
      _future = null;
      _future = loadConfigFile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Text("Loading...");
        } else {
          List<Widget> sidePanelModels = List<Widget>();

          tabInstances.add(DashboardScreen());
          routeMap.add('dashboard');
          tabInstances.add(DBToolScreen());
          routeMap.add('dbtool');

          try {
            Global.configure = jsonDecode(snapshot.data);
            //print('Load Config File:' + Global.configure.toString());

            Map<String, dynamic> models = Global.configure['models'];
            for (String name in models.keys) {
              Map<String, dynamic> model = models[name];
              sidePanelModels.add(GestureDetector(
                  child: Text(
                    '   - ' + name,
                    style: TEXTSTYLE_SIDE,
                  ),
                  onTap: () {
                    switchTab('ml_' + name);
                  }));

              if (routeMap.indexOf('ml_' + name) < 0) {
                tabInstances.add(ModelListScreen(name, model['struct'], model['endpoints'], switchTab));
                routeMap.add('ml_' + name);
              }

              if (routeMap.indexOf('m_' + name) < 0) {
                tabInstances.add(ModelScreen(name, model['struct'], switchTab));
                routeMap.add('m_' + name);
              }
            }
          } catch (e) {
            print('Config file error:' + e.toString());
          }

          return Container(
              child: Row(
            children: <Widget>[
              Flexible(flex: 2, child: Container(color: Colors.blue, child: SidePanel(sidePanelModels, switchTab, refreshConfigure))),
              Flexible(
                  flex: 8,
                  child: IndexedStack(
                    index: this.tabIndex,
                    children: this.tabInstances,
                  )),
            ],
          ));
        }
      },
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("Dashboard");
  }
}

class SidePanel extends StatelessWidget {
  final List<Widget> models;
  final Function switchTab;
  final Function refresh;

  SidePanel(this.models, this.switchTab, this.refresh);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, cons) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              width: cons.maxWidth,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  fetchImageFromUrl(Global.getConfigure('icon').toString(), size: 50) ?? Icon(Icons.dashboard, size: 50),
                  Text(Global.getConfigure('title') ?? 'Restforbackpain', style: TESTSTYLE_TITLE)
                ],
              )),
          Divider(),
          Container(
            width: cons.maxWidth,
            height: cons.maxHeight - 50 * 2 - 40,
            child: Padding(
                padding: EdgeInsets.only(left: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Dashboard", style: TEXTSTYLE_SIDE),
                    Text("Models", style: TEXTSTYLE_SIDE),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: this.models,
                    ),
                  ],
                )),
          ),
          Divider(),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: cons.maxWidth,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        child: Icon(Icons.settings),
                        onPressed: () {
                          switchTab('dbtool');
                        },
                      ),
                      FlatButton(
                          child: Icon(Icons.refresh),
                          onPressed: () {
                            refresh();
                          })
                    ],
                  ))),
        ],
      );
    });
  }
}
