import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stockapp/global.dart' as globals;

class Buy extends StatefulWidget {
  double price;
  String symbol;

  Buy(this.price, this.symbol, this.callback);

  Function(int, double) callback;

  @override
  BuyState createState() => new BuyState();
}

class BuyState extends State<Buy> {
  TextEditingController sharesController = new TextEditingController(text: '0');
  TextEditingController totalController =
      new TextEditingController(text: '0.0');

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  int numShares = 0;
  double calcCost = 0.0;

  /// Validates the number of shares entered
  String _validateShares(String value) {
    int num = int.parse(value);
    if (num < 0) {
      return 'You cannot buy neggative shares';
    } else if (num == 0) {
      return 'The number of shares should be greater than 0';
    } else {
      return null;
    }
  }

  String _validateCost(String cost){
    double predicted = numShares * widget.price;

    print('$predicted : ${globals.looseCash}');

    if(globals.looseCash < predicted){
      return ('Not enough capital');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('# of shares: '),
                Container(
                  width: 150.0,
                  child: TextFormField(
                    initialValue: '0',
                    validator: _validateShares,
                    onFieldSubmitted: (String count) {
                      setState(() {
                        this.numShares = int.parse(count);
                        print('number of shares: $numShares');
                        this.calcCost = numShares * widget.price;
                        print('cost of shares: $calcCost');
                        totalController.text = globals.currencyFormatter
                            .format(calcCost);
                      });
                      FormState().validate();
                    },
                    keyboardType: TextInputType.phone,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Price: '),
                Container(
                  width: 150.0,
                  child: TextField(
                    enabled: false,
                    controller: TextEditingController(
                        text: globals.currencyFormatter.format(widget.price)),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Total: '),
                Container(
                  width: 150.0,
                  child: TextFormField(
                    enabled: true,
                    controller: totalController,
                    autovalidate: true,
                    validator: _validateCost,
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              RaisedButton(
                onPressed: () {
                  bool good = true;
                  if(good){
                    Map<String, dynamic> data = globals.data;


                    double price;
                    int shares;
                    double cost;

                    if(data['positions'].containsKey(widget.symbol)){
                      price = data['positions'][widget.symbol]['price'];
                      shares = data['positions'][widget.symbol]['shares'];
                      cost = price * shares;
                      print('pre add shares: $shares');

                      shares += numShares;
                      print('post add shares: $shares');

                      cost += calcCost;
                    } else{
                      shares = numShares;
                      cost = calcCost;
                    }
                    print(shares);
                    print(cost);
                    print(cost / shares);
                    price = cost / shares;


                    Map<String, dynamic> map = {'price': price, 'shares': shares};
                    globals.data['positions'][widget.symbol] = map;
                    globals.data['looseCash'] = globals.looseCash - calcCost;

//                    data.update(widget.symbol, map);

                    Firestore.instance.runTransaction((Transaction tx) async {
                      CollectionReference reference =
                      Firestore.instance.collection(globals.uid);
                      await reference.document(globals.docId).updateData(globals.data);
                    });
                    widget.callback(shares, price);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
