import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class IAMToken {
  String iamApiKey;
  String url;
  String accessToken;
  String refreshToken;
  String tokenType;
  int expiresIn;
  int expiration;

  IAMToken({@required this.iamApiKey, @required this.url});

  Future<IAMToken> retrieve() async {
    Map _body = {
      "grant_type": "urn:ibm:params:oauth:grant-type:apikey",
      "apikey": this.iamApiKey
    };
    var response = await http
        .post(
          Uri.parse("https://iam.bluemix.net/identity/token"),
          headers: {
            HttpHeaders.authorizationHeader: "Basic Yng6Yng=",
            HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
            HttpHeaders.acceptHeader: "application/json",
          },
          body: _body,
        )
        .timeout(const Duration(seconds: 360));
    Map data = json.decode(response.body);
    this.accessToken = data["access_token"];
    if (this.accessToken == null) {
      print("AccessToken is Null, please retry");
    }
    this.refreshToken = data["refresh_token"];
    this.tokenType = data["token_type"];
    this.expiresIn = data["expires_in"];
    this.expiration = data["expiration"];
    return this;
  }
}
