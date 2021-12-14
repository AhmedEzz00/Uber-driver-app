import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget homeWorkAddress({IconData iconData, String maintext,String hintText}) {
  return Row(
    children: [
      Icon(
        iconData,
        color: Colors.grey,
      ),
      SizedBox(
        width: 12.0,
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(maintext),
        SizedBox(
          height: 4.0,
        ),
        Text(
          hintText,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 12.0,
          ),
        ),
      ])
    ],
  );
}
