import 'package:flutter/material.dart';

import 'login_screen.dart';

class HomeScreen extends StatelessWidget 
{
  final double fatGoal = 70; // Example target in grams
  final double sugarGoal = 50; // Example target in grams
  final double calorieGoal = 2000; // Example target in kcal

  final double fatConsumed = 90; // Example: Change these dynamically
  final double sugarConsumed = 30;
  final double calorieConsumed = 2200;

  final String username;

  const HomeScreen({super.key, required this.username});

  Future<void> Logout(BuildContext context) async 
  {

    // Navigate back to login screen
    Navigator.pushReplacement
    (
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: 
          [
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
            SizedBox(height: 50), // Space between the title and the wheels
            // Large Calorie Wheel at the Top
            buildProgressWheel("Calories", calorieConsumed, calorieGoal, "kcal", size: 200),

            SizedBox(height: 50),

            // Row with Fat and Sugar Wheels Below
            Row
            (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: 
              [
                buildProgressWheel("Fat", fatConsumed, fatGoal, "g", size: 150),
                buildProgressWheel("Sugar", sugarConsumed, sugarGoal, "g", size: 150),
              ],
            ),

            SizedBox(height: 50),
            // Button to view the daily diet products
            ElevatedButton
            (
              onPressed: () 
              {
                // Navigate to the Daily Diet screen
                //Navigator.push
                (
                  //context,
                  //MaterialPageRoute(builder: (context) => DailyDietScreen()), // Placeholder for the diet screen
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

  Widget buildProgressWheel(String label, double consumed, double goal, String unit, {double size = 100}) 
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
