import 'package:flutter/material.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/models.dart';
import 'package:hanout/widget/elevated_button.dart';
import 'package:hanout/color.dart';
import 'paiement_done.dart';

class TotalCostScreen extends StatefulWidget {
  final double totalAchat;
  final double livraison;

  TotalCostScreen({required this.totalAchat, required this.livraison});

  @override
  _TotalCostScreenState createState() => _TotalCostScreenState();
}

class _TotalCostScreenState extends State<TotalCostScreen> {
  double totalCout = 0.0;
  double fraisService = 0.0;
  double taxeTVA = 0.0;
  double grandTotal = 0.0;

  @override
  void initState() {
    super.initState();
    totalCout = widget.totalAchat + widget.livraison;
    fraisService = totalCout * 0.05;
    taxeTVA = fraisService * 0.19;
    grandTotal = totalCout + fraisService + taxeTVA;
    initSquarePayment();
  }

  void initSquarePayment() {
    InAppPayments.setSquareApplicationId('sandbox-sq0idb-OgNumYKWNySZhZljrleXWA');
  }

  void startCardEntryFlow() {
    InAppPayments.startCardEntryFlow(
      onCardNonceRequestSuccess: onCardNonceRequestSuccess,
      onCardEntryCancel: onCardEntryCancel,
    );
  }

  void onCardNonceRequestSuccess(CardDetails result) {
    InAppPayments.completeCardEntry(
      onCardEntryComplete: () => processPayment(result.nonce),
    );
  }

  void onCardEntryCancel() {
  }

  void onCardEntryComplete() {
  }

  Future<void> processPayment(String nonce) async {
    print("Nonce: $nonce");
    // Navigate to Done page when card entry is complete
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Done()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 50),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Checkout', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                CostRow(description: 'Total Coût:', value: '${totalCout.toStringAsFixed(2)} TND'),
                SizedBox(height: 10),
                CostRow(description: 'Frais de Service:', value: '${fraisService.toStringAsFixed(2)} TND'),
                SizedBox(height: 10),
                CostRow(description: 'Coût de Livraison:', value: '${widget.livraison.toStringAsFixed(2)} TND'),
                SizedBox(height: 10),
                CostRow(description: 'TVA :', value: '${taxeTVA.toStringAsFixed(2)} TND'),
                SizedBox(height: 80),
                CostRow(description: 'Total:', value: '${grandTotal.toStringAsFixed(2)} TND', color: AppColors.secondaryColor),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(40.0),
        child: MyElevatedButton(
          buttonText: 'Confirm',
          onPressed: startCardEntryFlow,
        ),
      ),
    );
  }
}

class CostRow extends StatelessWidget {
  final String description;
  final String value;
  final Color color;

  const CostRow({Key? key, required this.description, required this.value, this.color = Colors.black}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(description, style: TextStyle(fontSize: 18, color: color)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}





