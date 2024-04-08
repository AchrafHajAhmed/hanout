import 'package:flutter/material.dart';
import 'package:hanout/color.dart';

class MyTextFormField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String?>? onSaved;
  final bool obscureText;

  const MyTextFormField({
    Key? key,
    required this.hintText,
    this.controller,
    this.validator,
    this.onSaved,
    this.obscureText = false,
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
    crossAxisAlignment: CrossAxisAlignment.start;
    return TextFormField(
      controller: _controller,
      obscureText: _isObscured,
      validator: widget.validator,
      onSaved: widget.onSaved,
      style: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w900,
          fontSize: 16.0,),

      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(),
        suffixIcon: widget.obscureText ? IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        ) : null,
      ),
    );
  }
}
