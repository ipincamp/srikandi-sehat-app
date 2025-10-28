import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomFormFieldType {
  text,
  email,
  password,
  number,
  date,
  dropdown,
}

class CustomFormField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final CustomFormFieldType type;
  final double borderRadius;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  // Dropdown properties
  final List<DropdownItem>? dropdownItems;
  final String? selectedValue;
  final Function(String?)? onDropdownChanged;
  final void Function(String)? onChanged;

  // Date picker properties
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime?)? onDateChanged;
  final String dateFormat; // 'dd/MM/yyyy', 'yyyy-MM-dd', etc.

  // Number properties
  final double? minValue;
  final double? maxValue;
  final int? decimalPlaces;
  final bool allowNegative;

  // General properties
  final bool enabled;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final dynamic isEmail;

  final dynamic isPassword;
  final dynamic items;
  final bool validatePasswordComplexity;

  final bool isMandatory;

  // onFieldSubmitted
  final Function(String)? onFieldSubmitted;

  const CustomFormField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.type = CustomFormFieldType.text,
    this.borderRadius = 10,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    // Dropdown
    this.dropdownItems,
    this.selectedValue,
    this.onDropdownChanged,
    this.onChanged,

    // Date
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateChanged,
    this.dateFormat = 'dd/MM/yyyy',
    // Number
    this.minValue,
    this.maxValue,
    this.decimalPlaces,
    this.allowNegative = true,
    // General
    this.enabled = true,
    this.maxLines = 1,
    this.textInputAction,
    this.isEmail = false,
    this.isPassword = false,
    this.items,
    this.isMandatory = true,
    this.validatePasswordComplexity = true,

    // onFieldSubmitted
    this.onFieldSubmitted,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  bool _obscureText = true;
  String? _selectedDropdownValue;
  DateTime? _selectedDate;

  bool _hasMinLength = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;
  bool _hasUppercase = false;

  get milliseconds => null;

  void _checkPasswordCriteria(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasNumber = RegExp(r'[0-9]').hasMatch(value);
      _hasSymbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value);
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    });
  }

  List<Widget> _buildPasswordCriteriaIndicator() {
    TextStyle baseStyle = Theme.of(context).textTheme.bodySmall!;
    Color activeColor = Colors.green;
    Color inactiveColor = Colors.grey;

    Widget buildCriteria(bool condition, String text) {
      return Row(
        children: [
          Icon(condition ? Icons.check_circle : Icons.cancel,
              size: 16, color: condition ? activeColor : inactiveColor),
          const SizedBox(width: 6),
          Text(text,
              style: baseStyle.copyWith(
                  color: condition ? activeColor : inactiveColor)),
        ],
      );
    }

    return [
      const SizedBox(height: 8),
      buildCriteria(_hasMinLength, "Minimal 8 karakter"),
      buildCriteria(_hasNumber, "Mengandung angka"),
      buildCriteria(_hasSymbol, "Mengandung simbol"),
      buildCriteria(_hasUppercase, "Mengandung huruf kapital"),
    ];
  }

  @override
  void initState() {
    super.initState();
    _obscureText = widget.type == CustomFormFieldType.password;
    _selectedDropdownValue = widget.selectedValue;
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: widget.label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            children: widget.isMandatory
                ? [
                    const TextSpan(
                      text: ' *', // Tambahkan spasi sebelum bintang
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        _buildFormField(),
      ],
    );
  }

  Widget _buildFormField() {
    switch (widget.type) {
      case CustomFormFieldType.dropdown:
        return _buildDropdownField();
      case CustomFormFieldType.date:
        return _buildDateField();
      default:
        return _buildTextFormField();
    }
  }

  Widget _buildTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          style: Theme.of(context).textTheme.bodyLarge,
          obscureText: _obscureText,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          keyboardType: _getKeyboardType(),
          inputFormatters: _getInputFormatters(),
          decoration: _getInputDecoration(),
          validator: widget.validator ?? _getDefaultValidator(),
          onChanged: (val) {
            widget.onChanged?.call(val);
            if (widget.type == CustomFormFieldType.password &&
                widget.validatePasswordComplexity) {
              _checkPasswordCriteria(val);
            }
            final num? number = double.tryParse(val);
            if (number != null) {
              if (widget.minValue != null && number < widget.minValue!) {
                // lakukan sesuatu, misalnya show error di UI
              }
              if (widget.maxValue != null && number > widget.maxValue!) {
                // lakukan sesuatu, misalnya reset atau show warning
              }
            }
          },
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: (widget.type == CustomFormFieldType.password &&
                  widget.validatePasswordComplexity &&
                  widget.controller.text.isNotEmpty &&
                  !(_hasMinLength && _hasNumber && _hasSymbol && _hasUppercase))
              ? Column(
                  key: const ValueKey('visible'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildPasswordCriteriaIndicator(),
                )
              : const SizedBox(key: ValueKey('hidden')),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    final List<DropdownItem> options = widget.dropdownItems ??
        (widget.items != null && widget.items is List<String>
            ? (widget.items as List<String>)
                .map((e) => DropdownItem(value: e, label: e))
                .toList()
            : <DropdownItem>[]);

    return DropdownButtonFormField<String>(
      value: _selectedDropdownValue?.isNotEmpty == true
          ? _selectedDropdownValue
          : null,
      items: options.map((item) {
        return DropdownMenuItem<String>(
          value: item.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 8),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  item.label,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: widget.enabled
          ? (value) {
              setState(() {
                _selectedDropdownValue = value;
              });
              widget.controller.text = value ?? '';
              widget.onDropdownChanged?.call(value);
            }
          : null,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.pink),
      dropdownColor: Colors.white,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: _getInputDecoration(),
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return '${widget.label} harus dipilih';
            }
            return null;
          },
      hint: Text(
        widget.placeholder,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: widget.controller,
      style: Theme.of(context).textTheme.bodyLarge,
      enabled: widget.enabled,
      readOnly: true,
      decoration: _getInputDecoration().copyWith(
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: widget.enabled ? () => _selectDate() : null,
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return '${widget.label} harus dipilih';
            }
            return null;
          },
    );
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: widget.enabled ? Colors.grey[100] : Colors.grey[50],
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
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      hintText: widget.placeholder,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
      prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
      suffixIcon: _getSuffixIcon(),
    );
  }

  Widget? _getSuffixIcon() {
    if (widget.type == CustomFormFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon != null ? Icon(widget.suffixIcon) : null;
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case CustomFormFieldType.email:
        return TextInputType.emailAddress;
      case CustomFormFieldType.number:
        return const TextInputType.numberWithOptions(decimal: true);
      case CustomFormFieldType.password:
        return TextInputType.visiblePassword;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    List<TextInputFormatter> formatters = [];

    if (widget.type == CustomFormFieldType.number) {
      // Allow numbers, decimal point, and negative sign if allowed
      String pattern = widget.allowNegative ? r'[0-9.-]' : r'[0-9.]';
      formatters.add(FilteringTextInputFormatter.allow(RegExp(pattern)));

      // Custom formatter for decimal places
      if (widget.decimalPlaces != null) {
        formatters.add(
            DecimalTextInputFormatter(decimalRange: widget.decimalPlaces!));
      }
    }

    return formatters;
  }

  String? Function(String?) _getDefaultValidator() {
    return (value) {
      if (value == null || value.isEmpty) {
        return '${widget.label} tidak boleh kosong';
      }

      switch (widget.type) {
        case CustomFormFieldType.email:
          if (!_isValidEmail(value)) {
            return 'Format email tidak valid';
          }
          break;
        case CustomFormFieldType.number:
          final numValue = double.tryParse(value);
          if (numValue == null) {
            return 'Harus berupa angka';
          }
          if (widget.minValue != null && numValue < widget.minValue!) {
            return 'Nilai minimal ${widget.minValue}';
          }
          if (widget.maxValue != null && numValue > widget.maxValue!) {
            return 'Nilai maksimal ${widget.maxValue}';
          }
          break;
        case CustomFormFieldType.password:
          if (widget.validatePasswordComplexity) {
            if (value.length < 8) {
              return 'Password minimal 8 karakter';
            }
            if (!RegExp(r'[0-9]').hasMatch(value)) {
              return 'Password harus mengandung angka';
            }
            if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
              return 'Password harus mengandung simbol';
            }
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return 'Password harus mengandung huruf kapital';
            }
          }
          break;
        default:
          break;
      }

      return null;
    };
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.pink,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });

      // Format date according to specified format
      String formattedDate = _formatDate(picked);
      widget.controller.text = formattedDate;
      widget.onDateChanged?.call(picked);
    }
  }

  String _formatDate(DateTime date) {
    switch (widget.dateFormat.toLowerCase()) {
      case 'yyyy-mm-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'mm/dd/yyyy':
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      case 'dd-mm-yyyy':
        return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      default: // 'dd/mm/yyyy'
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}

// Helper class for dropdown items
class DropdownItem {
  final String value;
  final String label;

  DropdownItem({required this.value, required this.label});
}

// Custom formatter for decimal places
class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    if (newText.isEmpty) {
      return newValue;
    }

    // Check for multiple decimal points
    if (newText.split('.').length > 2) {
      return oldValue;
    }

    // Check decimal places
    if (newText.contains('.')) {
      String afterDecimal = newText.split('.')[1];
      if (afterDecimal.length > decimalRange) {
        return oldValue;
      }
    }

    return newValue;
  }
}
