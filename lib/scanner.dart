import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'product_info_screen.dart';



class BarcodeScannerScreen extends StatefulWidget 
{
  const BarcodeScannerScreen({super.key});

  @override
  BarcodeScannerScreenState createState() => BarcodeScannerScreenState();
  
}


class BarcodeScannerScreenState extends State<BarcodeScannerScreen> 
{
  String? LastScannedBarcode; //To keep track of the last scanned barcode

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner
      (
        onDetect: (capture) 
        {
          final List<Barcode> barcodes = capture.barcodes;

          if (barcodes.isNotEmpty) 
          {
            String ScannedBarcode = barcodes.first.rawValue!;

            //If the barcode is different from the last one, navigate
            if (LastScannedBarcode != ScannedBarcode) 
            {
              setState(() 
              {
                LastScannedBarcode = ScannedBarcode; //This is now the last scanned barcode
              });

              //Navigate to the ProductInfoScreen
              Navigator.push
              (
                context,
                MaterialPageRoute
                (
                  builder: (context) => ProductInfoScreen(Barcode: ScannedBarcode),
                ),
              );
            }
          }
        },
      ),
    );
  }
}