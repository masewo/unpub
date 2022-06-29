import 'package:json_annotation/json_annotation.dart';
import 'package:unpub/src/auth/models/api_scopes.dart';

part 'api_token.g.dart';

@JsonSerializable()
class ApiToken {
  final String id;
  final String userId;
  final String token;
  final List<ApiScope> scopes;

  ApiToken(this.id, this.userId, this.token, this.scopes);

  factory ApiToken.fromJson(Map<String, dynamic> json) => _$ApiTokenFromJson(json);
  Map<String, dynamic> toJson() => _$ApiTokenToJson(this);
}
