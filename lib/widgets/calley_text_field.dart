import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CalleyTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final dynamic suffixIcon; // accepts Widget or IconData
  final Widget? prefixIcon;
  final VoidCallback? onSuffixIconTap;
  final String? Function(String?)? validator;

  const CalleyTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIcon,
    this.onSuffixIconTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    Widget? builtSuffix;
    if (suffixIcon is IconData) {
      builtSuffix = IconButton(
        icon: Icon(suffixIcon as IconData, size: 20, color: AppColors.textLight),
        onPressed: onSuffixIconTap,
      );
    } else if (suffixIcon is Widget) {
      builtSuffix = onSuffixIconTap != null
          ? GestureDetector(onTap: onSuffixIconTap, child: suffixIcon as Widget)
          : suffixIcon as Widget;
    }

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textDark,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.textLight,
          fontSize: 13,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: prefixIcon,
        suffixIcon: builtSuffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.0),
        ),
      ),
    );
  }
}
