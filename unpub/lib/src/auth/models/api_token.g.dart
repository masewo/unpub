// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiToken _$ApiTokenFromJson(Map<String, dynamic> json) => ApiToken(
      json['id'] as String,
      json['userId'] as String,
      json['token'] as String,
      (json['scopes'] as List<dynamic>)
          .map((e) => _$enumDecode(_$ApiScopeEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$ApiTokenToJson(ApiToken instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'token': instance.token,
      'scopes': instance.scopes.map((e) => _$ApiScopeEnumMap[e]).toList(),
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

const _$ApiScopeEnumMap = {
  ApiScope.read: 'read',
  ApiScope.write: 'write',
};
