import 'package:flutter/material.dart';
import 'package:flutterapp/main.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';


class ProductInfoScreen extends StatefulWidget 
{
  final String Barcode;

  const ProductInfoScreen({super.key, required this.Barcode});

  @override
  ProductInfoScreenState createState() => ProductInfoScreenState();
}


class ProductInfoScreenState extends State<ProductInfoScreen> 
{
  bool IsLoading = true;
  bool IsFavourite = false;
  String Fat = "N/A";
  String Sugar = "N/A";
  String Energy = "N/A";
  String Quantity = "N/A";
  String QuantityUnit = "";
  double QuantityValue = 0;
  double EnteredQuantity = 0;
  String ProductName = "";
  String ProductImage = "";

  @override
  void initState() 
  {
    super.initState();
    FetchProductDetails();
    CheckIfFavourite();
  }

  Future<void> CheckIfFavourite() async 
  {
    FirebaseFirestore Firestore = FirebaseFirestore.instance;
    DocumentSnapshot FavouriteDoc = await Firestore.collection("users").doc(ActiveUser).collection("favourites").doc(widget.Barcode).get();

    setState(() 
    {
      IsFavourite = FavouriteDoc.exists; // Update favourite status
    });
  }


  Future<void> FetchProductDetails() async //Get information from the API
  {
    setState(() 
    {
      IsLoading = true;
      Fat = "N/A";
      Sugar = "N/A";
      Energy = "N/A";
      Quantity = "N/A";
      QuantityUnit = "";
      QuantityValue = 0;
      ProductName = "";
      ProductImage = "";
    });

    OpenFoodAPIConfiguration.userAgent = UserAgent(name: "Flutter Sugar");

    ProductQueryConfiguration configuration = ProductQueryConfiguration
    (
      widget.Barcode,
      version: ProductQueryVersion.v3,
      fields: 
      [
        ProductField.NAME, 
        ProductField.IMAGE_FRONT_URL, 
        ProductField.NUTRIMENTS,
        ProductField.QUANTITY,
      ],
      language: OpenFoodFactsLanguage.ENGLISH,
      country: OpenFoodFactsCountry.UNITED_KINGDOM,
    );

    try 
    {
      final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(configuration);

      if (result.product != null && result.product!.nutriments != null) 
      {
        setState(() 
        {
          //get details
          ProductName = result.product!.productName ?? "Unknown Product";
          ProductImage = result.product!.imageFrontUrl ?? "";

          Fat = result.product!.nutriments!.getValue(Nutrient.fat, PerSize.oneHundredGrams)?.toStringAsFixed(1) ?? "N/A";
          Sugar = result.product!.nutriments!.getValue(Nutrient.sugars, PerSize.oneHundredGrams)?.toStringAsFixed(1) ?? "N/A";
          Energy = result.product!.nutriments!.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams)?.toStringAsFixed(0) ?? "N/A";
          Quantity = result.product!.quantity ?? "N/A";
          //separate quantity value from unit
          var QuantityParsed = ParseString(Quantity);
          QuantityValue = QuantityParsed["value"];
          QuantityUnit = QuantityParsed["unit"];
        });
      }
    } 
    catch (e) 
    {
      print("Error fetching product details: $e"); //state what is wrong
    } 
    finally
    {
      setState(() 
      {
        IsLoading = false; // Ensure loading stops
      });
    }
  }

  Map<String, dynamic> ParseString(String string) //function to split a value from its unit
  {
    List<String> Parts = string.split(' '); 

    if (Parts.isNotEmpty) 
    {
      double? Value = double.tryParse(Parts[0]); 
      String Unit = Parts.length > 1 ? Parts.sublist(1).join(' ') : ""; 

      if (Value != null) 
      {
        return {"value": Value, "unit": Unit};
      }
    }
    return {"value": 0, "unit": ""}; 
  }


  void AddToDailyDiet() async //Place values attained into firebase
  {
    if (EnteredQuantity <= 0) return;

    FirebaseFirestore Firestore = FirebaseFirestore.instance;

    double Factor = EnteredQuantity / 100;
    double AddedFat = double.parse(Fat) * Factor;
    double AddedSugar = double.parse(Sugar) * Factor;
    double AddedEnergy = double.parse(Energy) * Factor;

    // Reference to user's current diet in Firestore
    DocumentReference ProductRef = Firestore
    .collection("users")
    .doc(ActiveUser)
    .collection("dietlog")
    .doc(DateTime.now().millisecondsSinceEpoch.toString()); //Store information under the timestamp to prevent duplicates

    await ProductRef.set(
    {
      "barcode": widget.Barcode,
      "product_name": ProductName,
      "product_image": ProductImage,
      "quantity_used": EnteredQuantity,
      "quantity_unit": QuantityUnit,
      "fat": AddedFat.toStringAsFixed(2),
      "sugar": AddedSugar.toStringAsFixed(2),
      "energy": AddedEnergy.toStringAsFixed(2),
      "timestamp": FieldValue.serverTimestamp(),
    });

    //Output message of what was added
    ScaffoldMessenger.of(context).showSnackBar
    (
      SnackBar(content: Text("$EnteredQuantity $QuantityUnit of ${ProductName} added to daily diet! Fat: ${AddedFat.toStringAsFixed(2)} g, Sugar: ${AddedSugar.toStringAsFixed(2)} g, Energy: ${AddedEnergy.toStringAsFixed(2)} kcal.")),
    );
  }
  void ToggleFavourite() async 
  {
    FirebaseFirestore Firestore = FirebaseFirestore.instance;

    // Reference to user's favourites in Firestore
    DocumentReference FavouriteRef = Firestore
    .collection("users")
    .doc(ActiveUser)
    .collection("favourites")
    .doc(widget.Barcode); // Store each favourite by barcode

    if (IsFavourite) 
    {
      await FavouriteRef.delete(); // Remove from favourites if already added
      ScaffoldMessenger.of(context).showSnackBar
      (
        SnackBar(content: Text("${ProductName} removed from favourites!")),
      );
    }
    else 
    {
      await FavouriteRef.set(
      {
        "barcode": widget.Barcode,
      });
      ScaffoldMessenger.of(context).showSnackBar
      (
        SnackBar(content: Text("${ProductName} added to favourites!")),
      );
    }

    setState(() 
    {
      IsFavourite = !IsFavourite; // Toggle favourite state
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar(title: Text(ProductName)),
      body: Center
      (
        child: SingleChildScrollView
        (
          child: IsLoading //loading icon
        ? CircularProgressIndicator()
        : Column
          (
            mainAxisAlignment: MainAxisAlignment.center,
            children: 
            [
              //show image
              Image.network
              (
                ProductImage,
                fit: BoxFit.cover,
                width: 200,
                height: 200,
                errorBuilder: (context, error, stackTrace) 
                {
                  //if image was not found
                  return Image.asset('assets/images/NoImage.png', fit: BoxFit.cover, width: 200, height: 200);
                },
              ),

              //output results
              SizedBox(height: 10),
              Text(ProductName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              SizedBox(height: 10),
              Text("Quantity: $Quantity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              Text("Per 100 $QuantityUnit:"),
              Text("Fat: $Fat g", style: TextStyle(fontSize: 18)),
              Text("Sugar: $Sugar g", style: TextStyle(fontSize: 18)),
              Text("Energy: $Energy kcal", style: TextStyle(fontSize: 18)),
              SizedBox(height: 0),
              Padding
              (
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField
                (
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Enter quantity used ($QuantityUnit)"),
                  onChanged: (value) 
                  {
                    setState(() 
                    {
                      EnteredQuantity = double.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              Row
              (
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: 
                [
                  Expanded
                  (
                    child: ElevatedButton
                    (
                      onPressed: EnteredQuantity > 0 ? AddToDailyDiet : null,
                      child: Text("Add to Diet"),
                    ),
                  ),
                  SizedBox(width: 10), // Space between buttons
                  Expanded
                  (
                    child: ElevatedButton
                    (
                      onPressed: ToggleFavourite,
                      style: ElevatedButton.styleFrom
                      (
                        padding: EdgeInsets.zero, // Removes default padding for better icon centering
                      ),
                      child: Icon
                      (
                        Icons.favorite,
                        color: IsFavourite ? Colors.red : Colors.grey, // Red when favourite, grey otherwise
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ) 
      ),
    );
  } 
}
