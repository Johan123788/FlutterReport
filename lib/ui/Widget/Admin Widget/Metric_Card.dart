
import 'package:flutter/material.dart';
import 'package:ojociudadano/ui/screens/Administrador/admin_theme.dart';    


  class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool wide;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: wide ? 20 : 16,
      ),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: wide
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AdminTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AdminTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
    );
  }
}