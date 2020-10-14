import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import "client.dart";

class ToDoApp extends StatelessWidget {
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

  bool _isSaving = true;

  @override
  void initState() {
    super.initState();
  }

  Future<String> handleCreate(
      BuildContext context, dynamic id, Refetch refetch) async {
    return showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => Mutation(
            options: MutationOptions(
                documentNode: gql(createToDoMutation),
                onCompleted: (_) {
                  setState(() {
                    _isSaving = false;
                  });
                  Navigator.of(context).pop();
                }),
            builder: (RunMutation runMutation, QueryResult createResult) =>
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
                              labelText: "ToDo Title",
                              labelStyle: TextStyle(fontSize: 18),
                              hintText: "Make self better",
                              hintStyle: TextStyle(fontSize: 16),
                              errorText: createResult.hasException
                                  ? createResult.exception.toString()
                                  : null,
                            ),
                            controller: titleController,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: "ToDo Description",
                              labelStyle: TextStyle(fontSize: 18),
                              hintText: "Learning & Loving",
                              hintStyle: TextStyle(fontSize: 16),
                              errorText: createResult.hasException
                                  ? createResult.exception.toString()
                                  : null,
                            ),
                            controller: descController,
                          ),
                        )
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    _isSaving
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          )
                        : FlatButton(
                            onPressed: () async {
                              setState(() {
                                _isSaving = true;
                              });
                              runMutation({
                                "id": id + 1,
                                "title": titleController.text,
                                "description": descController.text
                              });
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
            pollInterval: 1),
        builder: (QueryResult queryResult,
            {Refetch refetch, FetchMore fetchMore}) {
          return Scaffold(
            appBar: AppBar(
              leading: Icon(
                Icons.notes,
                size: 34,
              ),
              title: Text("GraphQL ToDo List",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 24)),
              centerTitle: true,
            ),
            body: Center(
              child: Container(
                padding: EdgeInsets.only(top: 6),
                child: queryResult.hasException
                    ? Text(
                        queryResult.exception.toString(),
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      )
                    : queryResult.loading
                        ? CircularProgressIndicator()
                        : ToDoList(
                            list: queryResult.data['allTodos'],
                            onRefresh: refetch),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              tooltip: "Create Next ToDo!",
              child: Icon(
                Icons.add,
                size: 28,
              ),
              onPressed: () =>
                  (!queryResult.hasException && !queryResult.loading)
                      ? this.handleCreate(
                          context, queryResult.data['allTodos'].length, refetch)
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
        builder: (RunMutation runMutation, QueryResult updateResult) =>
            SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: ListView.builder(
                  itemCount: this.list.length,
                  itemBuilder: (BuildContext context, int idx) {
                    final item = this.list[idx];
                    return Container(
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 3, color: Colors.lightBlue)),
                        ),
                        child: CheckboxListTile(
                            contentPadding:
                                const EdgeInsets.fromLTRB(2, 0, 5, 2),
                            title: _title(text: item['title']),
                            subtitle: _subtitle(text: item['description']),
                            value: item['accomplished'],
                            secondary: Mutation(
                              options: MutationOptions(
                                  documentNode: gql(removeTodoMutation)),
                              builder: (RunMutation runMutation,
                                      QueryResult result) =>
                                  IconButton(
                                iconSize: 22,
                                splashRadius: 18.0,
                                padding: const EdgeInsets.all(0.0),
                                icon: Icon(
                                  Icons.remove_circle,
                                  size: 28,
                                  color: Colors.redAccent,
                                ),
                                tooltip: 'Delete this item',
                                onPressed: () {
                                  runMutation({"id": item['id']});
                                },
                              ),
                            ),
                            tristate: true,
                            onChanged: (_) {
                              runMutation({
                                "id": idx + 1,
                                'accomplished': !item['accomplished']
                              });
                              print(
                                  "Update Task [${item['title']}] Status to: ${item['accomplished'] ? 'Done' : 'ToDo'}");
                              // onRefresh();
                            }));
                  },
                )));
  }

  Widget _title({String text = ""}) =>
      Text(text, style: TextStyle(fontSize: 22, color: Colors.blue));

  Widget _subtitle({String text = ""}) => Padding(
      child: Text(text, style: TextStyle(fontSize: 16, color: Colors.black54)),
      padding: EdgeInsets.only(top: 8));
}
