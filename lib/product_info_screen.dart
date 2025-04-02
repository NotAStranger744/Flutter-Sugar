import 'package:flutter/material.dart';

class ProductInfoScreen extends StatelessWidget 
{
  const ProductInfoScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar(title: const Text("Product Info")),
      body: Center
      (
        child: Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>
          [
            const Text("Product Info Screen", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton
            (
              onPressed: () 
              {
                // Navigate back to Home Screen
                Navigator.pop(context);
              },
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}