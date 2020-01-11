import 'package:admin_template/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_html/flutter_html.dart';

class ModelScreen extends StatelessWidget {
  final String modelName;

  ModelScreen(this.modelName);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Align(alignment: Alignment.centerLeft, child: Text('User', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold))),
            Divider(),
            StringField("username", "test01", editable: false),
            StringField("displayName", "Test"),
            BooleanField('Administrator', true),
            IntegerField('Age', 18),
            FloatField('Height', 180.8),
            DateField('Birthday', '1992/09/13'),
            HtmlField('Story', '<h1>Hello</h1>\n<h2>World</h2>'),
          ],
        ));
  }
}

class HtmlField extends StatefulWidget {
  final String title, value;

  HtmlField(this.title, this.value);

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
            // Flexible(
            //     flex: 8,
            //     child: Align(
            //         alignment: Alignment.centerLeft,
            //         child: GestureDetector(
            //           child: Text("Edit"),
            //           onTap: () {
            //             print('Edit');
            //           },
            //         ))),
          ],
        ),
        Row(
          children: <Widget>[
            Spacer(flex: 15),
            Flexible(
                flex: 85,
                child: TextField(
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

class DateField extends StatefulWidget {
  final String title, value;

  DateField(this.title, this.value);

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
                        Text('  ' + this.currentValue + '  '),
                        ScaledButton(cons.maxWidth * 0.03, Icon(Icons.calendar_today, size: cons.maxWidth * 0.02), () {
                          DatePicker.showDatePicker(context, locale: LocaleType.zh, showTitleActions: true, currentTime: DateTime.now(), onConfirm: (date) {
                            setState(() {
                              this.currentValue = date.year.toString() + '/' + date.month.toString() + '/' + date.day.toString();
                            });
                          });
                        }),
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

  FloatField(this.title, this.value);

  FloatFieldState createState() => FloatFieldState(this.value);
}

class FloatFieldState extends State<FloatField> {
  double currentValue;
  TextEditingController controller = TextEditingController();

  FloatFieldState(this.currentValue);

  @override
  Widget build(BuildContext context) {
    controller.text = widget.value.toStringAsFixed(10);
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
                          }),
                          Container(
                              color: Colors.yellow,
                              width: 250,
                              child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: TextField(
                                    controller: controller,
                                    textAlign: TextAlign.center,
                                    onEditingComplete: () {
                                      print(controller.text);
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
                          }),
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

  IntegerField(this.title, this.value);

  IntegerFieldState createState() => IntegerFieldState(this.value);
}

class IntegerFieldState extends State<IntegerField> {
  int currentValue;
  TextEditingController controller = TextEditingController();

  IntegerFieldState(this.currentValue);

  @override
  Widget build(BuildContext context) {
    controller.text = this.currentValue.toString();
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
                            setState(() {
                              this.currentValue -= 1;
                            });
                          }),
                          Container(
                              width: 150,
                              child: TextField(
                                maxLength: 10,
                                controller: controller,
                                textAlign: TextAlign.center,
                                onChanged: (value) {
                                  this.currentValue = int.parse(value);
                                },
                              )),
                          ScaledButton(cons.maxWidth * 0.03, Icon(Icons.add), () {
                            setState(() {
                              this.currentValue += 1;
                            });
                          }),
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
  final bool initValue;

  BooleanField(this.title, this.initValue);

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
                        setState(() {
                          this.checkValue = newValue;
                        });
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
