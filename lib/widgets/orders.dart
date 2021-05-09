import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Orders extends StatefulWidget {
  Orders({Key key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
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
                  'Cant Find orders',
                  style: TextStyle(fontSize: 18),
                ),
              );

              // if we got our data
            } else if (snapshot.hasData) {
              // Extracting data from snapshot object
              final data = snapshot.data;
              if (snapshot.data.isEmpty) {
                return Text('No orders found');
              }
              return renderCard(data);
            }
          }

          // Displaying LoadingSpinner to indicate waiting state
          return Center(
            child: CircularProgressIndicator(),
          );
        },
        future: _loadOrders(),
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
    var item = jsonDecode(element);

    IconData icon = item['action'] == 'Buy'
        ? Icons.add_circle_outline_rounded
        : Icons.remove_circle_outline_rounded;
    return ListTile(
      leading: Icon(icon, size: 50),
      title: Text("${item['action']} - ${item['name']} (${item['exchange']})"),
      subtitle:
          Text("Quantity: ${item['quantity']} At Price: ${item['price']}"),
    );
  }

  Future<dynamic> _loadOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> orders = prefs.getStringList('ORDERS') ?? [];
    return orders;
  }
}
