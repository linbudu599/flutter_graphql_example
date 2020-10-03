import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import "./client.dart";

void main() {
  runApp(GraphQLToDoDemo());
}

class GraphQLToDoDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: "GraphQL ToDo List",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<String> handleCreate(BuildContext context, dynamic id) async {
    return showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => Mutation(
            options: MutationOptions(documentNode: gql(createToDoMutation)),
            builder: (RunMutation runMutation, QueryResult result) =>
                AlertDialog(
                  title: Text('Got an excellent idea?'),
                  content: Container(
                    height: 170,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                              labelText: "Title",
                              labelStyle: TextStyle(fontSize: 16),
                              hintText: "Make self better",
                              hintStyle: TextStyle(fontSize: 16),
                              errorText: result.hasException
                                  ? result.exception.toString()
                                  : null,
                            ),
                            controller: titleController,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                              labelText: "Description",
                              labelStyle: TextStyle(fontSize: 16),
                              hintText: "Learning & Loving",
                              hintStyle: TextStyle(fontSize: 16),
                              errorText: result.hasException
                                  ? result.exception.toString()
                                  : null,
                            ),
                            controller: descController,
                          ),
                        )
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          runMutation({
                            "id": id,
                            "title": titleController.text,
                            "description": descController.text
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Create",
                          style: TextStyle(fontSize: 16),
                        ))
                  ],
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
          documentNode: gql(
            getAllToDosQuery,
          ),
          variables: {},
          context: {},
        ),
        builder: (QueryResult result,
            {VoidCallback refetch, FetchMore fetchMore}) {
          return Scaffold(
            appBar: AppBar(
              title: Text("GraphQL ToDo List"),
            ),
            body: Center(
              child: result.hasException
                  ? Text(
                      result.exception.toString(),
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    )
                  : result.loading
                      ? CircularProgressIndicator()
                      : ToDoList(
                          list: result.data['allTodos'], onRefresh: refetch),
            ),
            floatingActionButton: FloatingActionButton(
              tooltip: "Create Next ToDo!",
              child: Icon(Icons.add),
              onPressed: () => (!result.hasException && !result.loading)
                  ? this.handleCreate(context, result.data['allTodos'].length)
                  : () {},
            ),
          );
        });
  }
}

class ToDoList extends StatelessWidget {
  final List<dynamic> list;
  final VoidCallback onRefresh;

  const ToDoList({Key key, @required this.list, @required this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Mutation(
        options: MutationOptions(
            documentNode: gql(updateToDoMutation),
            onCompleted: (data) {
              print("Mutation Completed");
            }),
        builder: (RunMutation runMutation, QueryResult result) =>
            ListView.builder(
              itemCount: this.list.length,
              itemBuilder: (BuildContext context, int idx) {
                final item = this.list[idx];
                return CheckboxListTile(
                    title: Text(item['title']) ?? "",
                    subtitle: Text(item['description']) ?? "",
                    value: item['accomplished'],
                    onChanged: (_) {
                      runMutation({
                        "id": idx + 1,
                        'accomplished': !item['accomplished']
                      });
                      print(
                          "Update Task [${item['title']}] Status to: ${item['accomplished'] ? 'Done' : 'ToDo'}");
                      onRefresh();
                    });
              },
            ));
  }
}
