import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:square_in_app_payments/models.dart';

class PaymentService {
  final databaseReference = FirebaseDatabase.instance.ref();

  Future<void> chargePayment(String nonce, double amount) async {
    try {
      var result = await processPaymentOnServer(nonce, amount);

      await databaseReference.child('payments').push().set({
        'transactionId': result.transactionId,
        'amount': amount,
        'date': DateTime.now().toString(),
      });
    } catch (e) {
      print('Erreur lors du traitement du paiement: $e');
    }
  }

  Future<void> startCardEntryFlow() async {
    await InAppPayments.startCardEntryFlow(
      onCardNonceRequestSuccess: (CardDetails result) {
        print('Nonce obtenu: ${result.nonce}');
        chargePayment(result.nonce, 100.00);
        InAppPayments.completeCardEntry(onCardEntryComplete: () {
          print('Entrée de carte terminée');
        });
      },
      onCardEntryCancel: () {
        print('Entrée de carte annulée');
      },
    );
  }

  Future<dynamic> processPaymentOnServer(String nonce, double amount) async {
    return {'transactionId': '123456789'};
  }
}




