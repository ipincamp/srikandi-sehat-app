import 'package:flutter/material.dart';

class CustomFormField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool isPassword;
  final bool isEmail;
  final double borderRadius;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  const CustomFormField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.isPassword = false,
    this.isEmail = false,
    this.borderRadius = 10,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          style: Theme.of(context).textTheme.bodyLarge,
          obscureText: _obscureText,
          keyboardType:
              widget.isEmail ? TextInputType.emailAddress : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.pink),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            hintText: widget.placeholder,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            prefixIcon:
                widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : (widget.suffixIcon != null ? Icon(widget.suffixIcon) : null),
          ),
          validator: widget.validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return '${widget.label} tidak boleh kosong';
                }
                if (widget.isEmail && !_isValidEmail(value)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
        ),
      ],
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }
}
