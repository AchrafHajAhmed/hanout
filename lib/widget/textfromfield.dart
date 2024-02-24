import 'package:flutter/material.dart';

class textfromfield extends StatefulWidget {
  const textfromfield({super.key, required this.labelText});

  final String labelText;


  @override
  State<textfromfield> createState() => _textfromfieldState();
}

class _textfromfieldState extends State<textfromfield> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Veuillez entrer du text';
        }
        return null;
        },
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
