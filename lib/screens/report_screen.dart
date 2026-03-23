import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/ai_services.dart';
import '../services/docx_services.dart';
import '../services/telegram_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  //  SETTINGS 
  String _claudeApiKey = '';
  String _telegramToken = '';
  String _telegramChatId = '';
  String _userName = '';
  String _department = '';
  String _ollamaUrl = '';
  String _ollamaModel = '';
  bool _settingsLoaded = false;

  //  FORM CONTROLLERS 
  final _tasksController = TextEditingController();
  final _activity1Controller = TextEditingController();
  final _action1Controller = TextEditingController();
  final _due1Controller = TextEditingController();
  final _activity2Controller = TextEditingController();
  final _action2Controller = TextEditingController();
  final _due2Controller = TextEditingController();
  final _pending1Controller = TextEditingController();
  final _direction1Controller = TextEditingController();
  final _pending2Controller = TextEditingController();
  final _direction2Controller = TextEditingController();
  final _issuesController = TextEditingController();

  // STATES
  String _aiExpandedText = '';
  String _modelUsed = '';
  bool _isGenerating = false;
  bool _isSending = false;
  bool _aiDone = false;

  // LIFECYCLE
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _tasksController.dispose();
    _activity1Controller.dispose();
    _action1Controller.dispose();
    _due1Controller.dispose();
    _activity2Controller.dispose();
    _action2Controller.dispose();
    _due2Controller.dispose();
    _pending1Controller.dispose();
    _direction1Controller.dispose();
    _pending2Controller.dispose();
    _direction2Controller.dispose();
    _issuesController.dispose();
    super.dispose();
  }

  // LOAD SETTINGS
  Future<void> _loadSettings() async {
    final settings = await SettingsService.getSettings();
    setState(() {
      _claudeApiKey = settings['claude_api_key'] ?? '';
      _telegramToken = settings['telegram_bot_token'] ?? '';
      _telegramChatId = settings['telegram_chat_id'] ?? '';
      _userName = settings['user_name'] ?? '';
      _department = settings['department'] ?? 'Software Development';
      _ollamaUrl = settings['ollama_base_url'] ?? 'http://localhost:11434';
      _ollamaModel = settings['ollama_model'] ?? 'llama3.2';
      _settingsLoaded = true;
    });
  }

  // GENERATE WITH AI 
Future<void> _generateWithAI() async {
  if (_tasksController.text.trim().isEmpty) {
    _showSnack('Please enter your completed tasks first', Colors.red);
    return;
  }

  if (_telegramToken.isEmpty || _telegramChatId.isEmpty) {
    _showSnack('Please configure your settings first ', Colors.orange);
    return;
  }

  setState(() => _isGenerating = true);

    try {
  final ai = AiService(
  claudeApiKey: dotenv.env['CLAUDE_API_KEY'] ?? '',
  ollamaBaseUrl: dotenv.env['OLLAMA_BASE_URL'] ?? '',
  ollamaModel: dotenv.env['OLLAMA_MODEL'] ?? '',
);

    final (:result, :usedModel) =
        await ai.expandActivities(_tasksController.text);

    setState(() {
      _aiExpandedText = result;
      _modelUsed = usedModel;
      _aiDone = true;
    });
  } catch (e) {
    _showSnack('$e', Colors.red);
  } finally {
    setState(() => _isGenerating = false);
  }
}

  //  GENERATE DOCX + SEND 
  Future<void> _generateAndSend() async {
    if (_aiExpandedText.isEmpty) {
      _showSnack('Please generate the report with AI first', Colors.red);
      return;
    }

    if (_telegramToken.isEmpty || _telegramChatId.isEmpty) {
      _showSnack('Please configure your settings first', Colors.orange);
      return;
    }

    setState(() => _isSending = true);

    try {
      final deadline = DeadlineService.getNextDeadline();
      final periodEnd = deadline;
      final periodStart = deadline.subtract(const Duration(days: 14));

      final docxService = DocxServices();
      final file = await docxService.generateReport(
        today: now,
        name: "Peter Muthama",
        periodStart: _formatDate(periodStart),
        periodEnd: _formatDate(periodEnd),
        activitiesCompleted: _aiExpandedText,
        activitiesInProcess: [
          {
            'task': _activity1Controller.text,
            'action': _action1Controller.text,
            'due': _due1Controller.text,
          },
          {
            'task': _activity2Controller.text,
            'action': _action2Controller.text,
            'due': _due2Controller.text,
          },
        ],
        activitiesPending: [
          {
            'task': _pending1Controller.text,
            'direction': _direction1Controller.text,
          },
          {
            'task': _pending2Controller.text,
            'direction': _direction2Controller.text,
          },
        ],
        issues: _issuesController.text,
      );

      final telegram = TelegramService(
        botToken: _telegramToken,  
        chatId: _telegramChatId,    
      );
    
      final success = await telegram.sendDocxReport(file);

      if (success) {
        _showSnack('Report sent successfully!', Colors.green);
        _clearForm();
      } else {
        _showSnack('Telegram send failed', Colors.red);
      }
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    } finally {
      setState(() => _isSending = false);
    }
  }

  //  HELPERS 
  String _formatDate(DateTime date) =>
      DateFormat('EEEE, dd MMMM yyyy').format(date);

  void _clearForm() {
    _tasksController.clear();
    _activity1Controller.clear();
    _action1Controller.clear();
    _due1Controller.clear();
    _activity2Controller.clear();
    _action2Controller.clear();
    _due2Controller.clear();
    _pending1Controller.clear();
    _direction1Controller.clear();
    _pending2Controller.clear();
    _direction2Controller.clear();
    _issuesController.clear();
    setState(() {
      _aiExpandedText = '';
      _modelUsed = '';
      _aiDone = false;
    });
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  //  UI HELPERS 
  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF0D1B2A),
          ),
        ),
      );

  Widget _inputField(
    TextEditingController ctrl,
    String hint, {
    int lines = 1,
  }) =>
      TextField(
        controller: ctrl,
        maxLines: lines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

  //  BUILD 
  @override
  Widget build(BuildContext context) {
    // Show loader while settings load
    if (!_settingsLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF57C00)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Weekly Report'),
        backgroundColor: const Color(0xFFF57C00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //  ACTIVITIES COMPLETED 
            _sectionHeader('Activities Completed'),
            const Text(
              'Enter tasks as bullet points, one per line',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 6),
            _inputField(
              _tasksController,
              '- Fixed login bug\n- Reviewed PRs\n- Updated dashboard',
              lines: 5,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateWithAI,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Expand with AI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF57C00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (_isGenerating)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child:
                      CircularProgressIndicator(color: Color(0xFFF57C00)),
                ),
              ),
            if (_aiDone) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'AI Expanded:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _modelUsed.contains('Ollama')
                                ? Colors.blue[100]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _modelUsed,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _modelUsed.contains('Ollama')
                                  ? Colors.blue[800]
                                  : Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(_aiExpandedText,
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],

            //  ACTIVITIES IN PROCESS 
            _sectionHeader('Activities In Process'),
            Row(children: [
              Expanded(child: _inputField(_activity1Controller, 'Task 1')),
              const SizedBox(width: 8),
              Expanded(
                  child: _inputField(_action1Controller, 'Next action')),
              const SizedBox(width: 8),
              SizedBox(
                  width: 90,
                  child: _inputField(_due1Controller, 'Due date')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _inputField(_activity2Controller, 'Task 2')),
              const SizedBox(width: 8),
              Expanded(
                  child: _inputField(_action2Controller, 'Next action')),
              const SizedBox(width: 8),
              SizedBox(
                  width: 90,
                  child: _inputField(_due2Controller, 'Due date')),
            ]),

            //  ACTIVITIES PENDING 
            _sectionHeader('Activities Pending'),
            Row(children: [
              Expanded(
                  child:
                      _inputField(_pending1Controller, 'Pending task 1')),
              const SizedBox(width: 8),
              Expanded(
                  child: _inputField(_direction1Controller, 'Direction')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child:
                      _inputField(_pending2Controller, 'Pending task 2')),
              const SizedBox(width: 8),
              Expanded(
                  child: _inputField(_direction2Controller, 'Direction')),
            ]),

            //  ISSUES 
            _sectionHeader('Issues for Immediate Attention'),
            _inputField(
              _issuesController,
              'Any blockers or urgent issues? (leave blank if none)',
              lines: 3,
            ),

            //  SEND BUTTON 
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: (_isSending || !_aiDone) ? null : _generateAndSend,
              icon: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _isSending
                    ? 'Generating & Sending...'
                    : 'Generate .docx & Send to Manager',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}