import 'package:flutter/material.dart';

import 'package:stockapp/components/stock.dart';
import 'package:stockapp/widgets/stock_widget.dart';

class SearchView extends StatefulWidget {
  @override
  SearchState createState() => new SearchState();
}

class SearchState extends State<SearchView> {
  Stock stock;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        Text('Stock Look Up'),
        Container(
          width: MediaQuery.of(context).size.width * .95,
          child: Row(
            children: <Widget>[
              TextField(),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
              )
            ],
          ),
        ),
        stock == null ? CircularProgressIndicator() : StockWidget(stock, null),
      ],
    );
  }
}
