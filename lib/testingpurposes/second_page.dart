import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Page"),
      ),
      body: Center(
        child: Text(
          'You have navigated to the second page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
