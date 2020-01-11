import 'package:flutter/material.dart';

import 'package:admin_template/ui.dart';
import 'package:admin_template/model.dart';

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
  final List<String> availabelTabs = ['dashboard', 'users'];
  Map<String, Widget> tabInstances = {};
  Widget currentTab;

  void switchTab(String name) {
    if (availabelTabs.contains(name)) {
      setState(() {
        currentTab = getTabContent(name);
      });
    }
  }

  Widget getTabContent(String name, {init: true, data: null}) {
    if (availabelTabs.contains(name)) {
      if (tabInstances.containsKey(name)) {
        return tabInstances[name];
      } else {
        if (init) {
          Widget w;
          switch (name) {
            case 'dashboard':
              w = DashboardScreen();
              break;
            case 'users':
              w = ModelScreen('Users');
              break;
          }
          return w;
        } else {
          return null;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentTab == null) {
      currentTab = getTabContent('users');
    }
    return Container(
        child: Row(
          children: <Widget>[
            Flexible(flex: 1, child: Container(color: Colors.blue, child: SidePanel(switchTab))),
            Flexible(flex: 5, child: currentTab),
          ],
        ));
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("Dashboard");
  }
}

class SidePanel extends StatefulWidget {
  final Function tabClicked;

  SidePanel(this.tabClicked);

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
                  children: <Widget>[
                    GestureDetector(
                        child: Text("   - Users", style: TEXTSTYLE_SIDE),
                        onTap: () {
                          widget.tabClicked('users');
                        }),
                  ],
                ),
              ],
            )),
      ],
    );
  }
}
