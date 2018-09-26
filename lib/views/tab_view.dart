import 'package:flutter/material.dart';

import 'home_view.dart';
import 'search_view.dart';

class TabView extends StatefulWidget {
  @override
  TabState createState() => new TabState();
}

class TabState extends State<TabView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Your Portfolio'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {},
            )
          ],
          bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.home),),
              Tab(icon: Icon(Icons.search),),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            HomeView(),
            TabView(),
          ],
        ),
      ),
    );
  }
}
