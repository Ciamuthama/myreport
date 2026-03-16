import 'dart:io';
import 'package:http/http.dart' as http;

class TelegramService{
  final String botToken;
  final String chatId;

  TelegramService({required this.botToken, required this.chatId});

  Future<bool> sendDocxReport(File docxFile, String caption) async{
    final url = Uri.parse('https://api.telegram.org/bot$botToken/sendDocument');

    final request = http.MultipartRequest('POST', url);
    ..fields['chat_id'] = chatId
    ..fields['caption'] = caption
    ..files.add(await http.MultipartFile.fromPath(
      'document',
       docxFile.path,
       filename: docxFile.path.split('/').last,
       ));

       final response = await request.send();
       return response.statusCode == 200;
  }
}