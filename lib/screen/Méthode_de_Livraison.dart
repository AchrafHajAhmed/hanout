import 'package:flutter/material.dart';
import 'package:hanout/screen/My_Account/My_Account.dart';
import 'package:hanout/widget/elevated_button.dart';

class MethodesDeLivraison extends StatefulWidget {
  @override
  _MethodesDeLivraisonState createState() => _MethodesDeLivraisonState();
}

class _MethodesDeLivraisonState extends State<MethodesDeLivraison> {
  String _deliveryMethod = 'livraison';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Méthode de Livraison'),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            RadioListTile<String>(
              title: Text('Livraison'),
              value: 'livraison',
              groupValue: _deliveryMethod,
              onChanged: (value) {
                setState(() {
                  _deliveryMethod = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Retrait en magasin'),
              value: 'retrait',
              groupValue: _deliveryMethod,
              onChanged: (value) {
                setState(() {
                  _deliveryMethod = value!;
                });
              },
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MyElevatedButton(
                buttonText: 'Confirmer',
                onPressed: () {
                  _confirmDeliveryMethod();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeliveryMethod() async {

    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la méthode de livraison'),
        content: Text('Êtes-vous sûr(e) de vouloir choisir $_deliveryMethod comme méthode de livraison ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      print('Méthode de livraison choisie : $_deliveryMethod');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyAccount()),
      );
    }
  }
}

