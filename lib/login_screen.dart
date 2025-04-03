import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget 
{
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> 
{
  //Controls text fields
  final TextEditingController UsernameController = TextEditingController();
  final TextEditingController PasswordController = TextEditingController();
  final FirebaseFirestore Firestore = FirebaseFirestore.instance; //Firestore Database instance
  bool IsRegistering = false; //toggle between register and login mode

  Future<void> LoginOrRegister() async 
  {
    final Username = UsernameController.text.trim(); //trim to remove whitespace
    final Password = PasswordController.text.trim();

    if (Username.isNotEmpty && Password.isNotEmpty) 
    {
      final UserReference = Firestore.collection('users').doc(Username);
      final UserDocument = await UserReference.get();

      if (IsRegistering) 
      {
        if (!UserDocument.exists) //If username does not exist
        {
          await UserReference.set
          ({
            'username': Username,
            'password': Password,
            'CalorieGoal': "2000",
            'FatGoal': "70",
            'SugarGoal': "50"
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User registered!'))); //Confirmation message
          //Store active user
          ActiveUser = Username;

          //Navigate to HomeScreen
          Navigator.pushReplacement
          (
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } 
        else 
        {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Username already exists!'))); //Warning message
          //And do nothing else
        }
      } 
      else //Logging in
      {
        if (UserDocument.exists) 
        {
          final UserData = UserDocument.data() as Map<String, dynamic>;
          final StoredPassword = UserData['password'];


          //Very basic login system, no security, encryption, hashing. More of a proof of concept.
          if (StoredPassword == Password) //If password matches
          {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login successful!')));
            ActiveUser = Username;

            // Navigate to HomeScreen
            Navigator.pushReplacement
            (
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } 
          else //password doesnt match
          {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Incorrect password!')));
          }
        } 
        else //user doesnt exist 
        {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Username not found!')));
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text(IsRegistering ? 'Register' : 'Login'), //Top bar changes depending on action
      ),
      body: Padding
      (
        padding: const EdgeInsets.all(20.0), //Stop widgets touching the edge of the screen
        child: Center
        (
          child: SingleChildScrollView
          (
            child: Column
            (
              mainAxisSize: MainAxisSize.min, //Makes elements vertically central
              children: 
              [
                Text //App name
                (
                  'Flutter Sugar',
                  style: TextStyle
                  (
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 50), //Separate by 50 units from login options
                Card //Place elements into a card, good for stylization and collecting related elements.
                (
                  elevation: 20, //how far the card appears to be lifted from the app
                  shadowColor: Colors.cyan,
                  shape: RoundedRectangleBorder
                  (
                    borderRadius: BorderRadius.circular(50), //how rounded the edges are
                  ),
                  child: Padding
                  (
                    padding: const EdgeInsets.all(20.0), //Keep widgets away from the cards edges
                    child: Column
                    (
                      mainAxisSize: MainAxisSize.min,
                      children: 
                      [
                        //Username field
                        TextField
                        (
                          controller: UsernameController,
                          decoration: InputDecoration
                          (
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person), //Picture of a person
                            border: OutlineInputBorder
                            (
                              borderRadius: BorderRadius.circular(20), //rounding of edges
                              borderSide: BorderSide(color: Colors.cyan),
                            ),
                          ),
                          textInputAction: TextInputAction.next, //Proceeds to the password box
                        ),

                        SizedBox(height: 20), //Gap between fields

                        //Password field
                        TextField
                        (
                          controller: PasswordController,
                          obscureText: true,
                          decoration: InputDecoration
                          (
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock), //icon of a lock
                            border: OutlineInputBorder
                            (
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.cyan),
                            ),
                          ),
                          textInputAction: TextInputAction.done, //closes the keyboard
                        ),

                        SizedBox(height: 20),

                        //Login/Register Button
                        ElevatedButton
                        (
                          onPressed: LoginOrRegister,
                          style: ElevatedButton.styleFrom
                          (
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder
                            (
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(IsRegistering ? 'Register' : 'Login'),
                        ),

                        SizedBox(height: 20),

                        //Login/Register toggle
                        TextButton
                        (
                          onPressed: () 
                          {
                            setState(() 
                            {
                              IsRegistering = !IsRegistering;
                            });
                          },
                          child: Text
                          (
                            IsRegistering ? 'Already have an account? Login here' : 'Don\'t have an account? Register here',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}