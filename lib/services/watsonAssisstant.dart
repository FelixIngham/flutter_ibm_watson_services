import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WatsonAssistantResponse {
  var result;
  WatsonAssistantContext context;

  WatsonAssistantResponse({this.result, this.context});
}

class WatsonAssistantContext {
  Map<String, dynamic> context;

  WatsonAssistantContext({
    this.context,
  });

  void resetContext() {
    this.context = {};
  }
}

class WatsonAssistantV2Credential {
  String username;
  String apikey;
  String version;
  String url;
  String assistantID;

//Addition to suit the need of projection

  WatsonAssistantV2Credential({
    this.username = 'apikey',
    @required this.apikey,
    this.version = "2020-09-24",
    @required this.url,
    @required this.assistantID,
  });
}

class WatsonAssistantApiV2 {
  WatsonAssistantV2Credential watsonAssistantCredential;
  var auth;
  String sessionId = 'Expired';

  WatsonAssistantApiV2({
    @required this.watsonAssistantCredential,
  });

  Future<Null> createSession() async {
    try {
      String urlWatsonAssistant =
          '${watsonAssistantCredential.url}/v2/assistants/${watsonAssistantCredential.assistantID}/sessions?version=${watsonAssistantCredential.version}';

      this.auth = 'Basic ' +
          base64Encode(utf8.encode(
              '${watsonAssistantCredential.username}:${watsonAssistantCredential.apikey}'));
      //Create a new session.
      // A session is used to send user input to a skill and receive responses.
      // It also maintains the state of the conversation.
      var newSess = await http.post(
        Uri.parse(urlWatsonAssistant),
        headers: {
          "content-type": "application/json",
          HttpHeaders.authorizationHeader: auth
        },
      );
      var parsedJsonSession = json.decode(newSess.body);
      this.sessionId = parsedJsonSession['session_id'];
      print('the session ${this.sessionId} is created');
    } catch (error) {
      return error;
    }
  }

  Future<Null> deleteSession() async {
    await http.delete(
      Uri.parse(
          '${watsonAssistantCredential.url}/v2/assistants/${watsonAssistantCredential.assistantID}/sessions/${this.sessionId}/message?version=${watsonAssistantCredential.version}'),
      headers: {
        "content-type": "application/json",
      },
    );
    this.sessionId = 'Expired';
  }

  Future<WatsonAssistantResponse> sendMessage(
      String textInput, WatsonAssistantContext context) async {
    bool enableContext = false;
    //Include user booking details in the request if it is present. Default for
    // all variable is set to null by Virtual assistant during the opening node.
    if (textInput == 'Y') {
      enableContext = true;
    }
    Map<String, dynamic> _body = {
      "input": {
        "message_type": "text",
        "text": textInput,
        "options": {"return_context": enableContext, "export": true}
      },
      "context": context.context
    };
    // Send HHTP request and wait for reponse.
    var response = await http.post(
        Uri.parse(
            '${watsonAssistantCredential.url}/v2/assistants/${watsonAssistantCredential.assistantID}'
            '${this.sessionId}/message?version=${watsonAssistantCredential.version}'),
        headers: {
          "content-type": "application/json",
          HttpHeaders.authorizationHeader: auth
        },
        body: json.encode(_body));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then decode reponse.
      //Decode response and extract relevant information from the response structure
      Map<String, dynamic> _result = json.decode(response.body);
      var watsonResponse = _result['output']['generic'];
      WatsonAssistantContext _context =
          WatsonAssistantContext(context: _result['context']);
      WatsonAssistantResponse watsonAssistantResult =
          WatsonAssistantResponse(context: _context, result: watsonResponse);
      return watsonAssistantResult;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Unsuccessful request');
    }
  }
}
