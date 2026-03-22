import 'package:flutter/material.dart';
import 'package:myreport/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _claudeKeyController = TextEditingController();
  final _telegramTokenController = TextEditingController();
  final _telegramChatIdController = TextEditingController();
  final _ollamaUrlController = TextEditingController();
  final _ollamaModelController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _showClaudeKey = false;
  bool _showTelegramToken = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _claudeKeyController.dispose();
    _telegramTokenController.dispose();
    _telegramChatIdController.dispose();
    _ollamaUrlController.dispose();
    _ollamaModelController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  //  LOAD FROM SHARED PREFERENCES
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text =
          prefs.getString('user_name') ?? '';
      _claudeKeyController.text =
          prefs.getString('claude_api_key') ?? '';
      _telegramTokenController.text =
          prefs.getString('telegram_bot_token') ?? '';
      _telegramChatIdController.text =
          prefs.getString('telegram_chat_id') ?? '';
      _ollamaUrlController.text =
          prefs.getString('ollama_base_url') ?? 'http://localhost:11434';
      _ollamaModelController.text =
          prefs.getString('ollama_model') ?? 'llama3.2';
      _departmentController.text =
          prefs.getString('department') ?? 'Software Development';
      _isLoading = false;
    });
  }

  //  SAVE TO SHARED PREFERENCES
Future<void> _saveSettings() async {
  // Validate required fields
  if (_nameController.text.trim().isEmpty) {
    _showSnack('Your name is required', Colors.red);
    return;
  }
  if (_telegramTokenController.text.trim().isEmpty) {
    _showSnack('Telegram bot token is required', Colors.red);
    return;
  }
  if (_telegramChatIdController.text.trim().isEmpty) {
    _showSnack('Telegram chat ID is required', Colors.red);
    return;
  }

  setState(() => _isSaving = true);

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('claude_api_key', _claudeKeyController.text.trim());
    await prefs.setString('telegram_bot_token', _telegramTokenController.text.trim());
    await prefs.setString('telegram_chat_id', _telegramChatIdController.text.trim());
    await prefs.setString('ollama_base_url', _ollamaUrlController.text.trim());
    await prefs.setString('ollama_model', _ollamaModelController.text.trim());
    await prefs.setString('department', _departmentController.text.trim());

    _showSnack(' Settings saved!', Colors.green);


    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false, 
      );
    }
  } catch (e) {
    _showSnack('Error saving settings: $e', Colors.red);
  } finally {
    setState(() => _isSaving = false);
  }
}

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }


  Widget _sectionHeader(String title, IconData icon) => Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF0D1B2A),
              ),
            ),
          ],
        ),
      );

  Widget _inputField(
    TextEditingController ctrl,
    String label,
    String hint, {
    bool obscure = false,
    bool? showText,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0D1B2A),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            obscureText: obscure && !(showText ?? false),
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 13, color: Colors.grey),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              suffixIcon: onToggleVisibility != null
                  ? IconButton(
                      icon: Icon(
                        (showText ?? false)
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
            ),
          ),
          if (helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                helperText,
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          const SizedBox(height: 12),
        ],
      );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Settings are stored securely on your device. They are never shared.',
                      style:
                          TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

         
            _sectionHeader('Personal Info', Icons.person),
            _inputField(
              _nameController,
              'Your Full Name',
              'e.g. Peter Muthama',
              helperText: 'Used in the report header',
            ),
            _inputField(
              _departmentController,
              'Department',
              'e.g. Software Development',
            ),

        
            _sectionHeader('Telegram', Icons.send),
            _inputField(
              _telegramTokenController,
              'Bot Token',
              'e.g. 123456:ABC-DEF...',
              obscure: true,
              showText: _showTelegramToken,
              onToggleVisibility: () => setState(
                  () => _showTelegramToken = !_showTelegramToken),
              helperText: 'Get this from @BotFather on Telegram',
            ),
            _inputField(
              _telegramChatIdController,
              'Manager Chat ID',
              'e.g. 987654321',
              keyboardType: TextInputType.number,
              helperText:
                  'Send /start to your bot then check getUpdates',
            ),

           
            _sectionHeader('AI Settings', Icons.auto_awesome),
            _inputField(
              _claudeKeyController,
              'Claude API Key (optional)',
              'sk-ant-api03-...',
              obscure: true,
              showText: _showClaudeKey,
              onToggleVisibility: () =>
                  setState(() => _showClaudeKey = !_showClaudeKey),
              helperText:
                  'Only needed if Ollama is unavailable. Get from console.anthropic.com',
            ),
            _inputField(
              _ollamaUrlController,
              'Ollama URL',
              'http://localhost:11434',
              helperText:
                  'Use localhost:11434 with ADB reverse, or your PC\'s local IP',
            ),
            _inputField(
              _ollamaModelController,
              'Ollama Model',
              'e.g. llama3.2, mistral, qwen2.5',
              helperText: 'Run "ollama list" to see available models',
            ),

            const SizedBox(height: 12),


            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSettings,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(
                  _isSaving ? 'Saving...' : 'Save Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
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