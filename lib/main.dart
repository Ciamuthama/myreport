import 'package:flutter/material.dart';

import 'package:myreport/notification.dart';
import 'package:myreport/screens/report_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myreport/services/deadline_service.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await NotificationService.init();
  runApp(const ReportBotApp());
}

class ReportBotApp extends StatelessWidget {
  const ReportBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReportBot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  int _daysUntilDeadline() => DeadlineService.daysUntilDeadline();

  @override
  Widget build(BuildContext context) {
    final daysLeft = _daysUntilDeadline();
    final isUrgent = daysLeft <= 2;
    final deadline = DateTime(2026, 3, 27);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('ReportBot'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // ── DEADLINE CARD ──
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUrgent ? Colors.red[300]! : Colors.orange[300]!,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 40,
                    color: isUrgent ? Colors.red : Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Next Report Due',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DeadlineService.formattedDeadline(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isUrgent ? Colors.red : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      daysLeft <= 0 ? 'DUE TODAY!' : '$daysLeft days left',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── START REPORT BUTTON ──
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportScreen()),
              ),
              icon: const Icon(Icons.edit_note, size: 28),
              label: const Text(
                'Start New Report',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Set real reminders
            OutlinedButton.icon(
              onPressed: () async {
                final deadline = DeadlineService.getNextDeadline();
                await NotificationService.scheduleReportReminders(deadline);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ' Reminders set for ${DeadlineService.formattedDeadline()}!',
                    ),
                    backgroundColor: Colors.green,
                    clipBehavior: Clip.hardEdge,
                  ),
                );
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Set Deadline Reminder'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
