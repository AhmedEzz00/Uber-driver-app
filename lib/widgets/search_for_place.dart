import 'package:flutter/material.dart';

class SearchForPlace extends StatelessWidget {
  final String image;
  final String hint;
  final TextEditingController controller;
  final Function onChanged;
  SearchForPlace({this.image, this.hint, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          image,
          height: 16.0,
          width: 16.0,
        ),
        SizedBox(
          width: 18.0,
        ),
        Expanded(
          child: Container(
            height: 40.0,
            decoration: BoxDecoration(
              color: Colors.grey[350],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(
                3.0,
              ),
              child: TextField(
                onChanged: onChanged,
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  //fillColor: Colors.grey[400],
                  //filled: true,
                  border: InputBorder.none,
                  prefix: SizedBox(
                    width: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
