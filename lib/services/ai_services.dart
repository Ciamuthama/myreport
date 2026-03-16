import 'dart:convert';
import 'package:http/http.dart' as http;

class AiServices {
  final String claudeApiKey;
  final String ollamaBaseUrl;
  final String ollamaModel;

  AiServices({
    required this.claudeApiKey,
    required this.ollamaBaseUrl,
    required this.ollamaModel,
  });

  Future<bool> isOllamaAvailable() async{
    try {
      final response = await http.get(Uri.parse('$ollamaBaseUrl/api/tags'))
      .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch(_){
      return false;
    }
  }

  Future<({String result, String useModel})> expandActivities(String rawTasks) async{
    final ollamaUp = await isOllamaAvailable();

    if(ollamaUp){
      try {
        final result = await _callOllama(rawTasks);
        return (result: result, useModel: 'ollama($ollamaModel)');
      } catch(e){
        throw Exception('Failed to expand activities with Ollama: $e');
      }
    }

    final result = await _callAPI(rawTasks);
    return (result: result, useModel: 'api');
  }

Future<String> _callOllama(String rawTasks) async{
  final response = await http.post(
    Uri.parse('$ollamaBaseUrl/api/generate'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'model': ollamaModel,
      'prompt': _buildPrompt(rawTasks),
      'stream': false,
    }),
  );
  if (response.statusCode == 200){
    final data = jsonDecode(response.body);
    return data['response'].toString().trim();
  } 
  throw Exception('Ollama API error: ${response.statusCode} - ${response.body}'); 
}

Future<String> _callAPI(String rawTasks) async{
 final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': claudeApiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-haiku-4-5-20251001', 
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
