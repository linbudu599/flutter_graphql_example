import 'package:flutter/foundation.dart';

class Todo {
  const Todo({
    @required this.id,
    @required this.title,
    @required this.accomplished,
  });

  final String id;
  final String title;
  final bool accomplished;

  String getId() => this.id;
  String getTitle() => this.title;
  bool getAccomplished() => this.accomplished;
}
