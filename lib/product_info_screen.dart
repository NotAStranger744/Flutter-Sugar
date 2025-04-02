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
  bool isLoading = true;
  String fat = "N/A";
  String sugar = "N/A";
  String energy = "N/A";
  String quantity = "N/A";
  String quantityUnit = "";
  double quantityValue = 0;
  double enteredQuantity = 0;

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
        fat = result.product!.nutriments!.getValue(Nutrient.fat, PerSize.oneHundredGrams)?.toStringAsFixed(1) ?? "N/A";
        sugar = result.product!.nutriments!.getValue(Nutrient.sugars, PerSize.oneHundredGrams)?.toStringAsFixed(1) ?? "N/A";
        energy = result.product!.nutriments!.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams)?.toStringAsFixed(0) ?? "N/A";
        quantity = result.product!.quantity ?? "N/A";
        var quantityParsed = parseString(quantity);
        quantityValue = quantityParsed["value"];
        quantityUnit = quantityParsed["unit"];

        isLoading = false;
      });
    } 
    else 
    {
      setState(() 
      {
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> parseString(String string) 
  {
    List<String> parts = string.split(' '); 

    if (parts.isNotEmpty) 
    {
      double? value = double.tryParse(parts[0]); 
      String unit = parts.length > 1 ? parts.sublist(1).join(' ') : ""; 

      if (value != null) 
      {
        return {"value": value, "unit": unit};
      }
    }
    return {"value": 0, "unit": ""}; 
  }

  void addToDailyDiet() 
  {
    double factor = enteredQuantity / 100;
    double addedFat = double.parse(fat) * factor;
    double addedSugar = double.parse(sugar) * factor;
    double addedEnergy = double.parse(energy) * factor;


    // Here you can save the data to local storage or a database
    ScaffoldMessenger.of(context).showSnackBar
    (
      SnackBar(content: Text("$enteredQuantity $quantityUnit of ${widget.ProductName} added to daily diet! Fat: ${addedFat.toStringAsFixed(2)} g, Sugar: ${addedSugar.toStringAsFixed(2)} g, Energy: ${addedEnergy.toStringAsFixed(2)} kcal.")),
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
        child: isLoading 
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
            Text("Quantity: $quantity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            Text("Per 100 $quantityUnit:"),
            Text("Fat: $fat g", style: TextStyle(fontSize: 18)),
            Text("Sugar: $sugar g", style: TextStyle(fontSize: 18)),
            Text("Energy: $energy kcal", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Padding
            (
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField
              (
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Enter quantity used ($quantityUnit)"),
                onChanged: (value) 
                {
                  setState(() 
                  {
                    enteredQuantity = double.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton
            (
              onPressed: enteredQuantity > 0 ? addToDailyDiet : null,
              child: Text("Add to Daily Diet"),
            ),
          ],
        ),
      ),
    );
  }
}
