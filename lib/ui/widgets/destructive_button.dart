import 'package:eventura/ui/shared/app_colors.dart';
import 'package:flutter/material.dart';

class DestructiveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String label;
  final IconData icon;

  const DestructiveButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorRed,
          foregroundColor: Colors.white,
        ),

        onPressed: onPressed,
        child:
            isLoading
                ? const CircularProgressIndicator()
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20, color: Colors.white),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
