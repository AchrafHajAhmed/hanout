import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextFormField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String?>? onSaved;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters; // Adding inputFormatters as a parameter

  const MyTextFormField({
    Key? key,
    required this.hintText,
    this.controller,
    this.validator,
    this.onSaved,
    this.obscureText = false,
    this.inputFormatters,
  }) : super(key: key);

  @override
  _MyTextFormFieldState createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  late final TextEditingController _controller;
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _isObscured = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      obscureText: _isObscured,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(),
        suffixIcon: widget.obscureText ? IconButton(
          icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() => _isObscured = !_isObscured);
          },
        ) : null,
      ),
      validator: widget.validator,
      onSaved: widget.onSaved,
      inputFormatters: widget.inputFormatters,
    );
  }
}



