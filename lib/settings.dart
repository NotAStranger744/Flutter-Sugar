import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController CalorieGoalController = TextEditingController();
  final TextEditingController FatGoalController = TextEditingController();
  final TextEditingController SugarGoalController = TextEditingController();

  @override
  void initState() 
  {
    super.initState();

    FetchGoals();
  }

  Future<void> FetchGoals() async 
  {
    FirebaseFirestore Firestore = FirebaseFirestore.instance;

    DocumentSnapshot UserDoc = await Firestore.collection('users').doc(ActiveUser).get();

    if (UserDoc.exists) 
    {
      var data = UserDoc.data() as Map<String, dynamic>;
      setState(() 
      {
        CalorieGoalController.text = (data['CalorieGoal'] ?? 2000).toString();
        FatGoalController.text = (data['FatGoal'] ?? 70).toString();
        SugarGoalController.text = (data['SugarGoal'] ?? 50).toString();

      });
    } 
    else 
    {
      setState(() 
      {
      });
    }
  }


  
  Future<void> SaveGoals() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Parse the goal values as double before saving
  double calorieGoal = double.tryParse(CalorieGoalController.text) ?? 2000;
  double fatGoal = double.tryParse(FatGoalController.text) ?? 70;
  double sugarGoal = double.tryParse(SugarGoalController.text) ?? 50;

  // Ensure we have valid values
  print("Saving goals: CalorieGoal = $calorieGoal, FatGoal = $fatGoal, SugarGoal = $sugarGoal");

  try {
    // Update the user's goals in Firestore
    DocumentReference goalRef = firestore.collection('users').doc(ActiveUser);

    // Set the new goals (using update to modify existing fields)
    await goalRef.update({
      'CalorieGoal': calorieGoal,
      'FatGoal': fatGoal,
      'SugarGoal': sugarGoal,
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Goals Saved!")));
  } catch (e) {
    // Handle error if the update fails
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save goals!")));
    print("Error saving goals: $e");
  }
}

  Future<void> Logout(BuildContext context) async 
  {
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
      appBar: AppBar(title: Text("Settings")),
      body: Center
      (
        child: SingleChildScrollView
        (
          padding: const EdgeInsets.all(16.0),
          child: Column
          (
            mainAxisAlignment: MainAxisAlignment.start,
            children: 
            [
              // Title Text
              Text(
                "Set Your Goals",
                style: TextStyle
                (
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              
              // Calorie Goal Field
              TextField
              (
                controller: CalorieGoalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration
                (
                  labelText: "Calorie Goal (kcal)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Fat Goal Field
              TextField(
                controller: FatGoalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration
                (
                  labelText: "Fat Goal (g)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Sugar Goal Field
              TextField
              (
                controller: SugarGoalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration
                (
                  labelText: "Sugar Goal (g)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),

              // Save Button
              ElevatedButton
              (
                onPressed: ()
                {
                  SaveGoals;
                  ScaffoldMessenger.of(context).showSnackBar
                  (
                    SnackBar(content: Text("Goals Saved!")),
                  );
                },
                child: Text("Save Goals"),
                style: ElevatedButton.styleFrom
                (
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              SizedBox(height: 30),

              // Logout Button
              ElevatedButton
              (
                onPressed: () => Logout(context),
                child: Text("Logout", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom
                (
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                ),
              ),
            ],
          ),
        )
        
      ),
    );
  }
}
