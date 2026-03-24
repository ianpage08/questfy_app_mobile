import 'package:flutter/material.dart';
import 'package:questfy_app_mobile/core/theme/app.colors.dart';


class StatusHeader extends StatelessWidget {
  final int streak;
  final int shields;

  const StatusHeader({super.key, required this.streak, required this.shields});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Questify",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Row(
            children: [
              _StatusChip(
                icon: Icons.local_fire_department,
                value: "$streak",
                color: AppColors.fire,
              ),
              const SizedBox(width: 12),
              _StatusChip(
                icon: Icons.shield,
                value: "$shields",
                color: AppColors.shield,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
