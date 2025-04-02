import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'product_info_screen.dart';

void main() 
{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget 
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: 'Flutter Sugar',
      initialRoute: '/',
      routes: 
      {
        '/': (context) => const MyHomePage(),
        '/productInfo': (context) => const ProductInfoScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget 
{
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> 
{
  int _selectedIndex = 0; // Default to Home screen

  final List<Widget> _screens = 
  [
    const HomeScreen(),
    SearchScreen(),
  ];

  void _onItemTapped(int index) 
  {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text('Flutter Sugar'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar
      (
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>
        [
          BottomNavigationBarItem
          (
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem
          (
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}