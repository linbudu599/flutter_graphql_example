import 'package:flutter/foundation.dart';

class Person {
  const Person({@required this.id, @required this.name, @required this.age});

  final String id;
  final String name;
  final int age;

  String getId() => this.id;
  String getName() => this.name;
  int getAge() => this.age;
}
