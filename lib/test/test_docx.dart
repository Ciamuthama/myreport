import 'package:flutter/material.dart';
import '../services/docx_services.dart';

class TestDocx extends StatefulWidget {
    const TestDocx({super.key});

    @override
    State<TestDocx> createState() => _TestDocxState();
}

class _TestDocxState extends State<TestDocx> {
   String  _status = 'Tap the button to test';
   bool _isLoading = false;


   Future<void> _testGeneration() async{
    setState(() {
        _isLoading = true;
        _status = 'Generating document...';
    });

    try {
      final docxService = DocxServices();
      final file = await docxService.generateReport(
        today: DateTime.now(),
        name: 'Peter Muthama',
        periodStart: 'Monday, 01 March 2026',
        periodEnd: DateTime.now().toString(),
        activitiesCompleted:
            'Completed integration of the Claude AI API into the ReportBot Flutter application. Reviewed and merged three pull requests on the Sacco Portal project.',
        activitiesInProcess: [
          {
            'task': 'Sacco Portal Website',
            'action': 'Final QA testing',
            'due': '20/03/2026',
          },
          {
            'task': 'Sacco Member App',
            'action': 'UI implementation',
            'due': '23/03/2026',
          },
        ],
        activitiesPending: [
          {
            'task': 'API documentation',
            'direction': 'Awaiting backend specs',
          },
        ],
        issues: '',
      );
      setState(() {
        _status="Document generated successfully: ${file.path}";
      });
    } catch (e) {
      setState(() {
        _status = 'Error generating document: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
   }
@override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Docx Generation'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _status,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGeneration,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.description),
              label: Text(_isLoading ? 'Generating...' : 'Generate Test Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}