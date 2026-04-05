import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final IconData? icon;
  final double height;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.icon,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color ?? AppColors.primary, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _buildChild(color ?? AppColors.primary),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isLoading || onPressed == null
              ? null
              : AppColors.primaryGradient,
          color: isLoading || onPressed == null ? AppColors.textHint : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading || onPressed == null
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _buildChild(Colors.white),
        ),
      ),
    );
  }

  Widget _buildChild(Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: isOutlined ? AppColors.primary : Colors.white,
          strokeWidth: 2.5,
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ],
      );
    }
    return Text(label,
        style: TextStyle(
            color: textColor, fontSize: 16, fontWeight: FontWeight.w600));
  }
}
