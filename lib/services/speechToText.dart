import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_ibm_watson_services/flutter_ibm_watson_services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_ibm_watson_services/utils/IAMToken.dart';

class SpeechToTextCredential {
  String username;
  String apikey;
  String version;
  String url;

  SpeechToTextCredential({
    this.username = 'apikey',
    this.version = "2020-09-24",
    @required this.apikey,
    @required this.url,
  });
}

class SpeechToText {
  SpeechToTextCredential speechToTextCredential;
  IAMToken token;
  String content;
  String model;
  String _text;

  SpeechToText({
    @required this.speechToTextCredential,
    this.content = "audio/webm;codecs=opus",
    this.model = "en-US_BroadbandModel",
  });

  Future<Null> createSession() async {
    this.token = await IAMToken(
        iamApiKey: '${speechToTextCredential.apikey}',
        url: '${speechToTextCredential.url}')
        .build();
    //print('STT Access Token: ${this.options.accessToken}');
  }

  Future<String> sendMessage(String fileUrl) async {
    _text = '';
    String token = this.token.accessToken;
    Uint8List bytes = await File(fileUrl).readAsBytes();
    var response = await http.post(
      Uri.parse('${speechToTextCredential.url}/v1/recognize?access_token=$token&model=${this.model}'),
      headers: {
        HttpHeaders.contentTypeHeader: this.content,
      },
      body: bytes,
    );
    var parsedJson = json.decode(response.body);
    List result = parsedJson['results'];
    for (var i = 0; i < result.length; i++) {
      _text += result[i]['alternatives'][0]['transcript'];
    }
    return _text;
  }
}
