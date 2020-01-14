import 'package:flutter/material.dart';

const Color COLOR_SIDE_FONT = Colors.white;
const TextStyle TEXTSTYLE_SIDE = TextStyle(color: COLOR_SIDE_FONT, fontSize: 28);

const double MODEL_COLUMN_SPACE = 10.0;

class ScaledButton extends StatelessWidget {
  final double size;
  final Widget child;
  final Function onPressed;
  final bool editable;
  Color color;

  ScaledButton(this.size, this.child, this.onPressed, {this.color, this.editable: true});

  @override
  Widget build(BuildContext context) {
    if (this.color == null) this.color = Colors.white;
    return Container(
        width: size,
        height: size,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: RawMaterialButton(
                child: this.child,
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: this.color,
                onPressed: () {
                  if (this.editable) {
                    this.onPressed();
                  }
                },
              ),
            )
          ],
        ));
  }
}