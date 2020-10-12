# Flutter-GraphQL-Example

A simple demo shows basic usage of combination of `Flutter` & `GraphQL`.

## Article

**[WIP]** [在Flutter中使用GraphQL的初体验](./docs/README.md)

## Notice

Creating [`/res/xml/network_security_config.xml`](android/app/src/main/res/xml/network_security_config.xml) And Editing [`AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml) to enable HTTP request in Emulator, otherwise you will got **'Insecure HTTP is not allowed by platform' error**. see [here](https://flutter.dev/docs/release/breaking-changes/network-policy-ios-android#migration-guide) for more details about.

```xml
<!-- network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true" />
</network-security-config>

<!-- AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.flutter_graphql_example">
   <application
        android:networkSecurityConfig="@xml/network_security_config">
    <!-- ... -->
    </application>
</manifest>

```

## Prerequisites

**Make sure you've already installed required environment including:**

- `NodeJS` & `NPM` / `Yarn`
- `Flutter` & `Dart`
- `Android Studio` & `Android/IOS Emulator`

## Usage

Two kinds usage of `graphql_flutter` package are included:

- **Imperative Usage**: [Person Admin](lib/person/person.dart)
- **Declarative Usage**: [ToDo List](lib/todolist/todolist.dart)

```bash
git clone git@github.com:linbudu599/flutter_graphql_example.git

cd flutter_graphql_example
```

### Server

```bash
cd ./server

npm install

# both 2 servers will start
npm run dev
```

> Powered by [JSON-GraphQL-Server](https://github.com/marmelab/json-graphql-server).

As server gets ready, you can use visit

- [http://localhost:1111/graphql](http://localhost:1111/graphql)  (ToDo List)
- [http://localhost:4000/graphql](http://localhost:4000/graphql)  (Person Admin)

to check your **GraphQL Server** easily by [**GraphIQL**](https://github.com/graphql/graphiql), which contains definition of `Query` / `Mutation` info.

### Client

```bash
dart pub get
flutter run .\lib\main.dart
```

> Powered by [GraphQL-Flutter](https://pub.dev/packages/graphql_flutter)

