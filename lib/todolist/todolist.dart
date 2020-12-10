import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'client.dart';
import 'modal.dart';
import 'model.dart';

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Main(),
      ),
    );
  }
}

class Main extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Main();
}

class _Main extends State<Main> {
  List<Todo> listTodo = List<Todo>();
  bool _loading = true;

  void fillList() async {
    GraphQLClient _client = clientCreator();
    QueryResult result = await _client.query(
      QueryOptions(
        documentNode: gql(getAllTodos()),
      ),
    );

    print(result.data);

    setState(() {
      _loading = false;
    });

    if (!result.hasException) {
      for (int i = 0; i < result.data["Todos"].length; i++) {
        setState(() {
          listTodo.add(
            Todo(
                id: result.data["Todos"][i]["id"],
                desc: result.data["Todos"][i]["desc"],
                title: result.data["Todos"][i]["title"],
                accomplished: result.data["Todos"][i]["accomplished"]),
          );
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fillList();
  }

  void _addTodo(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => OperationModal(isCreate: true),
    ).whenComplete(() {
      listTodo.clear();
      fillList();
    });
  }

  void _editDeleteTodo(context, Todo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          OperationModal(isCreate: false, todo: todo),
    ).whenComplete(() {
      listTodo.clear();
      fillList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Icon(
            Icons.notes,
            size: 34,
          ),
          title: Text("GraphQL Todo List",
              textAlign: TextAlign.center, style: TextStyle(fontSize: 24)),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, size: 28),
          onPressed: () => _addTodo(context),
          tooltip: "Create Todo",
        ),
        body: Center(
            child: _loading
                ? CircularProgressIndicator()
                : Column(children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "Todo List",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 30.0, color: Colors.black54),
                          ),
                        )),
                    Container(
                        child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: listTodo.length ?? 0,
                                itemBuilder: (context, index) => Container(
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.only(left: 22),
                                        leading: Icon(Icons.person),
                                        title: Text(
                                          "${listTodo[index].getTitle()}",
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 18,
                                              letterSpacing: 1.2,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        subtitle: Text(
                                            '${listTodo[index].getDesc()}'),
                                        onTap: () {
                                          _editDeleteTodo(
                                              context, listTodo[index]);
                                        },
                                      ),
                                    )))),
                  ])));
  }
}
