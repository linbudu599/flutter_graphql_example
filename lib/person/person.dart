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

  void fillList() async {
    GraphQLClient _client = clientToQuery();
    QueryResult result = await _client.query(
      QueryOptions(
        documentNode: gql(getAll()),
      ),
    );

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
          title: Text("GraphQL & Flutter Example"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: () => _addPerson(context),
              tooltip: "Insert  person",
            ),
          ],
        ),
        body: Stack(children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Person List",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0),
                ),
              )),
          Container(
            child: ListView.builder(
                itemCount: listPerson?.length ?? 0,
                itemBuilder: (context, index) => ListTile(
                      selected: listPerson == null ? false : true,
                      title: Text(
                        "${listPerson[index].getName()}",
                      ),
                      onTap: () {
                        _editDeletePerson(context, listPerson[index]);
                      },
                    )),
          )
        ]));
  }
}
