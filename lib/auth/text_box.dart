import 'package:flutter/material.dart';

// เอาไว้ตกแต่งตัวอักษร
class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;
  const MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2.5),
        color: Colors.white,
      ),
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
      ),
      padding: const EdgeInsets.only(
        left: 15,
        bottom: 15,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sectionName,
              style: TextStyle(color: Colors.grey[500]),
            ),
            IconButton(
                onPressed: onPressed,
                icon: Icon(
                  Icons.border_color,
                  color: Colors.grey[400],
                )),
          ],
        ),
        Text(text),
      ]),
    );
  }
}

class MyTextBox1 extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;
  const MyTextBox1({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 4),
        color: Colors.white,
      ),
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
      ),
      padding: const EdgeInsets.only(
        left: 15,
        bottom: 15,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sectionName,
              style: TextStyle(color: Colors.grey[500]),
            ),
            IconButton(
                onPressed: onPressed,
                icon: Icon(
                  Icons.border_color,
                  color: Colors.grey[400],
                )),
          ],
        ),
        Text(text),
      ]),
    );
  }
}
