import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const String GRAPHQL_SERVER = "http://10.0.2.2:4000/graphql";

HttpLink httpLink = HttpLink(
  uri: GRAPHQL_SERVER,
);

ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(link: httpLink, cache: InMemoryCache()),
);

GraphQLClient clientCreator() => GraphQLClient(
      cache: InMemoryCache(),
      link: httpLink,
    );

String getAllTodos() {
  return """ 
    fragment TodoFields on Todo {
      id
      title
      accomplished
    }
  
    query {
      Todos: allTodos{
        ... TodoFields
      }
    }
    """;
}

String addTodo(String id, String title) {
  return """
      mutation {
          createTodo(id: "$id", title: "$title", 
            accomplished: false){
              id
              title
              accomplished
          }
      }
    """;
}

String deleteTodo(String id) {
  return """
      mutation {
        removeTodo(id: "$id")
      } 
    """;
}

String updateTodo({@required String id, String title, bool accomplished}) {
  return """
      mutation {
          createTodo(id: "$id", title: "$title",
            accomplished: $accomplished){
              id
              title
              accomplished
          }
      }
    """;
}
