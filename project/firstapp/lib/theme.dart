import 'package:flutter/material.dart';

class AppColors {
  static const Color background    = Color(0xFF0D0F1C);
  static const Color surface       = Color(0xFF171929);
  static const Color surfaceLight  = Color(0xFF1F2136);
  static const Color primary       = Color(0xFF6B46E8);
  static const Color primaryLight  = Color(0xFF4B8AFF);
  static const Color success       = Color(0xFF00D09E);
  static const Color danger        = Color(0xFFFF4D6D);
  static const Color warning       = Color(0xFFFFB800);
  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xFF7B7F9E);
  static const Color border        = Color(0xFF262840);
}

const kGradient = LinearGradient(
  colors: [Color(0xFF6B46E8), Color(0xFF4B8AFF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

InputDecoration kDarkInput({
  required String label,
  String? hint,
  Widget? prefixIcon,
  String? suffixText,
}) {
  return InputDecoration(
    labelText: label.isEmpty ? null : label,
    hintText: hint,
    prefixIcon: prefixIcon,
    suffixText: suffixText,
    suffixStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
    labelStyle: const TextStyle(color: AppColors.textSecondary),
    hintStyle: const TextStyle(color: AppColors.textSecondary),
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}

Widget kGradientButton({
  required String text,
  required VoidCallback? onPressed,
  bool isLoading = false,
}) {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      gradient: onPressed == null ? null : kGradient,
      color: onPressed == null ? AppColors.surfaceLight : null,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: onPressed == null ? AppColors.textSecondary : Colors.white,
                  ),
                ),
        ),
      ),
    ),
  );
}

AppBar kDarkAppBar({required String title, required BuildContext context, List<Widget>? actions}) {
  return AppBar(
    backgroundColor: AppColors.background,
    elevation: 0,
    leading: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
      ),
    ),
    title: Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
    ),
    actions: actions,
  );
}
