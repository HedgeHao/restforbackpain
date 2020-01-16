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
  Map<String, dynamic> originData;

  void updateValue(String name, dynamic value) {
    data[name] = value;
  }

  dynamic getValue(String name) {
    return data[name];
  }

  @override
  void initState() {
    data = {};
    super.initState();
  }

  void saveChange(BuildContext ctx) {
    String endpointParsed = Global.configure['models'][widget.name]['endpoints']['actions']['update'][1].toString().replaceAll('\$id', this.data['id'].toString());
    String url = Global.configure['host'] + '/' + Global.configure['models'][widget.name]['endpoints']['name'] + '/' + endpointParsed;

    Map<String, dynamic> body = {};
    for (String index in this.originData.keys) {
      if (originData[index] != this.data[index]) {
        body[index] = this.data[index];
      }
    }

    print(body);

    http.put(url, body: jsonEncode(body)).then((http.Response resp) {
      Map<String, dynamic> respObj = json.decode(resp.body);
      if (respObj['code'] == 200) {
        answerDialog(ctx, "Message", "Save success", null);
      }
    });
  }

  void update(int id) {
    String endpointParsed = Global.configure['models'][widget.name]['endpoints']['actions']['read'][1].toString().replaceAll('\$id', id.toString());
    String url = Global.configure['host'] + '/' + Global.configure['models'][widget.name]['endpoints']['name'] + '/' + endpointParsed;
    http.get(url).then((http.Response resp) {
      Map<String, dynamic> respObj = json.decode(resp.body);
      if (respObj['code'] == 200) {
        originData = Map.from(respObj['data']);
        setState(() {
          this.data = respObj['data'];
        });
      }
    });
  }

  Widget ModelField(Map<String, dynamic> field) {
    switch (field['type']) {
      case 'string':
        return StringField(field['name'], getValue, updateValue, editable: field['editable'] == null);
      case 'boolean':
        return BooleanField(field['name'], getValue, updateValue, editable: field['editable'] == null);
      case 'integer':
        return IntegerField(field['name'], getValue, updateValue, editable: field['editable'] == null);
      case 'float':
        return FloatField(field['name'], getValue, updateValue, editable: field['editable'] == null);
      case 'date':
        return DateField(field['name'], getValue, updateValue, editable: field['editable'] == null);
      case 'datetime':
        return DateTimeField(field['name'], getValue, updateValue, editable: field['editable'] == null);
      case 'html':
        return HtmlField(field['name'], getValue, updateValue, editable: field['editable'] == null);
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
          ))),
          Row(
            children: <Widget>[
              FlatButton(
                child: Text('Save'),
                onPressed: () {
                  saveChange(context);
                },
              )
            ],
          )
        ]));
  }
}

class HtmlField extends StatefulWidget {
  final String title;
  final Function getValue;
  final Function setValue;
  final bool editable;

  HtmlField(this.title, this.getValue, this.setValue, {this.editable: true});

  HtmlFieldState createState() => HtmlFieldState();
}

class HtmlFieldState extends State<HtmlField> {
  final FocusNode focusNode = FocusNode();
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    focusNode.addListener(() {
      widget.setValue(widget.title, controller.text);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                      child: Text(upperFirst(widget.title) + ':'),
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
                    data: controller.text,
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
                )),
          ],
        )
      ],
    );
  }
}

class DateTimeField extends StatefulWidget {
  final String title;
  final Function getValue;
  final Function setValue;
  final bool editable;

  DateTimeField(this.title, this.getValue, this.setValue, {this.editable: true});

  DateTimeFieldState createState() => DateTimeFieldState();
}

class DateTimeFieldState extends State<DateTimeField> {
  DateTime currentValue;

  @override
  void initState() {
    String val = widget.getValue(widget.title);
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
    super.initState();
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
                      child: Text(upperFirst(widget.title) + ':'),
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
                            widget.setValue(widget.title, dateTime.toIso8601String());
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
  final String title;
  final Function getValue;
  final Function setValue;
  final bool editable;

  DateField(this.title, this.getValue, this.setValue, {this.editable: true});

  DateFieldState createState() => DateFieldState();
}

class DateFieldState extends State<DateField> {
  DateTime currentValue;

  @override
  void initState() {
    String val = widget.getValue(widget.title);
    if (val.contains('T')) {
      currentValue = DateTime.parse(val);
    } else {
      try {
        currentValue = DateTime.fromMillisecondsSinceEpoch(int.parse(val));
      } catch (e) {
        print(e);
      }
    }

    super.initState();
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
                      child: Text(upperFirst(widget.title) + ':'),
                    ))),
            Flexible(
                flex: 85,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: LayoutBuilder(builder: (ctx, cons) {
                    return Row(
                      children: <Widget>[
                        Text('  ' + (currentValue == null ? '' : DateFormat('yyyy-MM-dd').format(currentValue)) + '  '),
                        ScaledButton(cons.maxWidth * 0.03, Icon(Icons.calendar_today, size: cons.maxWidth * 0.02), () {
                          DatePicker.showDatePicker(context, locale: LocaleType.zh, showTitleActions: true, currentTime: DateTime.now(), onConfirm: (date) {
                            widget.setValue(widget.title, date.toIso8601String());
                            setState(() {
                              currentValue = date;
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
  final Function getValue;
  final Function setValue;
  final bool editable;

  FloatField(this.title, this.getValue, this.setValue, {this.editable: true});

  FloatFieldState createState() => FloatFieldState();
}

class FloatFieldState extends State<FloatField> {
  TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  @override
  void initState() {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        try {
          double.parse(controller.text);
          widget.setValue(widget.title, int.parse(controller.text));
        } catch (e) {
          print("Failed");
          controller.text = widget.getValue(widget.title).toString();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controller.text = widget.getValue(widget.title).toString();
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
                      child: Text(upperFirst(widget.title) + ':'),
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
                            setState(() {
                              controller.text = (int.parse(controller.text) - 0.1).toString();
                              widget.setValue(widget.title, int.parse(controller.text));
                            });
                          }, editable: widget.editable),
                          Container(
                              width: 180,
                              child: TextField(
                                enabled: widget.editable,
                                controller: controller,
                                textAlign: TextAlign.center,
                                focusNode: focusNode,
                              )),
                          ScaledButton(cons.maxWidth * 0.03, Icon(Icons.add), () {
                            setState(() {
                              controller.text = (int.parse(controller.text) + 0.1).toString();
                              widget.setValue(widget.title, int.parse(controller.text));
                            });
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
  final Function getValue;
  final Function setValue;
  final bool editable;

  IntegerField(this.title, this.getValue, this.setValue, {this.editable: true});

  IntegerFieldState createState() => IntegerFieldState();
}

class IntegerFieldState extends State<IntegerField> {
  TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  @override
  void initState() {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        try {
          int.parse(controller.text);
          widget.setValue(widget.title, int.parse(controller.text));
        } catch (e) {
          print("Failed");
          controller.text = widget.getValue(widget.title).toString();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controller.text = widget.getValue(widget.title).toString();
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
                      child: Text(upperFirst(widget.title) + ':'),
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
                            setState(() {
                              controller.text = (int.parse(controller.text) - 1).toString();
                              widget.setValue(widget.title, int.parse(controller.text));
                            });
                          }, editable: widget.editable),
                          Container(
                              width: 120,
                              child: TextField(
                                enabled: widget.editable,
                                controller: controller,
                                textAlign: TextAlign.center,
                                focusNode: focusNode,
                              )),
                          ScaledButton(cons.maxWidth * 0.03, Icon(Icons.add), () {
                            setState(() {
                              controller.text = (int.parse(controller.text) + 1).toString();
                              widget.setValue(widget.title, int.parse(controller.text));
                            });
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
  final Function getValue;
  final Function setValue;
  final bool editable;

  BooleanField(this.title, this.getValue, this.setValue, {this.editable});

  BooleanFieldState createState() => BooleanFieldState();
}

class BooleanFieldState extends State<BooleanField> {
  bool currentValue;

  @override
  void initState() {
    currentValue = widget.getValue(widget.title);
    super.initState();
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
                      child: Text(upperFirst(widget.title) + ':'),
                    ))),
            Flexible(
                flex: 85,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Checkbox(
                      value: this.currentValue,
                      onChanged: (newValue) {
                        if (widget.editable) {
                          widget.setValue(widget.title, newValue);
                          setState(() {
                            this.currentValue = newValue;
                          });
                        }
                      },
                    ))),
          ],
        ));
  }
}

class StringField extends StatelessWidget {
  final String title;
  final Function getValue;
  final Function setValue;
  final bool editable;
  final FocusNode focusNode = FocusNode();
  final TextEditingController controller = TextEditingController();

  StringField(this.title, this.getValue, this.setValue, {this.editable: true}) {
    focusNode.addListener(() {
      setValue(this.title, controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    controller.text = getValue(this.title);
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
                      child: Text(upperFirst(this.title) + ':'),
                    ))),
            Flexible(
                flex: 85,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      enabled: this.editable,
                      controller: controller,
                      focusNode: focusNode,
                    ))),
          ],
        ));
  }
}
