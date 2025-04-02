import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ProductInfoScreen extends StatefulWidget 
{
  final String productName;
  final String productImage;
  final String barcode;

  const ProductInfoScreen({super.key, required this.productName, required this.productImage, required this.barcode});

  @override
  _ProductInfoScreenState createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> 
{
  bool isLoading = true;
  String fat = "N/A";
  String sugar = "N/A";
  String energy = "N/A";

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
      widget.barcode,
      version: ProductQueryVersion.v3,
      fields: 
      [
        ProductField.NUTRIMENTS,
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

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar(title: Text(widget.productName)),
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
              widget.productImage,
              fit: BoxFit.cover,
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) 
              {
                return Image.asset('assets/images/NoImage.png', fit: BoxFit.cover, width: 200, height: 200);
              },
            ),
            SizedBox(height: 20),
            Text(widget.productName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            SizedBox(height: 20),
            Text("Fat: $fat g", style: TextStyle(fontSize: 18)),
            Text("Sugar: $sugar g", style: TextStyle(fontSize: 18)),
            Text("Energy: $energy kcal", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
