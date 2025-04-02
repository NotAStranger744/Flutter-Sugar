import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class SearchScreen extends StatefulWidget 
{
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> 
{
  String searchQuery = "";
  List<Map<String, String>> products = [];
  bool isLoading = false;

  Future<void> fetchProducts(String query) async 
  {
    setState(() 
    {
      isLoading = true;
    });
    OpenFoodAPIConfiguration.userAgent = UserAgent(name: "Flutter Sugar");
    ProductSearchQueryConfiguration configuration = ProductSearchQueryConfiguration
    (
      version: ProductQueryVersion.v3,
      fields: [ProductField.NAME, ProductField.IMAGE_FRONT_URL],
      parametersList: [SearchTerms(terms: [query])],
      language: OpenFoodFactsLanguage.ENGLISH,
      country: OpenFoodFactsCountry.UNITED_KINGDOM,
    );

    final SearchResult result = await OpenFoodAPIClient.searchProducts
    (
      User(userId: "cmason19", password: "FlutterPassword744"),
      configuration,
    );

    if (result.products != null) 
    {
      setState(() 
      {
        products = result.products!.map((product) => 
        {
          "name": product.productName ?? "Unknown",
          "image": product.imageFrontUrl ?? "assets/images/NoImage.png",
        }).toList();
        isLoading = false;
      });
    } 
    else 
    {
      setState(() 
      {
        products = [];
        isLoading = false;
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
          child: TextField
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
          child: isLoading 
          ? Center(child: CircularProgressIndicator())
          : GridView.builder
          (
            padding: EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount
            (
              crossAxisCount: 2, // Two columns
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8, // Adjusts height of each item
            ),
            itemCount: products.length,
            itemBuilder: (context, index) 
            {
              return Card
              (
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Column
                (
                  children: 
                  [
                    Expanded
                    (
                      child: Image.network
                      (
                        products[index]["image"]!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) 
                        {
                          // Fallback to a local image if the network image fails
                          return Image.asset('assets/images/NoImage.png', fit: BoxFit.cover);
                        },
                      ),
                    ),
                    Padding
                    (
                      padding: const EdgeInsets.all(8.0),
                      child: Text
                      (
                        products[index]["name"]!,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
