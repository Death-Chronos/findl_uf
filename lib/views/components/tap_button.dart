import 'package:flutter/material.dart';

class TapButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color color;



  const TapButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                shadowColor: Colors.black.withValues(
                  alpha: 0.3,
                ), // substitui withOpacity
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            );
  }
}