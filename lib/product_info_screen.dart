import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ProductInfoScreen extends StatefulWidget 
{
  final String ProductName;
  final String ProductImage;
  final String Barcode;

  const ProductInfoScreen({super.key, required this.ProductName, required this.ProductImage, required this.Barcode});

  @override
  ProductInfoScreenState createState() => ProductInfoScreenState();
}

class ProductInfoScreenState extends State<ProductInfoScreen> 
{
  bool IsLoading = true;
  String Fat = "N/A";
  String Sugar = "N/A";
  String Energy = "N/A";
  String Quantity = "N/A";
  String QuantityUnit = "";
  double QuantityValue = 0;
  double EnteredQuantity = 0;

  @override
  void initState() 
  {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async 
  {
    OpenFoodAPIConfiguration.userAgent = UserAgent(name: "Flutter Sugar");

    ProductQueryConfiguration configuration = ProductQueryConfiguration
    (
      widget.Barcode,
      version: ProductQueryVersion.v3,
      fields: 
      [
        ProductField.NUTRIMENTS,
        ProductField.QUANTITY,
      ],
      language: OpenFoodFactsLanguage.ENGLISH,
      country: OpenFoodFactsCountry.UNITED_KINGDOM,
    );

    final ProductResultV3 result = await OpenFoodAPIClient.getProductV3
    (
      configuration,
    );

    if (result.product != null && result.product!.nutriments != null)
    {
      setState(()
      {
        Fat = result.product!.nutriments!.getValue(Nutrient.fat, PerSize.oneHundredGrams)?.toStringAsFixed(1) ?? "N/A";
        Sugar = result.product!.nutriments!.getValue(Nutrient.sugars, PerSize.oneHundredGrams)?.toStringAsFixed(1) ?? "N/A";
        Energy = result.product!.nutriments!.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams)?.toStringAsFixed(0) ?? "N/A";
        Quantity = result.product!.quantity ?? "N/A";
        var QuantityParsed = parseString(Quantity);
        QuantityValue = QuantityParsed["value"];
        QuantityUnit = QuantityParsed["unit"];

        IsLoading = false;
      });
    } 
    else 
    {
      setState(() 
      {
        IsLoading = false;
      });
    }
  }

  Map<String, dynamic> parseString(String string) 
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

  void addToDailyDiet() 
  {
    double Factor = EnteredQuantity / 100;
    double AddedFat = double.parse(Fat) * Factor;
    double AddedSugar = double.parse(Sugar) * Factor;
    double AddedEnergy = double.parse(Energy) * Factor;


    // Here you can save the data to local storage or a database
    ScaffoldMessenger.of(context).showSnackBar
    (
      SnackBar(content: Text("$EnteredQuantity $QuantityUnit of ${widget.ProductName} added to daily diet! Fat: ${AddedFat.toStringAsFixed(2)} g, Sugar: ${AddedSugar.toStringAsFixed(2)} g, Energy: ${AddedEnergy.toStringAsFixed(2)} kcal.")),
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar(title: Text(widget.ProductName)),
      body: Center
      (
        child: IsLoading 
        ? CircularProgressIndicator()
        : Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: 
          [
            Image.network
            (
              widget.ProductImage,
              fit: BoxFit.cover,
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) 
              {
                return Image.asset('assets/images/NoImage.png', fit: BoxFit.cover, width: 200, height: 200);
              },
            ),
            SizedBox(height: 20),
            Text(widget.ProductName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            SizedBox(height: 20),
            Text("Quantity: $Quantity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            Text("Per 100 $QuantityUnit:"),
            Text("Fat: $Fat g", style: TextStyle(fontSize: 18)),
            Text("Sugar: $Sugar g", style: TextStyle(fontSize: 18)),
            Text("Energy: $Energy kcal", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
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
            ElevatedButton
            (
              onPressed: EnteredQuantity > 0 ? addToDailyDiet : null,
              child: Text("Add to Daily Diet"),
            ),
          ],
        ),
      ),
    );
  }
}
