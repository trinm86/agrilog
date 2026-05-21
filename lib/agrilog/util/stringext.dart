extension StringListExt on Iterable<String?> {
  String joinNonEmpty(String separator) {
    return where((s) => s != null && s.trim().isNotEmpty).join(separator);
  }
}

extension StringExt on String {
  String removeNewLine() {
    return trim().replaceAll(RegExp(r'\r\n|\r|\n'), '');
  }
}