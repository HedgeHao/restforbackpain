import 'package:admin_template/global.dart' as Global;
import 'package:admin_template/ui.dart';
import 'package:admin_template/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ModelScreen extends StatefulWidget {
  final String name;
  final List<dynamic> struct;
  final Function switchModelList;

  ModelScreen(this.name, this.struct, this.switchModelList);

  ModelScreenState stateObj;

  ModelScreenState createState() {
    stateObj = ModelScreenState();
    return stateObj;
  }
}

class ModelScreenState extends State<ModelScreen> {
  Map<String, dynamic> data;

  @override
  void initState() {
    data = {};
    super.initState();
  }

  void update(int id) {
    String endpointParsed = Global.configure['models'][widget.name]['endpoints']['actions']['read'][1].toString().replaceAll('\$id', id.toString());
    String url = Global.configure['host'] + '/' + Global.configure['models'][widget.name]['endpoints']['name'] + '/' + endpointParsed;
    http.get(url).then((http.Response resp) {
      Map<String, dynamic> respObj = json.decode(resp.body);
      if (respObj['code'] == 200) {
        setState(() {
          this.data = respObj['data'];
        });
      }
    });
  }

  Widget ModelField(Map<String, dynamic> field) {
    switch (field['type']) {
      case 'string':
        return StringField(upperFirst(field['name']), data[field['name']], editable: field['editable'] == null);
      case 'boolean':
        return BooleanField(upperFirst(field['name']), data[field['name']] == true, editable: field['editable'] == null);
      case 'integer':
        return IntegerField(upperFirst(field['name']), data[field['name']], editable: field['editable'] == null);
      case 'float':
        return FloatField(upperFirst(field['name']), data[field['name']], editable: field['editable'] == null);
      case 'date':
        return DateField(upperFirst(field['name']), data[field['name']], editable: field['editable'] == null);
      case 'datetime':
        return DateTimeField(upperFirst(field['name']), data[field['name']], editable: field['editable'] == null);
      case 'html':
        return HtmlField(upperFirst(field['name']), data[field['name']], editable: field['editable'] == null);
      default:
        return Text('Error:' + field.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(10.0),
        child: Column(children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                  child: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    widget.switchModelList('ml_' + widget.name);
                  }),
              Align(alignment: Alignment.centerLeft, child: Text(upperFirst(widget.name), style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold))),
            ],
          ),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(
            children: <Widget>[for (Map<String, dynamic> field in widget.struct) ModelField(field)],
          )))
        ]));
  }
}

class HtmlField extends StatefulWidget {
  final String title, value;
  final bool editable;

  HtmlField(this.title, this.value, {this.editable: true});

  HtmlFieldState createState() => HtmlFieldState(this.value);
}

class HtmlFieldState extends State<HtmlField> {
  String currentValue;
  TextEditingController controller = TextEditingController();

  HtmlFieldState(value) {
    controller.text = value;
    this.currentValue = value;
  }

  @override
  Widget build(BuildContext context) {
    if (controller.text == "") {
      controller.text = widget.value;
    }

    if (this.currentValue == null || this.currentValue == "") {
      this.currentValue = "</br>";
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
                flex: 15,
                child: Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(widget.title + ':'),
                    ))),
            Flexible(
                flex: 85,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    border: Border.all(
                      color: Colors.grey[400],
                    ),
                  ),
                  child: SingleChildScrollView(
                      child: Html(
                    data: this.currentValue,
                  )),
                )),
          ],
        ),
        Row(
          children: <Widget>[
            Spacer(flex: 15),
            Flexible(
                flex: 85,
                child: TextField(
                  enabled: widget.editable,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: controller,
                  onChanged: (value) {
                    setState(() {
                      this.currentValue = value;
                    });
                  },
                )),
          ],
        )
      ],
    );
  }
}

class DateTimeField extends StatefulWidget {
  final String title, value;
  final bool editable;

  DateTimeField(this.title, this.value, {this.editable: true});

  DateTimeFieldState createState() => DateTimeFieldState(this.value);
}

class DateTimeFieldState extends State<DateTimeField> {
  DateTime currentValue;

  DateTimeFieldState(String val) {
    if (val == null) {
      currentValue = null;
    } else if (val.contains('T')) {
      currentValue = DateTime.parse(val);
    } else {
      try {
        currentValue = DateTime.fromMillisecondsSinceEpoch(int.parse(val) * 1000);
      } catch (e) {
        print('Datetime parse error:' + e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 5, right: 5, bottom: MODEL_COLUMN_SPACE),
        child: Row(
          children: <Widget>[
            Flexible(
                flex: 15,
                child: Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(widget.title + ':'),
                    ))),
            Flexible(
                flex: 85,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: LayoutBuilder(builder: (ctx, cons) {
                    return Row(
                      children: <Widget>[
                        Text('  ' + (this.currentValue == null ? '' : DateFormat('yyyy-MM-dd - kk:mm:ss').format(this.currentValue)) + '  '),
                        ScaledButton(cons.maxWidth * 0.06, Icon(Icons.calendar_today, size: cons.maxWidth * 0.02), () {
                          DatePicker.showDateTimePicker(context, locale: LocaleType.zh, showTitleActions: true, currentTime: DateTime.now(), onConfirm: (dateTime) {
                            setState(() {
                              this.currentValue = dateTime;
                            });
                          });
                        }, editable: widget.editable),
                      ],
                    );
                  }),
                )),
          ],
        ));
  }
}

class DateField extends StatefulWidget {
  final String title, value;
  final bool editable;

  DateField(this.title, this.value, {this.editable: true});

  DateFieldState createState() => DateFieldState(this.value);
}

class DateFieldState extends State<DateField> {
  String currentValue;

  DateFieldState(value) {
    if (value == '') {
      this.currentValue = ' ';
    } else {
      this.currentValue = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 5, right: 5, bottom: MODEL_COLUMN_SPACE),
        child: Row(
          children: <Widget>[
            Flexible(
                flex: 15,
                child: Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(widget.title + ':'),
                    ))),
            Flexible(
                flex: 85,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: LayoutBuilder(builder: (ctx, cons) {
                    return Row(
                      children: <Widget>[
                        Text('  ' + this.currentValue.toString() + '  '),
                        ScaledButton(cons.maxWidth * 0.03, Icon(Icons.calendar_today, size: cons.maxWidth * 0.02), () {
                          DatePicker.showDatePicker(context, locale: LocaleType.zh, showTitleActions: true, currentTime: DateTime.now(), onConfirm: (date) {
                            setState(() {
                              this.currentValue = date.year.toString() + '/' + date.month.toString() + '/' + date.day.toString();
                            });
                          });
                        }, editable: widget.editable),
                      ],
                    );
                  }),
                )),
          ],
        ));
  }
}

class FloatField extends StatefulWidget {
  final String title;
  final double value;
  final bool editable;

  FloatField(this.title, this.value, {this.editable: true});

  FloatFieldState createState() => FloatFieldState(this.value);
}

class FloatFieldState extends State<FloatField> {
  double currentValue;
  TextEditingController controller = TextEditingController();

  FloatFieldState(this.currentValue);

  @override
  Widget build(BuildContext context) {
    if (widget.value == null) {
      controller.text = '(null)';
    } else {
      controller.text = widget.value.toStringAsFixed(10);
    }

    return Padding(
        padding: EdgeInsets.only(left: 5, right: 5, bottom: MODEL_COLUMN_SPACE),
        child: Row(
          children: <Widget>[
            Flexible(
                flex: 15,
                child: Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(widget.title + ':'),
                    ))),
            Flexible(
                flex: 85,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: LayoutBuilder(
                    builder: (ctx, cons) {
                      return Row(
                        children: <Widget>[
                          ScaledButton(cons.maxWidth * 0.03, Icon(Icons.remove), () {
                            this.currentValue -= 0.1;
                            controller.text = this.currentValue.toStringAsFixed(10);
                          }, editable: widget.editable),
                          Container(
                              width: 250,
                              child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: TextField(
                                    enabled: widget.editable,
                                    controller: controller,
                                    textAlign: TextAlign.center,
                                    onEditingComplete: () {
                                      if (controller.text == "") this.currentValue = 0.0;
                                      try {
                                        double.parse(controller.text);
                                        this.currentValue = double.parse(controller.text);
                                      } catch (e) {
                                        print("Failed");
                                        controller.text = this.currentValue.toStringAsFixed(10);
                                      }
                                    },
                                  ))),
                          ScaledButton(cons.maxWidth * 0.03, Icon(Icons.add), () {
                            this.currentValue += 0.1;
                            controller.text = this.currentValue.toStringAsFixed(10);
                          }, editable: widget.editable),
                        ],
                      );
                    },
                  ),
                )),
          ],
        ));
  }
}

class IntegerField extends StatefulWidget {
  final String title;
  final int value;
  final bool editable;

  IntegerField(this.title, this.value, {this.editable: true});

  IntegerFieldState createState() => IntegerFieldState(this.value);
}

class IntegerFieldState extends State<IntegerField> {
  int currentValue;
  TextEditingController controller = TextEditingController();

  IntegerFieldState(this.currentValue);

  @override
  Widget build(BuildContext context) {
    controller.text = this.currentValue == null ? '' : this.currentValue.toString();
    return Padding(
        padding: EdgeInsets.only(left: 5, right: 5, bottom: MODEL_COLUMN_SPACE),
        child: Row(
          children: <Widget>[
            Flexible(
                flex: 15,
                child: Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(widget.title + ':'),
                    ))),
            Flexible(
                flex: 85,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: LayoutBuilder(
                    builder: (ctx, cons) {
                      return Row(
                        children: <Widget>[
                          ScaledButton(cons.maxWidth * 0.03, Icon(Icons.remove), () {
                            if (this.currentValue != null) {
                              setState(() {
                                this.currentValue -= 1;
                              });
                            }
                          }, editable: widget.editable),
                          Container(
                              width: 120,
                              child: TextField(
                                enabled: widget.editable,
                                controller: controller,
                                textAlign: TextAlign.center,
                                onEditingComplete: () {
                                  if (controller.text == "") this.currentValue = 0;
                                  try {
                                    double.parse(controller.text);
                                    this.currentValue = int.parse(controller.text);
                                  } catch (e) {
                                    print("Failed");
                                    controller.text = this.currentValue.round().toString();
                                  }
                                },
                              )),
                          ScaledButton(cons.maxWidth * 0.03, Icon(Icons.add), () {
                            if (this.currentValue != null) {
                              setState(() {
                                this.currentValue += 1;
                              });
                            }
                          }, editable: widget.editable),
                        ],
                      );
                    },
                  ),
                )),
          ],
        ));
  }
}

class BooleanField extends StatefulWidget {
  final String title;
  final bool initValue, editable;

  BooleanField(this.title, this.initValue, {this.editable});

  BooleanFieldState createState() => BooleanFieldState(this.initValue);
}

class BooleanFieldState extends State<BooleanField> {
  bool checkValue;

  BooleanFieldState(this.checkValue);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 5, right: 5, bottom: MODEL_COLUMN_SPACE),
        child: Row(
          children: <Widget>[
            Flexible(
                flex: 15,
                child: Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(widget.title + ':'),
                    ))),
            Flexible(
                flex: 85,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Checkbox(
                      value: this.checkValue,
                      onChanged: (newValue) {
                        if (widget.editable) {
                          setState(() {
                            this.checkValue = newValue;
                          });
                        }
                      },
                    ))),
          ],
        ));
  }
}

class StringField extends StatelessWidget {
  final String title, value;
  final bool editable;

  StringField(this.title, this.value, {this.editable: true});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    controller.text = this.value;
    return Padding(
        padding: EdgeInsets.only(left: 5, right: 5, bottom: MODEL_COLUMN_SPACE),
        child: Row(
          children: <Widget>[
            Flexible(
                flex: 15,
                child: Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(this.title + ':'),
                    ))),
            Flexible(
                flex: 85,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      enabled: this.editable,
                      controller: controller,
                    ))),
          ],
        ));
  }
}
