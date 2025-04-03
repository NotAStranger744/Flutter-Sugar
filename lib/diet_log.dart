import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting date

class DietLogScreen extends StatefulWidget {
  const DietLogScreen({super.key});

  @override
  _DietLogScreenState createState() => _DietLogScreenState();
}

class _DietLogScreenState extends State<DietLogScreen> {
  List<Map<String, dynamic>> currentDayItems = [];
  Map<String, List<Map<String, dynamic>>> olderItemsByDay = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDietLog();
  }

  Future<void> loadDietLog() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DateTime today = DateTime.now();
    DateFormat dateFormat = DateFormat("yyyy-mm-dd");

    // Get the current day formatted as yyyy-mm-dd
    String todayFormatted = dateFormat.format(today);

    QuerySnapshot snapshot = await firestore
        .collection("users")
        .doc("ActiveUser") // Use the active user ID here
        .collection("dietlog")
        .where("timestamp", isGreaterThanOrEqualTo: today.millisecondsSinceEpoch - 86400000) // Timestamp from the previous day
        .get();

    List<Map<String, dynamic>> currentDayItemsTemp = [];
    Map<String, List<Map<String, dynamic>>> olderItemsTemp = {};

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String productName = data["product_name"];
      String productImage = data["product_image"];
      double quantityUsed = data["quantity_used"];
      String quantityUnit = data["quantity_unit"];
      double fat = data["fat"];
      double sugar = data["sugar"];
      double energy = data["energy"];
      DateTime timestamp = (data["timestamp"] as Timestamp).toDate();

      // Get the date in yyyy-MM-dd format
      String productDate = dateFormat.format(timestamp);

      // Group by day
      if (productDate == todayFormatted) {
        currentDayItemsTemp.add({
          "name": productName,
          "image": productImage,
          "quantity_used": quantityUsed,
          "quantity_unit": quantityUnit,
          "fat": fat,
          "sugar": sugar,
          "energy": energy,
          "timestamp": timestamp,
        });
      } else {
        if (!olderItemsTemp.containsKey(productDate)) {
          olderItemsTemp[productDate] = [];
        }
        olderItemsTemp[productDate]!.add({
          "name": productName,
          "image": productImage,
          "quantity_used": quantityUsed,
          "quantity_unit": quantityUnit,
          "fat": fat,
          "sugar": sugar,
          "energy": energy,
          "timestamp": timestamp,
        });
      }
    }

    setState(() {
      currentDayItems = currentDayItemsTemp;
      olderItemsByDay = olderItemsTemp;
      isLoading = false;
    });
  }

  // Function to remove item from today's diet log
  void removeItem(String productName, DateTime timestamp) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore
        .collection("users")
        .doc("ActiveUser") // Use the active user ID here
        .collection("dietlog")
        .where("product_name", isEqualTo: productName)
        .where("timestamp", isEqualTo: Timestamp.fromDate(timestamp))
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
      loadDietLog(); // Reload diet log to reflect the change
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Diet Log")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Current day's items
                  ...currentDayItems.map((item) {
                    return ListTile(
                      leading: Image.network(
                        item["image"],
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/images/NoImage.png',
                              width: 50, height: 50);
                        },
                      ),
                      title: Text(item["name"]),
                      subtitle: Text(
                          "Qty: ${item["quantity_used"]} ${item["quantity_unit"]} - Fat: ${item["fat"]}g, Sugar: ${item["sugar"]}g, Energy: ${item["energy"]} kcal"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          removeItem(item["name"], item["timestamp"]);
                        },
                      ),
                    );
                  }).toList(),

                  // Older items grouped by day
                  ...olderItemsByDay.entries.map((entry) {
                    String day = entry.key;
                    List<Map<String, dynamic>> items = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            day,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...items.map((item) {
                          return ListTile(
                            leading: Image.network(
                              item["image"],
                              width: 50,
                              height: 50,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset('assets/images/NoImage.png',
                                    width: 50, height: 50);
                              },
                            ),
                            title: Text(item["name"]),
                            subtitle: Text(
                                "Qty: ${item["quantity_used"]} ${item["quantity_unit"]} - Fat: ${item["fat"]}g, Sugar: ${item["sugar"]}g, Energy: ${item["energy"]} kcal"),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
