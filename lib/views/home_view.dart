import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:stockapp/components/stock.dart';
import 'package:stockapp/widgets/stock_widget.dart';
import 'package:stockapp/global.dart' as globals;



class HomeView extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<HomeView> {
  FirebaseUser user;
  List<Widget> pos;

  @override
  void initState() {
    super.initState();
    user = globals.user;
  }

  callback(invalid) {
    setState(() {
      pos.remove(invalid);
    });
  }

  List<Widget> getPositions(DocumentSnapshot doc) {
    List<Stock> stocks = new List<Stock>();
    Map<dynamic, dynamic> positions = doc.data['positions'];

    positions.forEach((symbol, map) {
      Stock stock = new Stock(symbol: symbol, numShares: map['shares'], boughtPrice: map['price'] + .0);
      stocks.add(stock);
    });
    pos = new List<Widget>();
    stocks.forEach((Stock stock) {
      pos.add(StockWidget(stock, callback));
    });
    return pos;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Portfolio'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: Firestore.instance.collection(user.uid).snapshots,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data.documents.isEmpty) {
                  Map<String, dynamic> data = {
                    'positions': {},
                    'startingCash': 25000,
                    'currentCash': 25000,
                    'looseCash': 25000
                  };
                  Firestore.instance.runTransaction((Transaction tx) async {
                    CollectionReference reference =
                        Firestore.instance.collection(globals.uid);
                    await reference.add(data);
                  });
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                double currentCash = snapshot.data.documents.first.data['currentCash'] + .00;
                double startingCash = snapshot.data.documents.first.data['startingCash'] + .00;
                globals.looseCash = snapshot.data.documents.first.data['looseCash'] + .00;
                globals.docId = snapshot.data.documents.first.documentID;
                globals.data = snapshot.data.documents.first.data;

                return Flexible(
                  child: Center(
                    child: Container(
//                        height: MediaQuery.of(context).size.height * .95,
                      width: MediaQuery.of(context).size.width * .95,
                      child: ListView(
                        children: <Widget>[
                          Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 0.0, 8.0, 0.0),
                                  child: Text(
                                    globals.currencyFormatter.format(currentCash),
                                    style: TextStyle(fontSize: 64.0),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(
                                      ((currentCash - startingCash) / startingCash).toString() + '%',
                                      style: TextStyle(fontSize: 24.0),
                                    ),
                                    Text(
                                      '\$${currentCash - startingCash}',
                                      style: TextStyle(fontSize: 24.0),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Center(
                            child: Text(
                              'Your Positions',
                              style: TextStyle(fontSize: 32.0),
                            ),
                          ),
                          Container(
                            child: Column(
                              children:
                                  getPositions(snapshot.data.documents.first),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
