import 'package:flutter/foundation.dart';

class Todo {
  const Todo({
    @required this.id,
    @required this.title,
    @required this.desc,
    @required this.accomplished,
  });

  final int id;
  final String title;
  final String desc;
  final bool accomplished;

  int getId() => this.id;
  String getTitle() => this.title;
  String getDesc() => this.desc;
  bool getAccomplished() => this.accomplished;
}
