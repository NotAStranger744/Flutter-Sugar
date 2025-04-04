// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class SettingsScreen extends StatefulWidget 
{
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}


class SettingsScreenState extends State<SettingsScreen> 
{
  //Controllers for input fields
  final TextEditingController CalorieGoalController = TextEditingController();
  final TextEditingController FatGoalController = TextEditingController();
  final TextEditingController SugarGoalController = TextEditingController();

  @override
  void initState() 
  {
    super.initState();

    FetchGoals();
  }

  //Places current values of each goal into its box - firebase
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


  //Sets what is in the box to the users firebase account as preferences
  Future<void> SaveGoals() async
  {
    FirebaseFirestore Firestore = FirebaseFirestore.instance;

    final CalorieGoal = CalorieGoalController.text;
    final FatGoal = FatGoalController.text;
    final SugarGoal = SugarGoalController.text;

    
    DocumentReference GoalRef = Firestore.collection('users').doc(ActiveUser);
    await GoalRef.update(
    {
      'CalorieGoal': CalorieGoal,
      'FatGoal': FatGoal,
      'SugarGoal': SugarGoal,
    });

    ScaffoldMessenger.of(context).showSnackBar
    (
      SnackBar(content: Text("Goals Saved!")),
    );
  }

  //Sends the user back to the login screen
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
          padding: const EdgeInsets.all(15),
          child: Column //Vertical structure
          (
            mainAxisAlignment: MainAxisAlignment.start,
            children: 
            [
              //Title Text
              Text
              (
                "Set Your Goals",
                style: TextStyle
                (
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              
              //Calorie Goal Field
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

              //Fat Goal Field
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

              //Sugar Goal Field
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

              //Save Button
              ElevatedButton
              (
                onPressed: ()
                {
                  SaveGoals();
                  ScaffoldMessenger.of(context).showSnackBar
                  (
                    SnackBar(content: Text("Goals Saved!")),
                  );
                },
                style: ElevatedButton.styleFrom
                (
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text("Save Goals"),
              ),
              SizedBox(height: 30),

              //Logout Button
              ElevatedButton
              (
                onPressed: () => Logout(context),
                style: ElevatedButton.styleFrom
                (
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                ),
                child: Text("Logout", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        )
        
      ),
    );
  }
}
