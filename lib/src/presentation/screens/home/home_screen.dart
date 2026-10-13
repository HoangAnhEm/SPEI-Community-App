import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/household/household_cubit.dart';
import '../../blocs/household/household_state.dart';
import '../../blocs/emission/emission_cubit.dart';
import '../../blocs/emission/emission_state.dart';
import '../../blocs/incident/incident_cubit.dart';
import '../../blocs/incident/incident_state.dart';
import '../../blocs/reward/reward_cubit.dart';
import '../../blocs/reward/reward_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hhCubit = context.read<HouseholdCubit>();
      if (hhCubit.state.status == HouseholdStatus.initial) {
        hhCubit.loadHouseholdData();
      }

      final emissionCubit = context.read<EmissionCubit>();
      if (emissionCubit.state.status == EmissionStatus.initial) {
        emissionCubit.loadEmissions();
      }

      final incCubit = context.read<IncidentCubit>();
      if (incCubit.state.status == IncidentListStatus.initial) {
        incCubit.loadMyIncidents();
      }

      final rewardCubit = context.read<RewardCubit>();
      if (rewardCubit.state.status == RewardLoadingStatus.initial) {
        rewardCubit.loadRewardData();
      }
    });
  }

  String _formatCurrentDate(DateTime now) {
    const weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    final weekday = weekdays[now.weekday - 1];
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    return '$weekday, $day tháng $month';
  }

  String _getShortName(String fullName) {
    if (fullName.trim().isEmpty) return '';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.last;
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildGreeting(),
              const SizedBox(height: 24),
              const _EmissionSummaryCard(),
              const SizedBox(height: 16),
              _buildPointsCard(),
              const SizedBox(height: 18),
              const Text(
                'Hôm nay mình làm gì?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 18),
              _buildGridMenu(context),
              const SizedBox(height: 12),
              _buildTaskCard(),
              const SizedBox(height: 18),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/icons/logo.png',
          width: 50,
          height: 38,
          errorBuilder: (context, error, stackTrace) => const CircleAvatar(
            backgroundColor: AppColors.successBg,
            radius: 16,
            child: Icon(Icons.eco, color: AppColors.primary, size: 16),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'SPEI Community',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
        ),
        IconButton(
          icon: Image.asset(
            'assets/icons/ic_notification.png',
            width: 24,
            height: 24,
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.notifications_none, color: AppColors.primary),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Image.asset(
            'assets/icons/ic_user.png',
            width: 24,
            height: 24,
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.person_outline, color: AppColors.primary),
          ),
          onPressed: () {
            context.push('/profile');
          },
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    final now = DateTime.now();
    final dateStr = _formatCurrentDate(now);

    final authState = context.watch<AuthBloc>().state;
    final householdState = context.watch<HouseholdCubit>().state;

    final user = authState is AuthAuthenticated ? authState.user : null;
    final household = householdState.household;

    final String line1;
    final String line2;

    if (household != null) {
      final userName = user?.fullName.trim() ?? '';
      final shortName = _getShortName(userName);
      final hhName = household.name.trim();

      if (household.members.length > 1) {
        line1 = 'Chào ${shortName.isNotEmpty ? shortName : 'cả nhà'},';
        line2 = 'và $hhName!';
      } else {
        line1 = 'Chào ${shortName.isNotEmpty ? shortName : 'bạn'},';
        line2 = '$hhName!';
      }
    } else {
      final fullName = user?.fullName.trim() ?? '';
      if (fullName.isNotEmpty) {
        line1 = 'Chào $fullName,';
        line2 = 'ngày xanh an lành!';
      } else {
        line1 = 'Chào bạn,';
        line2 = 'ngày xanh an lành!';
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr,
                style: const TextStyle(fontSize: 12, color: AppColors.subText),
              ),
              const SizedBox(height: 8),
              Text(
                '$line1\n$line2',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            color: AppColors.successBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/ic_sprout_smile.png',
              width: 68,
              height: 68,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.eco, color: AppColors.primary, size: 30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration( 
        color: const Color(0xFFFFF3D9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/ic_leaf_outline.png',
            width: 28,
            height: 28,
            color: AppColors.primary,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.eco_outlined, color: Color(0xFF5A7B45)),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Điểm xanh của cả nhà',
                  style: TextStyle(fontSize: 12, color: AppColors.subText),
                ),
                SizedBox(height: 2),
                Text(
                  '1.250 điểm',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Text(
                'Xem ví',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(
                'assets/icons/ic_arrow_right.png',
                width: 16,
                height: 16,
                color: AppColors.primary,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildGridItem(
          'assets/icons/feature_electric.png',
          AppColors.primary,
          AppColors.successBg,
          'Tính nhanh phát thải',
          'Ước tính tức thì',
          onTap: () {
            context.push('/emission/quick-calc/select-type');
          },
        ),
        _buildGridItem(
          'assets/icons/ic_chat_bubble.png',
          AppColors.bluePrimary,
          AppColors.blueBg,
          'Hỏi bạn Mầm AI',
          'Học xanh cùng con',
        ),
        _buildGridItem(
          'assets/icons/ic_camera.png',
          AppColors.bluePrimary,
          AppColors.blueBg,
          'Gửi phản ánh',
          'Góp ý môi trường',
          onTap: () {
            context.push('/incidents/create');
          },
        ),
        _buildGridItem(
          'assets/icons/feature_gift.png',
          AppColors.primary,
          AppColors.successBg,
          'Đổi quà xanh',
          'Quà cho cả nhà',
        ),
      ],
    );
  }

  Widget _buildGridItem(
    String iconAsset,
    Color iconColor,
    Color iconBgColor,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                iconAsset,
                width: 22,
                height: 22,
                color: iconColor,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.widgets_outlined, color: iconColor, size: 20),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.subText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7 ngày tắt thiết bị',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                '+50 điểm',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Cùng bé An kiểm tra đèn và quạt trước khi ra khỏi phòng.',
            style: TextStyle(fontSize: 13, color: AppColors.subText, height: 1.4),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8DC),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 6,
                width: 150,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '4/7 ngày • Chưa nhận điểm',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thẻ xanh hiển thị Kwh / Co2 ước tính và luân phiên các phân loại phát thải khác
class _EmissionSummaryCard extends StatefulWidget {
  const _EmissionSummaryCard();

  @override
  State<_EmissionSummaryCard> createState() => _EmissionSummaryCardState();
}

class _EmissionSummaryCardState extends State<_EmissionSummaryCard> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;
  int _itemsCount = 5;

  static const List<EmissionMetricItem> _defaultDemoItems = [
    EmissionMetricItem(
      category: 'electricity',
      title: 'Điện gia đình • SPEI Community',
      primaryValue: '--',
      primaryUnit: 'kWh sử dụng',
      co2eKg: '0,0',
      changeText: 'Tạo hoặc tham gia hộ để theo dõi phát thải cả nhà',
      isDecrease: true,
    ),
    EmissionMetricItem(
      category: 'transportation',
      title: 'Phương tiện • SPEI Community',
      primaryValue: '--',
      primaryUnit: 'lít nhiên liệu sử dụng',
      co2eKg: '0,0',
      changeText: 'Tạo hoặc tham gia hộ để theo dõi phát thải cả nhà',
      isDecrease: true,
    ),
    EmissionMetricItem(
      category: 'gas',
      title: 'Khí đốt Gas • SPEI Community',
      primaryValue: '--',
      primaryUnit: 'kg gas sử dụng',
      co2eKg: '0,0',
      changeText: 'Tạo hoặc tham gia hộ để theo dõi phát thải cả nhà',
      isDecrease: true,
    ),
    EmissionMetricItem(
      category: 'waste',
      title: 'Rác thải • SPEI Community',
      primaryValue: '--',
      primaryUnit: 'kg rác phát sinh',
      co2eKg: '0,0',
      changeText: 'Tạo hoặc tham gia hộ để theo dõi phát thải cả nhà',
      isDecrease: true,
    ),
    EmissionMetricItem(
      category: 'refrigerant',
      title: 'Môi chất lạnh • SPEI Community',
      primaryValue: '--',
      primaryUnit: 'kg môi chất lạnh',
      co2eKg: '0,0',
      changeText: 'Tạo hoặc tham gia hộ để theo dõi phát thải cả nhà',
      isDecrease: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      if (_itemsCount <= 1) return;
      final nextPage = (_currentIndex + 1) % _itemsCount;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _resetTimer() {
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final householdState = context.watch<HouseholdCubit>().state;
    final emissionState = context.watch<EmissionCubit>().state;

    final hasHousehold = householdState.household != null;

    final List<EmissionMetricItem> items =
        hasHousehold && emissionState.metricItems.isNotEmpty
            ? emissionState.metricItems
            : _defaultDemoItems;

    _itemsCount = items.length;
    final safeIndex = items.isEmpty ? 0 : (_currentIndex % items.length);

    return InkWell(
      onTap: () {
        if (hasHousehold) {
          context.push('/emission/history');
        } else {
          context.push('/family/create');
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          height: 130,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  _resetTimer();
                },
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildPageItem(item, hasHousehold);
                },
              ),
              // Dots chỉ báo và mũi tên cố định góc trên bên phải
              Positioned(
                top: 0,
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (items.length > 1)
                      Row(
                        children: List.generate(items.length, (i) {
                          final isSelected = safeIndex == i;
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOutCubic,
                              );
                              _resetTimer();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 4),
                              width: isSelected ? 14 : 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        }),
                      ),
                    const SizedBox(width: 6),
                    Image.asset(
                      'assets/icons/ic_arrow_up_right.png',
                      width: 18,
                      height: 18,
                      color: Colors.white,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.arrow_outward, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageItem(EmissionMetricItem item, bool hasHousehold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tiêu đề phân loại (chừa padding bên phải cho dots & icon)
        Padding(
          padding: const EdgeInsets.only(right: 84),
          child: Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 12),

        // 2. Cặp thông số chính & CO2e ước tính
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.primaryValue,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.primaryUnit,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.co2eKg,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.co2eUnit,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Khung bên dưới: So sánh tăng/giảm % hoặc CTA tham gia hộ
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: hasHousehold
              ? Row(
                  children: [
                    Icon(
                      item.isDecrease ? Icons.trending_down : Icons.trending_up,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.changeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : const Row(
                  children: [
                    Icon(Icons.group_add_outlined, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tạo hoặc tham gia hộ để theo dõi phát thải cả nhà',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                  ],
                ),
        ),
      ],
    );
  }
}

