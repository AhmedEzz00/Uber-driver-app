import 'package:flutter/material.dart';

Widget LogButton({String text,Function onPressed}) {
  return MaterialButton(
      color: Colors.yellow[600],
      textColor: Colors.white,
      child: Container(
        height: 50.0,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: 'Brand Bold',
            ),
          ),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
      onPressed: onPressed);
}
