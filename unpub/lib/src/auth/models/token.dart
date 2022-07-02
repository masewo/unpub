import 'package:json_annotation/json_annotation.dart';
import 'package:unpub/src/auth/models/token_scope.dart';

part 'token.g.dart';

DateTime identity(DateTime x) => x;

@JsonSerializable()
class Token {
  final String note;
  final String userId;
  final String token;
  final List<TokenScope> scope;

  @JsonKey(fromJson: identity, toJson: identity)
  final DateTime createdAt;

  @JsonKey(fromJson: identity, toJson: identity)
  final DateTime expiresAt;

  Token(this.note, this.userId, this.token, this.scope, this.createdAt, this.expiresAt);

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
  Map<String, dynamic> toJson() => _$TokenToJson(this);
}

