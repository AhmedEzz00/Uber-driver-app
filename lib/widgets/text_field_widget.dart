import 'package:flutter/material.dart';

Widget textFieldWidget(
    {String label,
    TextInputType textInputType,
    bool isObsecure = false,
    TextEditingController controller}) {
  return TextFormField(
    controller: controller,
    keyboardType: textInputType,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 12.0,
      ),
      hintStyle: TextStyle(
        color: Colors.grey,
        fontSize: 10.0,
      ),
    ),
    style: TextStyle(fontSize: 14.0),
    obscureText: isObsecure,
  );
}
