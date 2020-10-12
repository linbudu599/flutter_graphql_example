import 'package:flutter/material.dart';
import "todolist/todolist.dart";
import "person/person.dart";

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int _idx = 0;

  PageController _controller = PageController(initialPage: 0, keepPage: true);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: PageView(
          controller: _controller,
          children: <Widget>[ToDoApp(), PersonApp()],
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _idx,
            onTap: (int i) {
              _controller.jumpToPage(i);
              setState(() {
                _idx = i;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: [
              _buildItem(Icons.notes, "ToDo List"),
              _buildItem(Icons.person_pin, "Person Admin"),
            ]),
      ),
    );
  }

  BottomNavigationBarItem _buildItem(
    IconData defaultIcon,
    String title,
  ) {
    return BottomNavigationBarItem(
        icon: Icon(defaultIcon, color: Colors.grey, size: 28.0),
        activeIcon: Icon(defaultIcon, color: Colors.blue),
        label: title ?? "");
  }
}
