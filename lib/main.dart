import 'package:flutter/material.dart';
import 'package:myreport/test/test_docx.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Docx Generation Test')),
        body: TestDocx())
        )
  );
}
