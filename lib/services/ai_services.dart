import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  final String claudeApiKey;
  final String ollamaBaseUrl;
  final String ollamaModel;

  AiService({
    required this.claudeApiKey,
    this.ollamaBaseUrl = 'http://localhost:11434', 
    this.ollamaModel = 'qwen3.5:397b-cloud',      
  });

  Future<bool> isOllamaAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$ollamaBaseUrl/api/tags'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<({String result, String usedModel})> expandActivities(
    String rawTasks) async {
    // Only use Ollama for expansion. If Ollama is unavailable or the request fails,
    // propagate the error instead of falling back to Claude.
    final ollamaUp = await isOllamaAvailable();
    if (!ollamaUp) {
      throw Exception('Ollama is not available at $ollamaBaseUrl');
    }

    final result = await _callOllama(rawTasks);
    return (result: result, usedModel: 'Ollama ($ollamaModel)');
  }

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

  Future<String> _callClaude(String rawTasks) async {
    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': claudeApiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-haiku-4-5', // correct model string
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

    // Print full response body to help debug any future errors
    print('Claude error body: ${response.body}');
    throw Exception('Claude error: ${response.statusCode}');
  }

  String _buildPrompt(String rawTasks) => '''
You are a professional work report assistant.
Expand the following bullet points into clear, professional sentences
suitable for a weekly work report. Keep it concise — 3 to 6 sentences max.
Do not use bullet points in your response, write as plain flowing text.

Tasks:
$rawTasks''';
}