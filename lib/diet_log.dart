import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'main.dart';

class DietLogScreen extends StatefulWidget 
{
  const DietLogScreen({super.key});

  @override
  DietLogScreenState createState() => DietLogScreenState();
}

class DietLogScreenState extends State<DietLogScreen> 
{
  List<Map<String, dynamic>> DailyDiet = [];
  bool isLoading = true;

  @override
  void initState() 
  {
    super.initState();
    LoadDietLog();
  }

  Future<void> LoadDietLog() async 
  {
    FirebaseFirestore Firestore = FirebaseFirestore.instance;
    DateTime TimeNow = DateTime.now();
    DateTime StartOfDay = DateTime(TimeNow.year, TimeNow.month, TimeNow.day, 0, 0, 0); // Midnight

    //Look for items added today
    QuerySnapshot Query = await Firestore.collection("users").doc(ActiveUser).collection("dietlog").where("timestamp", isGreaterThanOrEqualTo: StartOfDay).get();

    List<Map<String, dynamic>> products = [];

    for (var doc in Query.docs) 
    {
      var data = doc.data() as Map<String, dynamic>;
      products.add(
      {
        "product_name": data["product_name"] ?? "Unknown",
        "product_image": data["product_image"] ?? "",
        "fat": data["fat"] ?? "0",
        "sugar": data["sugar"] ?? "0",
        "energy": data["energy"] ?? "0",
        "barcode": data["barcode"] ?? "0000000000000",
        "timestamp": data["timestamp"],
        "doc_id": doc.id, // Store the document ID (Unix timestamp) for deletion
      });
    }

    setState(() 
    {
      DailyDiet = products;
      isLoading = false;
    });
  }

  Future<void> removeItemFromDiet(String docId) async 
  {
    FirebaseFirestore Firestore = FirebaseFirestore.instance;

    // Remove the item from the diet log
    await Firestore
    .collection("users")
    .doc(ActiveUser)
    .collection("dietlog")
    .doc(docId)
    .delete();

    // Reload the diet log
    LoadDietLog();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar(title: Text("Daily Diet Log")),
      body: isLoading ? Center(child: CircularProgressIndicator()) : DailyDiet.isEmpty ? //loading symbol 
        Center(child: Text("No items added today")) : ListView.builder //if empty
        (
          itemCount: DailyDiet.length,
          itemBuilder: (context, index) 
          {
            var Item = DailyDiet[index];
            return Card
            (
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 5,
              child: ListTile
              (
                contentPadding: EdgeInsets.all(10),
                leading: Image.network
                (
                  Item["product_image"],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) 
                  {
                    return Image.asset('assets/images/NoImage.png',
                    fit: BoxFit.cover, width: 50, height: 50);
                  },
                ),
                title: Text(Item["product_name"]),
                subtitle: Column
                (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: 
                  [
                    Text("Fat: ${Item["fat"]} g"),
                    Text("Sugar: ${Item["sugar"]} g"),
                    Text("Energy: ${Item["energy"]} kcal"),
                  ],
                ),
                trailing: IconButton
                (
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => removeItemFromDiet(Item["doc_id"]),
                ),
              ),
            );
          },
      ),
    );
  }
}
