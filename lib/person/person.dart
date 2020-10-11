import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import "client.dart";
import "modal.dart";
import "model.dart";

class PersonPage extends StatelessWidget {
  const PersonPage({Key key}) : super(key: key);

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
  List<Person> listPerson = List<Person>();
  bool _loading = true;

  void fillList() async {
    GraphQLClient _client = clientCreator();
    QueryResult result = await _client.query(
      QueryOptions(
        documentNode: gql(getAll()),
      ),
    );

    setState(() {
      _loading = false;
    });

    if (!result.hasException) {
      for (int i = 0; i < result.data["persons"].length; i++) {
        setState(() {
          listPerson.add(
            Person(
              id: result.data["persons"][i]["id"],
              name: result.data["persons"][i]["name"],
              age: result.data["persons"][i]["age"],
            ),
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

  void _addPerson(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => OperationModal(isAdd: true),
    ).whenComplete(() {
      listPerson.clear();
      fillList();
    });
  }

  void _editDeletePerson(context, Person person) {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          OperationModal(isAdd: false, person: person),
    ).whenComplete(() {
      listPerson.clear();
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
          title: Text("GraphQL Person Admin",
              textAlign: TextAlign.center, style: TextStyle(fontSize: 24)),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, size: 28),
          onPressed: () => _addPerson(context),
          tooltip: "Create Person",
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
                            "Person Admin",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 30.0, color: Colors.black54),
                          ),
                        )),
                    Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: listPerson.length ?? 0,
                          itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(left: 22),
                                child: ListTile(
                                  leading: Icon(Icons.person),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  title: Text(
                                    "${listPerson[index].getName()}",
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 22,
                                        letterSpacing: 1.4,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  onTap: () {
                                    _editDeletePerson(
                                        context, listPerson[index]);
                                  },
                                ),
                              )),
                    )
                  ])));
  }
}
