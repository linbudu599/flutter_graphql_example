import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

/* TODO:
 * 1. Local Server
 * 2. Split Widget / Method
 * 3. Cache Control Differences
 * 4. Boundary Handle
 */

const String GRAPHQL_SERVER = "https://examplegraphql.herokuapp.com/graphql";

HttpLink httpLink = HttpLink(
  uri: GRAPHQL_SERVER,
);

ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
      link: httpLink,
      // cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
      cache: InMemoryCache()),
);

GraphQLClient clientToQuery() {
  return GraphQLClient(
    // cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
    cache: InMemoryCache(),
    link: httpLink,
  );
}

class Person {
  const Person({@required this.id, @required this.name, @required this.age});

  final String id;
  final String name;
  final int age;

  String getId() => this.id;
  String getName() => this.name;
  int getAge() => this.age;
}

String addPerson(String id, String name, int age) {
  return """
      mutation {
          addPerson(id: "$id", name: "$name",  age: $age){
            id
            name
            age
          }
      }
    """;
}

String getAll() {
  return """ 
      query {
        persons {
          id
          name
          age
        }
      }
    """;
}

String deletePerson(id) {
  return """
      mutation {
        deletePerson(id: "$id"){
          id
        }
      } 
    """;
}

String editPerson(String id, String name, int age) {
  return """
      mutation{
          editPerson(id: "$id", name: "$name", age: $age){
            name
          }
      }    
     """;
}

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
    print(result.exception);
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
          // TODO: Invalid Dialog
        }
      });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(this.isAdd ? "Add New Person" : "Edit or Delete Exist Person"),
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

class Principal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Principal();
}

class _Principal extends State<Principal> {
  List<Person> listPerson = List<Person>();

  void fillList() async {
    GraphQLClient _client = clientToQuery();
    QueryResult result = await _client.query(
      QueryOptions(
        documentNode: gql(getAll()),
      ),
    );

    if (!result.hasException) {
      for (var i = 0; i < result.data["persons"].length; i++) {
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
              tooltip: "Insert new person",
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
        home: Principal(),
      ),
    );
  }
}
