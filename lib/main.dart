import 'package:flutter/material.dart';
import 'package:myreport/screens/report_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');  
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Docx Generation Test')),
        body: ReportScreeen(),
        )
  ));
}
