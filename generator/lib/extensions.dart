import 'package:basic_utils/basic_utils.dart';

extension StringExtension on String {
  String toSnakeCase() => StringUtils.camelCaseToLowerUnderscore(this);
  String get uncapitalized =>
      isNotEmpty ? this[0].toLowerCase() + substring(1) : this;
}
