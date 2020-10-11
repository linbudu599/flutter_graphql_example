import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const String GRAPHQL_SERVER = "http://10.0.2.2:4000/graphql";

HttpLink httpLink = HttpLink(
  uri: GRAPHQL_SERVER,
);

ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
      link: httpLink,
      // cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
      cache: InMemoryCache()),
);

GraphQLClient clientCreator() => GraphQLClient(
      // cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
      cache: InMemoryCache(),
      link: httpLink,
    );

String getAll() {
  return """ 
     fragment PersonField on Person {
      id
      name
      age
    }
  
    query {
      persons: allPeople {
        ... PersonField
      }
    }
    """;
}

String addPerson(String id, String name, int age) {
  return """
      mutation {
          createPerson(id: "$id", name: "$name",  age: $age){
            id
            name
            age
          }
      }
    """;
}

String deletePerson(String id) {
  return """
      mutation {
        removePerson(id: "$id")
      } 
    """;
}

String editPerson(String id, String name, int age) {
  return """
      mutation {
          updatePerson (id: "$id", name: "$name", age: $age){
            id
            name
            age
          }
      }    
     """;
}
