import 'package:flutter/material.dart';

class FactureScan extends StatefulWidget {
  const FactureScan({super.key});
  @override
  State<FactureScan> createState() => _FactureScanState();
}

class _FactureScanState extends State<FactureScan> {
  bool isScanning = true;
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 3),
      () => setState(() => isScanning = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: isScanning
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.yellow),
                  Text("\nAnalyse..."),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const Text(
                    "\nFacture EDF : 120,00 €",
                    style: TextStyle(fontSize: 20),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("PAYER"),
                  ),
                ],
              ),
      ),
    );
  }
}
