import 'dart:io';
import "package:flutter/services.dart";
import 'package:path_provider/path_provider.dart';
import 'package:cleartec_docx_template/cleartec_docx_template.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart' as path_provider;


class DocxServices {
  Future<File> generateReport({
    required String name,
    required String periodStart,
    required String periodEnd,
    required String activitiesCompleted,
    required List<Map<String, String>> activitiesInProcess,
    required List<Map<String, String>> activitiesPending,
    required String issues,
     required DateTime today,
  }) async {
    final data = await rootBundle.load("assets/report_template.docx");
    final bytes = data.buffer.asUint8List();

    final docx = await DocxTemplate.fromBytes(bytes);
    final today = DateFormat("dd/MM/yyyy").format(DateTime.now());

    Content c = Content();
    c
    ..add(TextContent("date", today))
    ..add(TextContent("name", name))
    ..add(TextContent("period_start", periodStart))
    ..add(TextContent("period_end", periodEnd))
    ..add(TextContent("activities_completed", activitiesCompleted))
    ..add(TextContent("activity_1", activitiesInProcess.isNotEmpty ? activitiesInProcess[0]["tasks"] ?? "" : ""))
    ..add(TextContent("action_1", activitiesInProcess.isNotEmpty ? activitiesInProcess[0]['action'] ?? '' : ''))
        ..add(TextContent('due_1',
          activitiesInProcess.isNotEmpty ? activitiesInProcess[0]['due'] ?? '' : ''))
      ..add(TextContent('activity_2',
          activitiesInProcess.length > 1 ? activitiesInProcess[1]['task'] ?? '' : ''))
      ..add(TextContent('action_2',
          activitiesInProcess.length > 1 ? activitiesInProcess[1]['action'] ?? '' : ''))
      ..add(TextContent('due_2',
          activitiesInProcess.length > 1 ? activitiesInProcess[1]['due'] ?? '' : ''))
      ..add(TextContent('pending_1',
          activitiesPending.isNotEmpty ? activitiesPending[0]['task'] ?? '' : ''))
      ..add(TextContent('direction_1',
          activitiesPending.isNotEmpty ? activitiesPending[0]['direction'] ?? '' : ''))
      ..add(TextContent('pending_2',
          activitiesPending.length > 1 ? activitiesPending[1]['task'] ?? '' : ''))
      ..add(TextContent('direction_2',
          activitiesPending.length > 1 ? activitiesPending[1]['direction'] ?? '' : ''))
      ..add(TextContent('issues', issues));

      final generatedBytes = await docx.generate(c);

      // Use external storage directory for easier access on device
      final outputDir = await path_provider.getExternalStorageDirectory() ?? 
                        await getApplicationDocumentsDirectory();
      final fileName = '${DateFormat('dd-MM-yyyy').format(DateTime.now())}_$name.docx';
      final outputFile = File('${outputDir.path}/$fileName');
      await outputFile.writeAsBytes(generatedBytes!);
      return outputFile;
  }
  
}