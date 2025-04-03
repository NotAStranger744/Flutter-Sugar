import 'package:flutter/material.dart';
import 'product_info_screen.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class SearchScreen extends StatefulWidget 
{
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> 
{
  String searchQuery = "";
  List<Map<String, String>> Products = [];
  bool IsLoading = false;

  Future<void> fetchProducts(String query) async 
  {
    setState(() 
    {
      IsLoading = true;
    });
    OpenFoodAPIConfiguration.userAgent = UserAgent(name: "Flutter Sugar");
    ProductSearchQueryConfiguration configuration = ProductSearchQueryConfiguration
    (
      version: ProductQueryVersion.v3,
      fields: 
      [
        ProductField.NAME, 
        ProductField.IMAGE_FRONT_URL, 
        ProductField.BARCODE
      ],
      parametersList: [SearchTerms(terms: [query])],
      language: OpenFoodFactsLanguage.ENGLISH,
      country: OpenFoodFactsCountry.UNITED_KINGDOM,
    );

    final SearchResult result = await OpenFoodAPIClient.searchProducts
    (
      User(userId: "cmason19", password: "FlutterPassword744"), //API Requires a login
      configuration,
    );

    if (result.products != null) 
    {
      setState(() 
      {
        Products = result.products!.map((product) => 
        {
          "name": product.productName ?? "Unknown",
          "image": product.imageFrontUrl ?? "",
          "barcode": product.barcode ?? "0000000000000", // Default values if missing
        }).toList();
        IsLoading = false;
      });
    } 
    else 
    {
      setState(() 
      {
        Products = [];
        IsLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) 
  {
    return Column
    (
      children: 
      [
        Padding
        (
          padding: const EdgeInsets.all(8.0),
          child: TextField //Search Bar
          (
            onChanged: (value) 
            {
              setState(() 
              {
                searchQuery = value;
              });
            },
            onSubmitted: (value) 
            {
              if (value.isNotEmpty) 
              {
                fetchProducts(value);
              }
            },
            decoration: InputDecoration
            (
              hintText: "Search for a product...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        Expanded
        (
          child: IsLoading 
          ? Center(child: CircularProgressIndicator()) //Loading symbol after search
          : GridView.builder
          (
            padding: EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount //Grid layout of items
            (
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: Products.length,
            itemBuilder: (context, index) 
            {
              return GestureDetector
              (
                onTap: () 
                {
                  Navigator.push  //When item pressed, go to details page of the product
                  (
                    context,
                    MaterialPageRoute
                    (
                      builder: (context) => ProductInfoScreen
                      (
                        key: ValueKey(Products[index]["barcode"]!),
                        Barcode: Products[index]["barcode"]!,
                      ),
                    ),
                  );
                },
                child: Card //Each card within the grid contains
                (
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Column
                  (
                    children: 
                    [
                      Expanded
                      (
                        child: Image.network //An image
                        (
                          Products[index]["image"]!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) 
                          {
                            return Image.asset('assets/images/NoImage.png', fit: BoxFit.cover);
                          },
                        ),
                      ),
                      Padding
                      (
                        padding: const EdgeInsets.all(8.0),
                        child: Text //And the product name
                        (
                          Products[index]["name"]!,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
