import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'product_info_screen.dart';
import 'main.dart';

class FavouritesScreen extends StatefulWidget 
{
  const FavouritesScreen({super.key});

  @override
  FavouritesScreenState createState() => FavouritesScreenState();
}

class FavouritesScreenState extends State<FavouritesScreen> 
{
  List<Map<String, String>> FavouriteProducts = [];
  bool IsLoading = true;

  @override
  void initState() 
  {
    super.initState();
    LoadFavourites();
  }


  //Get favourite item barcodes from firebase, then get product info from OpenFoodFacts
  Future<void> LoadFavourites() async 
  {
    setState(() => IsLoading = true);


    //Firebase portion
    FirebaseFirestore Firestore = FirebaseFirestore.instance;
    QuerySnapshot Query = await Firestore
    .collection("users")
    .doc(ActiveUser)
    .collection("favourites")
    .get();

    List<String> Barcodes = Query.docs
    .map((doc) => doc["barcode"] as String)
    .toList();

    if (Barcodes.isEmpty) 
    {
      setState(() 
      {
        FavouriteProducts = [];
        IsLoading = false;
      });
      return;
    }
    
    //Openfoodfacts portion
    List<Map<String, String>> Products = [];

    for (String barcode in Barcodes) 
    {
      ProductQueryConfiguration config = ProductQueryConfiguration
      (
        barcode,
        version: ProductQueryVersion.v3,
        language: OpenFoodFactsLanguage.ENGLISH,
        fields: 
        [
          ProductField.NAME,
          ProductField.IMAGE_FRONT_URL,
          ProductField.BARCODE,
        ],
      );
      OpenFoodAPIConfiguration.userAgent = UserAgent(name: "Flutter Sugar");
      
      ProductResultV3 result = await OpenFoodAPIClient.getProductV3(config);

      if (result.product != null) 
      {
        Products.add( //Gather information for product card
        {
          "name": result.product!.productName ?? "Unknown",
          "image": result.product!.imageFrontUrl ?? "",
          "barcode": barcode,
        });
      }
    }

    setState(() 
    {
      FavouriteProducts = Products;
      IsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar(title: Text("Favourites")),
      body: IsLoading
      ? Center(child: CircularProgressIndicator()) //If loading
      : FavouriteProducts.isEmpty
      ? Center(child: Text("No favourite items yet!")) //If empty
      : GridView.builder
      (
        padding: EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount //Make a grid
        (
          crossAxisCount: 2, //Of only two columns
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: FavouriteProducts.length,
        itemBuilder: (context, index) 
        {
          return GestureDetector //Detect swiping, tapping
          (
            onTap: () async 
            {
              //Display product info on tap
              await Navigator.push
              (
                context,
                MaterialPageRoute
                (
                  builder: (context) => ProductInfoScreen
                  (
                    key: ValueKey(FavouriteProducts[index]["barcode"]!),
                    Barcode: FavouriteProducts[index]["barcode"]!,
                  ),
                ),
              );

              //Reload favourites when returning, in case of favourite removal
              LoadFavourites();
            },
            child: Card //Layout of the displayed favourites
            (
              shape: RoundedRectangleBorder //Rounded card
              (
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Column
              (
                children: 
                [
                  Expanded //Image and product name
                  (
                    child: Image.network
                    (
                      FavouriteProducts[index]["image"]!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) //In case no image is found
                      {
                        return Image.asset
                        (
                          'assets/images/NoImage.png',
                          fit: BoxFit.cover
                        );
                      },
                    ),
                  ),
                  Padding
                  (
                    padding: const EdgeInsets.all(8.0),
                    child: Text
                    (
                      FavouriteProducts[index]["name"]!,
                      style: TextStyle
                      (
                        fontSize: 16, fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
