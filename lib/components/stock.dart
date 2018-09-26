import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:stockapp/global.dart' as globals;

/// Holds information about a stock
class Stock{
  String name  = '';
  String symbol;
  double currentPrice;
  double boughtPrice = 0.00;
  int numShares;

  Stock({this.name: '', this.symbol, this.currentPrice: 0.0, this.boughtPrice, this.numShares});

  /// Creates a stock from a JSON map
  factory Stock.fromJson(Map<String, dynamic> map){
    return Stock(name: map['companyName'], symbol: map['symbol'], currentPrice: map['latestPrice']);
  }

  /// Gets the difference between the current price and the bought price
  double getChange(){
    if(currentPrice >= boughtPrice){
      return currentPrice / boughtPrice;
    }

    return -1 * currentPrice / boughtPrice;
  }

  /// Updates the saved data with info from the api
  Future<Stock> updateData() async {
    http.get(globals.url + '/stock/$symbol/batch?types=quote')
        .then((response){
          var body = json.decode(response.body)['quote'];
          name = body['companyName'];
          currentPrice = body['latestPrice'];
    });
    return this;
  }
  
}