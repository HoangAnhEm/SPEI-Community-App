import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HouseholdInfoCard extends StatelessWidget {
  final String householdName;
  final int memberCount;
  final String ownerName;
  final bool isOwner;

  const HouseholdInfoCard({
    super.key,
    required this.householdName,
    required this.memberCount,
    required this.ownerName,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  householdName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              Text(
                isOwner ? 'Chủ hộ' : 'Thành viên',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$memberCount người • Chủ hộ: $ownerName',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.subText,
            ),
          ),
        ],
      ),
    );
  }
}
