import 'package:flutter/material.dart';
import '../widgets/market_watch.dart';
import '../widgets/dashboard.dart';
import '../widgets/orders.dart';
import '../widgets/profile.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = '/home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _currentIndex = 0;
  final List<Widget> _children = [Dashboard(), Orders(), Profile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text("Market Watch"),
          MarketWatchWidget(),
          _children[_currentIndex]
        ],
      )),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Orders',
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile')
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
