// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
      json['note'] as String,
      json['userId'] as String,
      json['token'] as String,
      (json['scope'] as List<dynamic>)
          .map((e) => _$enumDecode(_$TokenScopeEnumMap, e))
          .toList(),
      identity(json['createdAt'] as DateTime),
      identity(json['expiresAt'] as DateTime),
    );

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'note': instance.note,
      'userId': instance.userId,
      'token': instance.token,
      'scope': instance.scope.map((e) => _$TokenScopeEnumMap[e]).toList(),
      'createdAt': identity(instance.createdAt),
      'expiresAt': identity(instance.expiresAt),
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$TokenScopeEnumMap = {
  TokenScope.read: 'read',
  TokenScope.write: 'write',
};
