import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketWatchWidget extends StatefulWidget {
  MarketWatchWidget({Key key}) : super(key: key);

  @override
  _MarketWatchWidgetState createState() => _MarketWatchWidgetState();
}

class _MarketWatchWidgetState extends State<MarketWatchWidget> {
  var jsonResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadJson();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        builder: (ctx, snapshot) {
          // Checking if future is resolved or not
          if (snapshot.connectionState == ConnectionState.done) {
            // If we got an error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Cant load file',
                  style: TextStyle(fontSize: 18),
                ),
              );

              // if we got our data
            } else if (snapshot.hasData) {
              // Extracting data from snapshot object
              final data = snapshot.data;
              return renderCard(data['stocks']);
            }
          }

          // Displaying LoadingSpinner to indicate waiting state
          return Center(
            child: CircularProgressIndicator(),
          );
        },
        future: _loadJson(),
      ),
    );
  }

  Widget renderCard(data) {
    return Container(
      height: MediaQuery.of(context).size.height / 2 - 100,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
      child: SingleChildScrollView(
        child: Column(
          children: data.map<Widget>((ele) => stockRow(ele)).toList(),
        ),
      ),
    );
  }

  Widget stockRow(element) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(element['name']),
        Text(element['current_price'].toString()),
        InputChip(
          onPressed: () {
            showModel('Buy', element);
          },
          label: Text('Buy'),
        ),
        InputChip(
          onPressed: () {
            showModel('Sell', element);
          },
          label: Text('Sell'),
        )
      ],
    );
  }

  Future<dynamic> _loadJson() async {
    String data = await rootBundle.loadString('assets/data/marketwatch.json');
    jsonResult = json.decode(data);
    return jsonResult;
  }

  void showModel(action, element) {
    var price = element['current_price'].toString();

    TextEditingController _textFieldControllerPrice =
        TextEditingController(text: price);
    TextEditingController _textFieldControllerQuantity =
        TextEditingController(text: '1');
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: 200,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price: '),
                    TextField(
                      controller: _textFieldControllerPrice,
                      decoration: InputDecoration(hintText: 'Price:'),
                    ),
                    Text('Quantity: '),
                    TextField(
                      controller: _textFieldControllerQuantity,
                      decoration: InputDecoration(hintText: 'Quantity:'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RaisedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            updateLocalStorage(
                                element,
                                action,
                                _textFieldControllerPrice.text,
                                _textFieldControllerQuantity.text);
                          },
                          child: Text(
                            action,
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blue[400],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> updateLocalStorage(stockElement, action, price, quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> orders = prefs.getStringList('ORDERS') ?? [];

    orders.add(orderStringify(stockElement, action, price, quantity));

    prefs.setStringList('ORDERS', orders);
  }

  String orderStringify(stockElement, action, price, quantity) {
    return ('{"name": "${stockElement['name']}", "exchange": "${stockElement['exchange']}", "action" : "$action", "price": "$price", "quantity": "$quantity"}');
  }
}
