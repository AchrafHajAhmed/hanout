import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/models.dart';

class SquarePayment {
  final String squareApplicationId;

  SquarePayment(this.squareApplicationId) {
    _initSquarePayment();
  }

  void _initSquarePayment() {
    InAppPayments.setSquareApplicationId(squareApplicationId);
  }

  Future<void> startPayment({
    required void Function(CardDetails) onSuccess,
    required void Function(String) onError,
    required void Function() onCancel,
  }) async {
    try {
      await InAppPayments.startCardEntryFlow(
        onCardNonceRequestSuccess: (CardDetails result) {

          InAppPayments.completeCardEntry(
              onCardEntryComplete: () {
                onSuccess(result);
              }
          );
        },
        onCardEntryCancel: onCancel,
        collectPostalCode: false,
      );
    } catch (e) {
      onError(e.toString());
    }
  }
}
