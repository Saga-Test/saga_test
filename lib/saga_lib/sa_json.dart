import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as dart;

//---------------------------------------------------------------------------------------------
// Json
//---------------------------------------------------------------------------------------------
// abstract class Json extends Map<String, dynamic> {
//   factory Json() => Map();
// }

//---------------------------------------------------------------------------------------------
// JsonSerializable
//---------------------------------------------------------------------------------------------
class JsonSerializable extends dart.JsonSerializable {
  const JsonSerializable() : super(fieldRename: FieldRename.pascal);
}

//---------------------------------------------------------------------------------------------
// JsonResult
//---------------------------------------------------------------------------------------------
class JsonResult extends dart.JsonSerializable {
  const JsonResult() : super(createToJson: false, fieldRename: FieldRename.pascal);
}

//---------------------------------------------------------------------------------------------
// JsonParameter
//---------------------------------------------------------------------------------------------
class JsonParameter extends dart.JsonSerializable {
  const JsonParameter() : super(createFactory: false, fieldRename: FieldRename.pascal);
}

//---------------------------------------------------------------------------------------------
// JsonKey
//---------------------------------------------------------------------------------------------
class JsonKey extends dart.JsonKey {
  const JsonKey({
    Object? defaultValue,
    bool? disallowNullValue,
    Function? fromJson,
    bool? ignore,
    bool? includeIfNull,
    String? name,
    bool? required,
    Function? toJson,
    Enum? unknownEnumValue,
  }) : super(
          defaultValue: defaultValue,
          disallowNullValue: disallowNullValue,
          fromJson: fromJson,
          ignore: ignore,
          includeIfNull: includeIfNull,
          name: name,
          required: required,
          toJson: toJson,
          unknownEnumValue: unknownEnumValue,
        );
}
