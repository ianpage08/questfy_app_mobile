import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:questfy_app_mobile/core/theme/app.colors.dart';

class ProgressCard extends StatelessWidget {
  final int level;
  final double percent;
  final String xp;

  const ProgressCard({
    super.key,
    required this.level,
    required this.percent,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nível $level",
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${(percent * 100).toInt()}%",
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 8.0,
            percent: percent,
            barRadius: const Radius.circular(10),
            backgroundColor: AppColors.cardBorder,
            progressColor: AppColors.accent,
            animation: true,
          ),
          const SizedBox(height: 10),
          Text(
            "$xp / 100 XP para o próximo nível",
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
