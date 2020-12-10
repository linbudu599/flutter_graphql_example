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
    query {
      Todos: allTodos{
        id
        title
        desc
        accomplished
      }
    }
    """;
}

String addTodo(String title, String desc) {
  return """
      mutation {
          createTodo(title: "$title", desc: "$desc"){
              id
              title
              desc
              accomplished
          }
      }
    """;
}

String updateTodo({
  @required int id,
  String title,
  String desc,
}) {
  return """
      mutation {
          updateTodo(id: $id, title: "$title", desc: "$desc"
          ){
              id
              title
              accomplished
          }
      }
    """;
}

String toggleStatus({@required int id}) {
  return """
      mutation {
          toggleTodoStatus(id: $id){
              id
              title
              accomplished
          }
      }
    """;
}

String deleteTodo(int id) {
  return """
      mutation {
        deleteTodo(id: $id)
      } 
    """;
}
