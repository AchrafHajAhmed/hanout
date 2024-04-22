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
      body: Column(
        children: <Widget>[
          RadioListTile<String>(
            title: Text('livraison'),
            value: 'livraison',
            groupValue: _deliveryMethod,
            onChanged: (value) {
              setState(() {
                _deliveryMethod = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: Text('retrait de magasin'),
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
            child: MyElevatedButton(buttonText: 'Confirm',  onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyAccount()));
            },),
          ),
        ],
      ),
    );
  }

  void confirmDeliveryMethod() {
    // Logic to confirm delivery method
    print('Méthode de livraison choisie : $_deliveryMethod');
  }
}
