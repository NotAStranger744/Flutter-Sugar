import 'package:flutter/material.dart';
import 'package:flutterapp/diet_log.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget
{
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}
String FatGoal = "0"; 
String SugarGoal = "0"; 
String CalorieGoal = "0"; 

class HomeScreenState extends State<HomeScreen>
{


  double FatConsumed = 0; 
  double SugarConsumed = 0;
  double CalorieConsumed = 0;

  bool IsLoading = true;

  @override
  void initState() 
  {
    super.initState();
    LoadDietLog();
    LoadUserPrefs();
  }
  
  Future<void> LoadUserPrefs() async 
  {
    FirebaseFirestore Firestore = FirebaseFirestore.instance;

    DocumentSnapshot UserDoc = await Firestore.collection('users').doc(ActiveUser).get();

    if (UserDoc.exists) 
    {
      var data = UserDoc.data() as Map<String, dynamic>;

      setState(() //Updates UI automatically
      {
        CalorieGoal = (data['CalorieGoal'] ?? 2000).toString();
        FatGoal = (data['FatGoal'] ?? 70).toString();
        SugarGoal = (data['SugarGoal'] ?? 50).toString();
      });
    }
  }

  Future<void> LoadDietLog() async 
  {
    FirebaseFirestore Firestore = FirebaseFirestore.instance;
    DateTime TimeNow = DateTime.now();
    DateTime StartOfDay = DateTime(TimeNow.year, TimeNow.month, TimeNow.day, 0, 0, 0); // Midnight

    // Query for items added today
    QuerySnapshot Query = await Firestore
    .collection("users")
    .doc(ActiveUser)
    .collection("dietlog")
    .where("timestamp", isGreaterThanOrEqualTo: StartOfDay)
    .get();

    double totalFat = 0;
    double totalSugar = 0;
    double totalCalories = 0;

    for (var doc in Query.docs) 
    {
      var data = doc.data() as Map<String, dynamic>;

      totalFat += double.tryParse(data["fat"]?.toString() ?? "0") ?? 0;
      totalSugar += double.tryParse(data["sugar"]?.toString() ?? "0") ?? 0;
      totalCalories += double.tryParse(data["energy"]?.toString() ?? "0") ?? 0;
    }

    setState(() 
    {
      FatConsumed = totalFat;
      SugarConsumed = totalSugar;
      CalorieConsumed = totalCalories;
      IsLoading = false;
    });
  }

  void RefreshDietLog() 
  {
    LoadDietLog();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      body: Padding
      (
        padding: const EdgeInsets.all(0),
        child: Column
        (
          mainAxisAlignment: MainAxisAlignment.start,
          children: 
          [
            Text //Welcome text
            (
              "Hello, $ActiveUser",
              style: TextStyle
              (
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            // Title text at the top
            Text
            (
              "Your Daily Summary",
              style: TextStyle
              (
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30), // Space between the title and the wheels
            // Large Calorie Wheel at the Top
            BuildProgressWheel("Calories", CalorieConsumed, double.parse(CalorieGoal), "kcal", size: 200),

            SizedBox(height: 30),

            // Row with Fat and Sugar Wheels Below
            Row
            (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: 
              [
                BuildProgressWheel("Fat", FatConsumed, double.parse(FatGoal), "g", size: 150),
                BuildProgressWheel("Sugar", SugarConsumed, double.parse(SugarGoal), "g", size: 150),
              ],
            ),

            SizedBox(height: 30),
            // Button to view the daily diet products
            ElevatedButton
            (
              onPressed: () 
              {
                //Navigate to the Daily Diet screen
                Navigator.push
                (
                  context,
                  MaterialPageRoute(builder: (context) => DietLogScreen(RefreshDietLog: RefreshDietLog)),
                );
              },
              child: Text("Edit Today's Diet", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom
              (
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget BuildProgressWheel(String label, double consumed, double goal, String unit, {double size = 100}) 
  {
    double progress = consumed / goal; // Normalize to a scale of 0-1
    bool exceeded = progress > 1.0; // Check if over goal

    return Stack
    (
      alignment: Alignment.center,
      children: 
      [
        SizedBox
        (
          width: size,
          height: size,
          child: CircularProgressIndicator
          (
            value: exceeded ? 1.0 : progress, // Green progress up to goal
            strokeWidth: size * 0.075,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            backgroundColor: Colors.grey.shade300,
          ),
        ),
        if (exceeded)
        SizedBox
        (
          width: size,
          height: size,
          child: CircularProgressIndicator
          (
            value: (consumed - goal) / goal, // Red for excess
            strokeWidth: size * 0.1,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            backgroundColor: Colors.transparent,
          ),
        ),
        Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: 
          [
            Text("$label", style: TextStyle(fontSize: size * 0.18, fontWeight: FontWeight.bold)),
            Text("${consumed.toStringAsFixed(0)}/${goal.toStringAsFixed(0)} $unit", style: TextStyle(fontSize: size * 0.1)),
          ],
        ),
      ],
    );
  }
}
