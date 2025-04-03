import 'package:flutter/material.dart';
import 'package:flutterapp/favourites.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async 
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

String? ActiveUser;

class MyApp extends StatelessWidget 
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      title: 'Flutter Sugar',
      theme: BuildTheme(),
      //default to login screen
      home: LoginScreen(),
    );
  }
}

// Global app theme
ThemeData BuildTheme() 
  {
    return ThemeData
    (
      appBarTheme: AppBarTheme
      (
        color: Colors.cyan,
        titleTextStyle: TextStyle
        (
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      buttonTheme: ButtonThemeData
      (
        buttonColor: Colors.cyan,
        shape: RoundedRectangleBorder
        (
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData
      (
        style: ElevatedButton.styleFrom
        (
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder
          (
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData
      (
        style: TextButton.styleFrom
        (
          foregroundColor: Colors.white,
          backgroundColor: Colors.cyan,
          
          textStyle: TextStyle(color: Colors.white,fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }  


class HomePage extends StatefulWidget 
{
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> 
{
  int SelectedIndex = 1; // Default to home page

  final List<Widget> Screens = //setting up screens navigatable by bottom bar
  [
    SearchScreen(),
    HomeScreen(),
    FavouritesScreen()
  ];

  void OnItemTapped(int Index) 
  {
    setState(() 
    {
      SelectedIndex = Index; //Set screen index based upon navigation bar presses
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
      body: Screens[SelectedIndex],
      bottomNavigationBar: BottomNavigationBar
      (
        currentIndex: SelectedIndex,
        onTap: OnItemTapped, //set the index on tap
        selectedItemColor: Colors.cyan,
        items: const <BottomNavigationBarItem>
        [
          BottomNavigationBarItem //Search screen button
          (
            icon: Icon(Icons.search),
            label: 'Search',
            backgroundColor: Colors.cyan,
          ),
          BottomNavigationBarItem //Home screen button
          (
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.cyan,
          ),
          BottomNavigationBarItem //Favourites screen button
          (
            icon: Icon(Icons.favorite),
            label: 'Favourites',
            backgroundColor: Colors.cyan,
          ),
        ],
      ),
    );
  }
}