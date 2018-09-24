import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:stockapp/components/stock.dart';
import 'buy_widget.dart';
import 'package:stockapp/global.dart' as globals;

/// A widget that displays data for a stock
class StockWidget extends StatefulWidget {
  final Stock stock;

  StockWidget({this.stock});

  @override
  StockState createState() => new StockState();
}

/// Stores the State for the StockWidget
class StockState extends State<StockWidget> {
  Stock stock;

  /// Initializes the State of the Widget
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stock = widget.stock;
    updateData();
  }

  /// Updates the state of the stock
  void updateData() {
    setState(() {
      stock.updateData();
    });
  }

  /// Retrieves the data for the stock from the API framework
  Future<Stock> getData() async {
    final response = await http
        .get(globals.url + '/stock/${widget.stock.symbol}/batch?types=quote');

    if (response.statusCode == 200) {
      return Stock.fromJson(json.decode(response.body)['quote']);
    } else {
      throw Exception('Failed to retrive data');
    }
  }

  /// Displays a Dialog for buying a stock
  Future<Null> _buyMenu(double price) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Buy ${stock.symbol.toUpperCase()}'),
            children: <Widget>[
              Buy(price: price, symbol: widget.stock.symbol,)
            ],
          );
        });
  }

  /// Builds the widget
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Stock>(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Card(
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(snapshot.data.symbol.toUpperCase()),
                  Text(snapshot.data.name),
                  Text(globals.currencyFormatter
                      .format(snapshot.data.currentPrice))
                ],
              ),
              children: <Widget>[
                Text('Positions'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Shares: ${stock.numShares}'),
                      Text('Bought at: ' +
                          globals.currencyFormatter
                              .format(stock.numShares * stock.boughtPrice)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Average Cost: ' +
                          globals.currencyFormatter.format(stock.boughtPrice)),
                      Text('Current: ' +
                          globals.currencyFormatter.format(
                              stock.numShares * snapshot.data.currentPrice))
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {},
                      child: Text('SELL'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        _buyMenu(snapshot.data.currentPrice);
                      },
                      child: Text('BUY'),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(stock.symbol.toUpperCase()),
                Text(stock.name),
                Text(stock.currentPrice.toString())
              ],
            ),
          );
        }
      },
    );
  }
}
