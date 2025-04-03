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

//Global editable goals
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
  
  //Get preferences from firestore database
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
        SugarGoal = (data['SugarGoal'] ?? 50).toString(); //Sets with potential default values
      });
    }
  }


  //Gets diet summary based upon products that were added in the day
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

      //Sum of all products
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

  //When removing items
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
            //Title text at the top
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
            SizedBox(height: 30), //Space between the title and the wheels
            //Large Calorie Wheel at the Top
            BuildProgressWheel("Calories", CalorieConsumed, double.parse(CalorieGoal), "kcal", size: 200),

            SizedBox(height: 30),

            //Row with Fat and Sugar Wheels Below
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
            //Edit diet products button
            ElevatedButton
            (
              onPressed: () 
              {
                //Navigate to the edit diet screen
                Navigator.push
                (
                  context,
                  MaterialPageRoute(builder: (context) => DietLogScreen(RefreshDietLog: RefreshDietLog)),
                );
              },
              style: ElevatedButton.styleFrom
              (
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text("Edit Today's Diet", style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }

  //Function to create the progress wheels of fat, sugar and carbs
  Widget BuildProgressWheel(String label, double Consumed, double Goal, String unit, {double size = 100}) 
  {
    double Progress = Consumed / Goal; //Normalize to a scale of 0-1, or 0-100%
    bool Exceeded = Progress > 1.0; //Check if over goal


    //Logic for two circular wheels atop eachother. A normal progress and exceeded progress
    return Stack
    (
      alignment: Alignment.center,
      children: 
      [
        SizedBox
        (
          width: size,
          height: size,
          child: CircularProgressIndicator //Progress toward goal
          (
            value: Exceeded ? 1.0 : Progress, 
            strokeWidth: size * 0.075,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            backgroundColor: Colors.grey.shade300,
          ),
        ),
        if (Exceeded)
        SizedBox
        (
          width: size,
          height: size,
          child: CircularProgressIndicator //Exceeding allowance
          (
            value: (Consumed - Goal) / Goal,
            strokeWidth: size * 0.1, //Slightly larger
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            backgroundColor: Colors.transparent,
          ),
        ),
        Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: //Text within the progress circle for values.
          [
            Text(label, style: TextStyle(fontSize: size * 0.18, fontWeight: FontWeight.bold)),
            Text("${Consumed.toStringAsFixed(0)}/${Goal.toStringAsFixed(0)} $unit", style: TextStyle(fontSize: size * 0.1)),
          ],
        ),
      ],
    );
  }
}
