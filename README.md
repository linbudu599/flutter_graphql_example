# Flutter-GraphQL-Example

Use GraphQL in Flutter Project. 💕

## Article

**WIP...**

## Notice

Creating [`/res/xml/network_security_config.xml`](android/app/src/main/res/xml/network_security_config.xml) And Editing [`AndroidManifest.xml`](android/app/src/profile/AndroidManifest.xml) to enable HTTP request in Emulator, otherwise you will got **'Insecure HTTP is not allowed by platform' error**. see [here](https://flutter.dev/docs/release/breaking-changes/network-policy-ios-android#migration-guide) for more details about.

## Usage

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

> Powered by [JSON-GraphQL-Server](https://github.com/marmelab/json-graphql-server).

### Client

```bash
dart pub get
flutter run .\lib\main.dart
```

> Powered by [GraphQL-Flutter](https://pub.dev/packages/graphql_flutter)