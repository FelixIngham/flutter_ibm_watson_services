import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_ibm_watson_services/flutter_ibm_watson_services.dart';
import 'package:flutter_ibm_watson_services/utils/IAMToken.dart';
import 'package:http/http.dart' as http;

class TextToSpeechCredential {
  String username;
  String apikey;
  String version;
  String url;

  TextToSpeechCredential({
    this.username = 'apikey',
    this.version = "2020-09-24",
    @required this.apikey,
    @required this.url,
  });
}

class TextToSpeech {
  TextToSpeechCredential textToSpeechCredential;
  IAMToken token;
  String accept;
  String voice;

  TextToSpeech({
    @required this.textToSpeechCredential,
    this.accept = "audio/webm;codecs=opus",
    this.voice = "en-GB_JamesV3Voice",
  });

  Future<Null> createSession() async {
    this.token = await IAMToken(
            iamApiKey: '${textToSpeechCredential.apikey}',
            url: '${textToSpeechCredential.url}')
        .retrieve();
    //print('TTS Access Token: ${this.token.accessToken}');
  }

  Future<Uint8List> sendMessage(String textInput) async {
    String token = this.token.accessToken;
    var response = await http.post(
      Uri.parse(
          '${textToSpeechCredential.url}/v1/synthesize?access_token=$token&voice=${this.voice}'),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "application/json",
        'Accept': this.accept
      },
      body: '{\"text\":\"$textInput\"}',
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then proceed.
       return response.bodyBytes;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Unsuccessful response');
    }
  }
}
