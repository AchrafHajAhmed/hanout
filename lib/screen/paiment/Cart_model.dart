import 'package:flutter/material.dart';
import 'package:hanout/screen/paiment/cart_item.dart';
import 'package:collection/collection.dart';


class CartModel with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addItem(String id, String title, double price) {
    CartItem? existingItem = _items.firstWhereOrNull((item) => item.id == id);

    if (existingItem != null) {
      existingItem.quantity++;
    } else {
      _items.add(CartItem(id: id, title: title, price: price, quantity: 1));
    }
    notifyListeners();
  }


  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}

