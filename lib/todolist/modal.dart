import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import "client.dart";
import "model.dart";

class OperationModal extends StatefulWidget {
  final Todo todo;
  final bool isCreate;

  OperationModal({Key key, this.todo, @required this.isCreate})
      : super(key: key);

  @override
  OperationModalState createState() =>
      OperationModalState(this.todo, this.isCreate);
}

class OperationModalState extends State<OperationModal> {
  final Todo todo;
  final bool isCreate;

  OperationModalState(this.todo, this.isCreate);

  TextEditingController todoId = TextEditingController();
  TextEditingController todoTitle = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!this.isCreate) {
      todoId.text = todo.getId() ?? "";
      todoTitle.text = todo.getTitle() ?? "";
    }
  }

  Future<Null> _handleAdd() async {
    GraphQLClient _client = clientCreator();
    QueryResult result = await _client.mutate(
      MutationOptions(
        documentNode: gql(addTodo(
          todoId.text,
          todoTitle.text,
        )),
      ),
    );
    if (!result.hasException) {
      // TODO: extract to _clear method
      todoId.clear();
      todoTitle.clear();
      Navigator.of(context).pop();
    }
  }

  Future<Null> _handleEdit() async {
    GraphQLClient _client = clientCreator();
    QueryResult result = await _client.mutate(
      MutationOptions(
          documentNode: gql(
        updateTodo(
          id: todoId.text,
          title: todoTitle.text,
          accomplished: true,
        ),
      )),
    );
    if (!result.hasException) {
      todoId.clear();
      todoTitle.clear();
    }
    Navigator.of(context).pop();
  }

  Widget get _deleteBtn => FlatButton(
        child: Text(
          "Delete",
          style: TextStyle(
            color: Colors.redAccent,
          ),
        ),
        onPressed: () async {
          GraphQLClient _client = clientCreator();
          QueryResult result = await _client.mutate(
            MutationOptions(
              documentNode: gql(deleteTodo(todoId.text)),
            ),
          );
          print(result.data);
          print(result.exception);
          print(result.hasException);
          if (!result.hasException) Navigator.of(context).pop();
        },
      );

  Widget get _addOrEditBtn => FlatButton(
      child: Text(this.isCreate ? "Add" : "Edit"),
      onPressed: () async {
        bool isNotEmpty = todoId.text.isNotEmpty && todoTitle.text.isNotEmpty;
        if (isNotEmpty) {
          this.isCreate ? await _handleAdd() : await _handleEdit();
        } else {
          // TODO: no empty fields warning
        }
      });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(this.isCreate ? "Add Item" : "Edit or Delete Exist Item"),
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
                    maxLength: 3,
                    controller: todoId,
                    enabled: this.isCreate,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      icon: Icon(Icons.perm_identity),
                      labelText: "ID",
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: TextField(
                    maxLength: 50,
                    controller: todoTitle,
                    decoration: InputDecoration(
                      icon: Icon(Icons.text_format),
                      labelText: "Title",
                    ),
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
        !this.isCreate ? _deleteBtn : null,
        _addOrEditBtn
      ],
    );
  }
}
