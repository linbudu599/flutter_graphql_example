import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import "client.dart";
import "model.dart";

class OperationModal extends StatefulWidget {
  final Person person;
  final bool isAdd;

  OperationModal({Key key, this.person, @required this.isAdd})
      : super(key: key);

  @override
  OperationModalState createState() =>
      OperationModalState(this.person, this.isAdd);
}

class OperationModalState extends State<OperationModal> {
  final Person person;
  final bool isAdd;

  OperationModalState(this.person, this.isAdd);

  TextEditingController personId = TextEditingController();
  TextEditingController personName = TextEditingController();
  TextEditingController personAge = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!this.isAdd) {
      personId.text = person.getId() ?? "";
      personName.text = person.getName() ?? "";
      personAge.text = person.getAge().toString() ?? "";
    }
  }

  Future<Null> _handleAdd() async {
    GraphQLClient _client = clientToQuery();
    QueryResult result = await _client.mutate(
      MutationOptions(
        documentNode: gql(addPerson(
          personId.text,
          personName.text,
          int.parse(personAge.text),
        )),
      ),
    );
    if (!result.hasException) {
      personId.clear();
      personName.clear();
      personAge.clear();
      Navigator.of(context).pop();
    }
  }

  Future<Null> _handleEdit() async {
    GraphQLClient _client = clientToQuery();
    QueryResult result = await _client.mutate(
      MutationOptions(
          documentNode: gql(
        editPerson(
          personId.text,
          personName.text,
          int.parse(personAge.text),
        ),
      )),
    );
    if (!result.hasException) {
      personId.clear();
      personName.clear();
      personAge.clear();
    }
    Navigator.of(context).pop();
  }

  Widget get _deleteBtn => FlatButton(
        child: Text("Delete"),
        onPressed: () async {
          GraphQLClient _client = clientToQuery();
          QueryResult result = await _client.mutate(
            MutationOptions(
              documentNode: gql(deletePerson(personId.text)),
            ),
          );
          if (!result.hasException) Navigator.of(context).pop();
        },
      );

  Widget get _addOrEditBtn => FlatButton(
      child: Text(this.isAdd ? "Add" : "Edit"),
      onPressed: () async {
        bool isNotEmpty = personId.text.isNotEmpty &&
            personName.text.isNotEmpty &&
            personAge.text.isNotEmpty;
        if (isNotEmpty) {
          this.isAdd ? await _handleAdd() : await _handleEdit();
        } else {
          // TODO: no empty fields warning
        }
      });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(this.isAdd ? "Add  Person" : "Edit or Delete Exist Person"),
      content: Container(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: Stack(
              children: <Widget>[
                Container(
                  child: TextField(
                    maxLength: 6,
                    controller: personId,
                    enabled: this.isAdd,
                    decoration: InputDecoration(
                      icon: Icon(Icons.perm_identity),
                      labelText: "ID",
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: TextField(
                    maxLength: 10,
                    controller: personName,
                    decoration: InputDecoration(
                      icon: Icon(Icons.text_format),
                      labelText: "Name",
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 160.0),
                  child: TextField(
                    maxLength: 2,
                    controller: personAge,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Age", icon: Icon(Icons.calendar_today)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Close"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        !this.isAdd ? _deleteBtn : null,
        _addOrEditBtn
      ],
    );
  }
}
