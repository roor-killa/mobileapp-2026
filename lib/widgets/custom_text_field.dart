import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final bool enabled;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint),
            counterText: '',
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
