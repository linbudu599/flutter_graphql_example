import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const String GRAPHQL_SERVER = "http://10.0.2.2:1111/graphql";

HttpLink httpLink = HttpLink(
    uri: GRAPHQL_SERVER,
    // useGETForQueries: true,
    includeExtensions: false,
    headers: {"authorization": "xxx"});

Cache cache = InMemoryCache();

ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
    cache: cache,
    link: httpLink,
  ),
);

// or use a clientCreator function to create ClientProvider dynamically
// like this
GraphQLClient clientCreator() => GraphQLClient(
      cache: cache,
      link: httpLink,
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
