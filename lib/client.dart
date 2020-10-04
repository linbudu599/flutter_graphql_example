import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// or use a clientCreator function to create ClientProvider dynamically
ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
    cache: InMemoryCache(),
    link: HttpLink(
        uri: 'http://10.0.2.2:1111/graphql',
        // useGETForQueries: true,
        includeExtensions: false,
        headers: {"authorization": "xxx"}),
  ),
);

final String getAllToDosQuery = """
query {
  allTodos {
    id,
    title,
    description,
    accomplished
  }
}
""";

final String createToDoMutation = """
mutation CreateTodo(\$id: ID!, \$title: String!, \$description: String!) {
  createTodo(id: \$id, title: \$title, description: \$description, accomplished: false) {
    id
  }
}
""";

final String updateToDoMutation = """
mutation UpdateTodo(\$id: ID!, \$accomplished: Boolean!) {
  updateTodo(id: \$id, accomplished: \$accomplished) {
    id
  }
}
""";

final String removeTodoMutation = """
mutation RemoveTodo(\$id: ID!){
  removeTodo(id: \$id)
}
""";
