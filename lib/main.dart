import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:admin_template/ui.dart';
import 'package:admin_template/model.dart';
import 'package:flutter/services.dart';

Map<String, dynamic> configure;

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

  Future<String> loadString() async => await rootBundle.loadString('assets/data/config.json');

  @override
  void initState() {
    _future = loadString();
    tabInstances['dashboard'] = DashboardScreen();
    super.initState();
  }

  final List<String> availabelTabs = ['dashboard', 'users'];
  Map<String, Widget> tabInstances = {};
  Widget currentTab;

  void switchTab(String name) {
    if (!tabInstances.containsKey(name)) {
      tabInstances[name] = ModelScreen(name, configure['models'][name]['struct'], {'username': 'Test'});
    }

    setState(() {
      currentTab = tabInstances[name];
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
          if (currentTab == null) {
            currentTab = tabInstances["dashboard"];
          }
          if (configure == null) {
            configure = jsonDecode(snapshot.data);
            print('Load Config File:' + configure.toString());
          }
          List<Widget> sidePanelModels = List<Widget>();
          Map<String, dynamic> models = configure['models'];
          for (String model in models.keys) {
            sidePanelModels.add(GestureDetector(
                child: Text("   - " + model, style: TEXTSTYLE_SIDE),
                onTap: () {
                  switchTab(model);
                }));
          }

          return Container(
              child: Row(
            children: <Widget>[
              Flexible(flex: 1, child: Container(color: Colors.blue, child: SidePanel(sidePanelModels))),
              Flexible(flex: 5, child: currentTab),
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

class SidePanel extends StatefulWidget {
  final List<Widget> models;

  SidePanel(this.models);

  SidePanelState createState() => SidePanelState();
}

class SidePanelState extends State<SidePanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flexible(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Icon(Icons.ac_unit), Text("MY ADMIN")],
          ),
        ),
        Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Dashboard", style: TEXTSTYLE_SIDE),
                Text("Models", style: TEXTSTYLE_SIDE),
                Column(
                  children: widget.models,
                ),
              ],
            )),
      ],
    );
  }
}
