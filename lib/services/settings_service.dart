import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static Future<Map<String, String>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_name':
          prefs.getString('user_name') ?? 'Your Name',
      'claude_api_key':
          prefs.getString('claude_api_key') ?? '',
      'telegram_bot_token':
          prefs.getString('telegram_bot_token') ?? '',
      'telegram_chat_id':
          prefs.getString('telegram_chat_id') ?? '',
      'ollama_base_url':
          prefs.getString('ollama_base_url') ?? 'http://localhost:11434',
      'ollama_model':
          prefs.getString('ollama_model') ?? 'llama3.2',
      'department':
          prefs.getString('department') ?? 'Software Development',
    };
  }

  static Future<bool> isConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('telegram_bot_token') ?? '';
    final chatId = prefs.getString('telegram_chat_id') ?? '';
    final name = prefs.getString('user_name') ?? '';
    return token.isNotEmpty && chatId.isNotEmpty && name.isNotEmpty;
  }
}