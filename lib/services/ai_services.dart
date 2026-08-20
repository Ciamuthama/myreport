import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myreport/services/settings_service.dart';

class AiService {
  String ollamaBaseUrl;
  String ollamaModel;

  AiService({
    this.ollamaBaseUrl = 'http://10.147.19.144:11434',
    this.ollamaModel = 'gemma4:31b-cloud',
  });

  // FACTORY — loads from settings automatically
  static Future<AiService> fromSettings() async {
    final settings = await SettingsService.getSettings();
    return AiService(
      ollamaBaseUrl:
          settings['ollama_base_url'] ?? 'http://10.147.19.144:11434',
      ollamaModel: settings['ollama_model'] ?? 'gemma4:31b-cloud',
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

  // MAIN METHOD — Ollama only
  Future<({String result, String usedModel})> expandActivities(
      String rawTasks) async {
    final ollamaUp = await isOllamaAvailable();

    if (!ollamaUp) {
      throw Exception(
        'Ollama is unavailable at $ollamaBaseUrl. Please check your Ollama service.',
      );
    }

    final result = await _callOllama(rawTasks);
    return (result: result, usedModel: 'Ollama ($ollamaModel)');
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

  // PROMPT
  String _buildPrompt(String rawTasks) => '''
You are a professional work report assistant.
Expand the following bullet points into clear, professional sentences
suitable for a weekly work report. Keep it concise — 1 sentences max.
use bullet points in your response, write as plain flowing text and return one response.

Tasks:
$rawTasks''';
}