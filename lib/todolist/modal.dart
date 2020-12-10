import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import "client.dart";
import "model.dart";

class OperationModal extends StatefulWidget {
  final Todo todo;
  final bool isCreate;

  OperationModal({
    Key key,
    this.todo,
    @required this.isCreate,
  }) : super(key: key);

  @override
  OperationModalState createState() =>
      OperationModalState(this.todo, this.isCreate);
}

class OperationModalState extends State<OperationModal> {
  final Todo todo;
  final bool isCreate;

  OperationModalState(this.todo, this.isCreate);

  TextEditingController todoTitle = TextEditingController();
  TextEditingController todoDesc = TextEditingController();

  @override
  void initState() {
    super.initState();
    print(isCreate);
    if (!this.isCreate) {
      todoTitle.text = todo.getTitle() ?? "";
      todoDesc.text = todo.getDesc() ?? "";
    }
  }

  Future<Null> _handleAdd() async {
    GraphQLClient _client = clientCreator();
    QueryResult result = await _client.mutate(
      MutationOptions(
        documentNode: gql(addTodo(todoTitle.text, todoDesc.text)),
      ),
    );
    if (!result.hasException) {
      todoTitle.clear();
      todoDesc.clear();
      Navigator.of(context).pop();
    }
  }

  Future<Null> _handleEdit() async {
    GraphQLClient _client = clientCreator();
    QueryResult result = await _client.mutate(
      MutationOptions(
          documentNode: gql(
        updateTodo(
            id: this.todo.id, title: todoTitle.text, desc: todoDesc.text),
      )),
    );
    if (!result.hasException) {
      todoTitle.clear();
      todoDesc.clear();
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
          QueryResult result = await _client.mutate(MutationOptions(
            documentNode: gql(
              deleteTodo(this.todo.id),
            ),
          ));

          if (!result.hasException && result.data.deleteTodo)
            Navigator.of(context).pop();
        },
      );

  Widget get _addOrEditBtn => FlatButton(
      child: Text(this.isCreate ? "Add" : "Edit"),
      onPressed: () async {
        bool isNotEmpty = todoTitle.text.isNotEmpty && todoDesc.text.isNotEmpty;
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
                    maxLength: 10,
                    controller: todoTitle,
                    decoration: InputDecoration(
                      icon: Icon(Icons.text_format),
                      labelText: "Title",
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: TextField(
                    maxLength: 20,
                    controller: todoDesc,
                    decoration: InputDecoration(
                      icon: Icon(Icons.note_add),
                      labelText: "Desc",
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
