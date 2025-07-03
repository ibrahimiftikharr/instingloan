import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class DialogflowService {
  late AutoRefreshingAuthClient _client;
  final _scopes = ['https://www.googleapis.com/auth/cloud-platform'];

  Future<void> init() async {
    final jsonCredentials = await rootBundle.loadString('assets/loanassistbot.json');
    final credentials = ServiceAccountCredentials.fromJson(jsonCredentials);
    _client = await clientViaServiceAccount(credentials, _scopes);
  }

  Future<String> detectIntent(String projectId, String sessionId, String userMessage) async {
    final url = Uri.parse(
        'https://dialogflow.googleapis.com/v2/projects/$projectId/agent/sessions/$sessionId:detectIntent');

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'queryInput': {
          'text': {'text': userMessage, 'languageCode': 'en'}
        }
      }),
    );

    final data = jsonDecode(response.body);
    return data['queryResult']['fulfillmentText'] ?? 'No response';
  }
}
