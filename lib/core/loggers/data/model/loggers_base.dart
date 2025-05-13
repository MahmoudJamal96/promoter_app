mixin LoggersBase {
  LoggersBase fromMap(Map<String, dynamic> map);
}
mixin ListLoggersBase on LoggersBase {
  List<LoggersBase>? get list;
}