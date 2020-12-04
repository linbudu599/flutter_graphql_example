# Flutter-GraphQL-Example

A simple demo shows basic usage of combination of `Flutter` & `GraphQL`.

## Article

**[WIP]** [在Flutter中使用GraphQL](./docs/README.md)

## Notice

To solve **'Insecure HTTP is not allowed by platform' Error**, You will need to do these things:

For Android:

- Create [`/res/xml/network_security_config.xml`](android/app/src/main/res/xml/network_security_config.xml).
- Edit [`AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml).

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

For IOS:

- Add [NSExceptionDomains( NSExceptionAllowsInsecureHTTPLoads )](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity/nsexceptiondomains) to `Info.plist` in `/ios/Runner/Info.plist` folder.

Above actions are required so that we can use **HTTP instead of HTTPS** request in Emulator Device, see [here](https://flutter.dev/docs/release/breaking-changes/network-policy-ios-android#migration-guide) for more details about.

## Prerequisites

**Make sure you've already finished required environment setup,  including:**

- `nodejs` & `npm` / `yarn`
- `flutter` & `dart`
- `Android Studio` & `Android/IOS Emulator`

## Usage

- **Declarative Usage**: [ToDo List](lib/todolist/todolist.dart)

```bash
git clone git@github.com:linbudu599/flutter_graphql_example.git

cd flutter_graphql_example
```

### Server

```bash
cd ./server

npm install

npm run dev
```

> Powered by [json-graphql-server](https://github.com/marmelab/json-graphql-server).  
> 
> Edit [todo.ts](./server/todo.ts) to use the content you like.

As server gets ready, you can visit

- [http://localhost:1111/graphql](http://localhost:1111/graphql)

to check your **GraphQL Server** easily by [**GraphiQL**](https://github.com/graphql/graphiql), which contains definition of `Query` / `Mutation` info.

### Client

```bash
dart pub get
flutter run .\lib\main.dart
```

> Powered by [graphql-flutter package](https://pub.dev/packages/graphql_flutter)

