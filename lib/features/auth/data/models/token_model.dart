class TokenModel {
  final String accessToken;
  final String? tokenType;
  final int? expiresIn;

  TokenModel({
    required this.accessToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] ?? json['token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
}
