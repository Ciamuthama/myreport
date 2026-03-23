import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myreport/services/settings_service.dart';

class AiService {
  String claudeApiKey;
  String ollamaBaseUrl;
  String ollamaModel;

  AiService({
    this.claudeApiKey = '',
    this.ollamaBaseUrl = 'http://localhost:11434',
    this.ollamaModel = 'qewn3.5:397b',
  });

  //  FACTORY — loads from settings automatically 
  static Future<AiService> fromSettings() async {
    final settings = await SettingsService.getSettings();
    return AiService(
      claudeApiKey: settings['claude_api_key'] ?? '',
      ollamaBaseUrl:
          settings['ollama_base_url'] ?? 'http://localhost:11434',
      ollamaModel: settings['ollama_model'] ?? 'qewn3.5:397b',
    );
  }

  //  CHECK OLLAMA 
  Future<bool> isOllamaAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$ollamaBaseUrl/api/tags'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  //  MAIN METHOD — Ollama first, Claude fallback 
  Future<({String result, String usedModel})> expandActivities(
      String rawTasks) async {
    final ollamaUp = await isOllamaAvailable();

    if (ollamaUp) {
      try {
        final result = await _callOllama(rawTasks);
        return (result: result, usedModel: 'Ollama ($ollamaModel)');
      } catch (e) {
        print('Ollama failed, falling back to Claude: $e');
      }
    } else {
      print('Ollama unavailable at $ollamaBaseUrl, trying Claude...');
    }

    //  CLAUDE FALLBACK 
    if (claudeApiKey.isEmpty) {
      throw Exception(
        'Ollama is unavailable and no Claude API key is configured. '
        'Please add your Claude API key in Settings.',
      );
    }

    final result = await _callClaude(rawTasks);
    return (result: result, usedModel: 'Claude API');
  }

  //  OLLAMA CALL 
  Future<String> _callOllama(String rawTasks) async {
    final response = await http.post(
      Uri.parse('$ollamaBaseUrl/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': ollamaModel,
        'prompt': _buildPrompt(rawTasks),
        'stream': false,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'].toString().trim();
    }
    throw Exception('Ollama error: ${response.statusCode}');
  }

  //  CLAUDE CALL 
  Future<String> _callClaude(String rawTasks) async {
    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': claudeApiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-haiku-4-5',
        'max_tokens': 500,
        'messages': [
          {'role': 'user', 'content': _buildPrompt(rawTasks)}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'].toString().trim();
    }

    print('Claude error body: ${response.body}');
    throw Exception('Claude error: ${response.statusCode}');
  }

  //  PROMPT 
  String _buildPrompt(String rawTasks) => '''
You are a professional work report assistant.
Expand the following bullet points into clear, professional sentences
suitable for a weekly work report. Keep it concise — 1 sentences max.
Do not use bullet points in your response, write as plain flowing text.

Tasks:
$rawTasks''';
}