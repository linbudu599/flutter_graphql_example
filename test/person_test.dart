// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import "package:flutter_graphql_example/person/model.dart";
// import "package:flutter_graphql_example/person/modal.dart";

// main() {
//   final String id = "10086";
//   final String name = "林不渡";
//   final int age = 18;

//   final Person person = Person(id: id, name: name, age: age);
//   group("Person Admin Unit Test", () {
//     test("should provide method as props getter", () {
//       expect(person.getId(), id);
//       expect(person.getName(), name);
//       expect(person.getAge(), age);
//     });
//   });

//   group("Person Admin Widget Test", () {
//     testWidgets('Operation Model On Edit Mode', (WidgetTester tester) async {
//       await tester.pumpWidget(MaterialApp(
//           home: OperationModal(
//         isAdd: false,
//         person: person,
//       )));

//       final Finder title = find.text("Edit or Delete Exist Person");

//       final Finder idField = find.text(id);
//       final Finder nameField = find.text(name);
//       final Finder ageField = find.text(age.toString());

//       final Finder addBtn = find.text("Add");
//       final Finder editBtn = find.text("Edit");
//       final Finder deleteBtn = find.text("Delete");

//       expect(title, findsOneWidget);

//       expect(idField, findsOneWidget);
//       expect(nameField, findsOneWidget);
//       expect(ageField, findsOneWidget);

//       expect(addBtn, findsNothing);
//       expect(editBtn, findsOneWidget);
//       expect(deleteBtn, findsOneWidget);

//       await tester.enterText(nameField, "芜湖!");
//       await tester.enterText(ageField, "21");
//     });
//   });
// }
