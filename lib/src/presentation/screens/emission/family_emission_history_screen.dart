import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../src/core/constants/app_colors.dart';
import '../../../domain/entities/emission_details.dart';
import '../../../domain/entities/household_emission.dart';
import '../../blocs/emission/emission_cubit.dart';

/// Màu sắc nhận diện từng phân loại phát thải theo thiết kế chuẩn
class EmissionCategoryTheme {
  static const Color electricity = Color(0xFF2E7D32); // Xanh lá đậm
  static const Color gas = Color(0xFF8BC34A); // Xanh nõn chuối
  static const Color waste = Color(0xFFA5D6A7); // Xanh pastel
  static const Color refrigerant = Color(0xFFB06F28); // Nâu hổ phách
  static const Color transportation = Color(0xFF42A5F5); // Xanh dương
  static const Color unrecorded = Color(0xFFD6D6D6); // Xám chưa nhập

  static Color getColor(String category) {
    switch (category) {
      case EmissionCategory.electricity:
        return electricity;
      case EmissionCategory.gas:
        return gas;
      case EmissionCategory.waste:
        return waste;
      case EmissionCategory.refrigerant:
        return refrigerant;
      case EmissionCategory.transportation:
        return transportation;
      default:
        return AppColors.primary;
    }
  }

  static IconData getIcon(String category) {
    switch (category) {
      case EmissionCategory.electricity:
        return Icons.bolt;
      case EmissionCategory.gas:
        return Icons.local_fire_department;
      case EmissionCategory.waste:
        return Icons.delete_outline;
      case EmissionCategory.refrigerant:
        return Icons.ac_unit;
      case EmissionCategory.transportation:
        return Icons.two_wheeler;
      default:
        return Icons.eco;
    }
  }
}

/// Màn hình Lịch sử phát thải gia đình - 100% sử dụng dữ liệu thực từ API
class FamilyEmissionHistoryScreen extends StatefulWidget {
  final int? initialYear;
  final int? initialMonth;

  const FamilyEmissionHistoryScreen({
    super.key,
    this.initialYear,
    this.initialMonth,
  });

  @override
  State<FamilyEmissionHistoryScreen> createState() =>
      _FamilyEmissionHistoryScreenState();
}

class _FamilyEmissionHistoryScreenState
    extends State<FamilyEmissionHistoryScreen> {
  late int _selectedYear;
  late int _selectedMonth;

  // Tab lọc danh sách bản ghi: 5 phân loại theo yêu cầu người dùng
  int _selectedCategoryTabIndex = 0;
  static const List<String> _categoryTabs = [
    EmissionCategory.electricity,
    EmissionCategory.gas,
    EmissionCategory.waste,
    EmissionCategory.refrigerant,
    EmissionCategory.transportation,
  ];

  static const Map<String, String> _categoryTabLabels = {
    EmissionCategory.electricity: 'Điện',
    EmissionCategory.gas: 'Gas',
    EmissionCategory.waste: 'Rác & nước',
    EmissionCategory.refrigerant: 'Môi chất lạnh',
    EmissionCategory.transportation: 'Phương tiện',
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = widget.initialYear ?? now.year;
    _selectedMonth = widget.initialMonth ?? now.month;

    // Tải dữ liệu phát thải thực tế từ API cho tháng đang chọn và tháng trước đó
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<EmissionCubit>().loadEmissions(
          year: _selectedYear,
          month: _selectedMonth,
        );
  }

  void _changeMonth(int delta) {
    final newDate = DateTime(_selectedYear, _selectedMonth + delta, 1);
    setState(() {
      _selectedYear = newDate.year;
      _selectedMonth = newDate.month;
    });
    _loadData();
  }

  void _selectMonthYear(int year, int month) {
    setState(() {
      _selectedYear = year;
      _selectedMonth = month;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final emissionState = context.watch<EmissionCubit>().state;
    final curMM = _selectedMonth.toString().padLeft(2, '0');

    // 100% Dữ liệu thực từ API Backend
    final currentRecords = emissionState.currentMonthEmissions;
    final previousRecords = emissionState.previousMonthEmissions;

    // Tính toán số liệu tổng hợp từ dữ liệu thực
    final currentTotalCo2e = currentRecords.fold<double>(
        0.0, (prev, element) => prev + element.co2eKg);

    final previousTotalCo2e = previousRecords.fold<double>(
        0.0, (prev, element) => prev + element.co2eKg);

    final diffCo2e = currentTotalCo2e - previousTotalCo2e;

    // Kiểm tra các nhóm đã có dữ liệu thực
    final recordedCategories = <String>{};
    for (final r in currentRecords) {
      recordedCategories.add(r.category);
    }
    final recordedCount = recordedCategories.length;
    final unrecordedCount = 5 - recordedCount;
    final unrecordedLabels = _categoryTabs
        .where((c) => !recordedCategories.contains(c))
        .map((c) => _categoryTabLabels[c] ?? c)
        .toList();

    // Lọc bản ghi theo Tab phân loại đang chọn
    final activeCategory = _categoryTabs[_selectedCategoryTabIndex];
    final filteredRecords = currentRecords
        .where((r) => r.category == activeCategory)
        .toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBF8), // Nền kem thanh nhã theo thiết kế
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header trên cùng
            _buildHeader(context),

            // Thanh báo loading khi API đang gọi
            if (emissionState.isLoading)
              const LinearProgressIndicator(
                minHeight: 2.5,
                backgroundColor: Color(0xFFE8F5E9),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),

            // 2. Nội dung cuộn chính có tính năng vuốt để làm mới (Pull-to-refresh)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _loadData(),
                color: const Color(0xFF2E7D32),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thanh chọn tháng có 2 nút chuyển nhanh và nút popup
                      _buildMonthNavigatorBar(curMM),
                      const SizedBox(height: 16),

                      // Card 1: Tổng phát thải đã ghi nhận từ API
                      _buildTotalEmissionCard(
                        currentTotalCo2e: currentTotalCo2e,
                        recordedCount: recordedCount,
                        unrecordedCount: unrecordedCount,
                        unrecordedLabels: unrecordedLabels,
                        diffCo2e: diffCo2e,
                        prevMonth: _getPrevMonthNumber(),
                        hasPreviousData: previousRecords.isNotEmpty,
                      ),
                      const SizedBox(height: 16),

                      // Card 2: Phân loại phát thải đã ghi nhận tháng MM (Donut chart & Legend thực)
                      _buildClassificationDonutCard(
                        curMM: curMM,
                        records: currentRecords,
                        totalCo2e: currentTotalCo2e,
                        recordedCount: recordedCount,
                        unrecordedLabels: unrecordedLabels,
                      ),
                      const SizedBox(height: 22),

                      // Section 3: Tiêu đề bản ghi tháng & TabBar 5 phân loại
                      _buildRecordsSectionHeader(currentRecords.length, curMM),
                      const SizedBox(height: 12),

                      // Tab bar lọc 5 phân loại
                      _buildCategoryTabBar(currentRecords),
                      const SizedBox(height: 14),

                      // Danh sách bản ghi theo tab được chọn từ API
                      _buildFilteredRecordsList(
                        records: filteredRecords,
                        activeCategory: activeCategory,
                        curMM: curMM,
                      ),
                      const SizedBox(height: 20),

                      // Section 4: Item tháng trước (dữ liệu thực từ API)
                      _buildPreviousMonthCard(
                        previousRecords: previousRecords,
                        previousTotalCo2e: previousTotalCo2e,
                      ),
                      const SizedBox(height: 24),

                      // Section 5: Nút Nhập dữ liệu tháng MM ở cuối trang
                      _buildInputDataBottomButton(curMM),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  /// 1. Header trên cùng: Nút quay lại, Tiêu đề, Logo hộ gia đình
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          // Nút quay lại bo tròn
          InkWell(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1E5128),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Tiêu đề & phụ đề
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phát thải gia đình',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2E1E),
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tổng hợp và nhập liệu phát thải theo tháng',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Logo avatar hộ gia đình
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
              color: Colors.white,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/icons/circle_center_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset('assets/icons/logo.png', fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Thanh chọn tháng: `<` [Tháng MM/yyyy] `>`
  Widget _buildMonthNavigatorBar(String curMM) {
    return Row(
      children: [
        // Nút lùi 1 tháng
        _buildNavChevronButton(
          icon: Icons.chevron_left,
          onTap: () => _changeMonth(-1),
        ),
        const SizedBox(width: 8),

        // Nút trung tâm chọn tháng cụ thể (chạm mở bottom modal)
        Expanded(
          child: InkWell(
            onTap: _showMonthPickerModal,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tháng $curMM/$_selectedYear',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B2E1E),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Nút tiến 1 tháng
        _buildNavChevronButton(
          icon: Icons.chevron_right,
          onTap: () => _changeMonth(1),
        ),
      ],
    );
  }

  Widget _buildNavChevronButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.grey.shade700, size: 22),
      ),
    );
  }

  /// 3. Card 1: Tổng phát thải đã ghi nhận
  Widget _buildTotalEmissionCard({
    required double currentTotalCo2e,
    required int recordedCount,
    required int unrecordedCount,
    required List<String> unrecordedLabels,
    required double diffCo2e,
    required int prevMonth,
    required bool hasPreviousData,
  }) {
    final prevMM = prevMonth.toString().padLeft(2, '0');
    final formattedTotal = _formatCo2(currentTotalCo2e);

    String trendText;
    bool isDecrease = true;
    if (!hasPreviousData) {
      trendText =
          'Dữ liệu kỳ đầu tiên · ${unrecordedCount > 0 ? 'Chưa nhập $unrecordedCount nhóm' : 'Đã nhập đủ 5 nhóm'}';
    } else if (diffCo2e < 0) {
      isDecrease = true;
      final diffAbs = _formatCo2(diffCo2e.abs());
      trendText =
          '↓ Giảm $diffAbs kg CO₂e so với tháng $prevMM · ${unrecordedCount > 0 ? 'Chưa nhập $unrecordedCount nhóm' : 'Đã nhập đủ 5 nhóm'}';
    } else if (diffCo2e > 0) {
      isDecrease = false;
      final diffAbs = _formatCo2(diffCo2e);
      trendText =
          '↑ Tăng $diffAbs kg CO₂e so với tháng $prevMM · ${unrecordedCount > 0 ? 'Chưa nhập $unrecordedCount nhóm' : 'Đã nhập đủ 5 nhóm'}';
    } else {
      trendText =
          'Không đổi so với tháng $prevMM · ${unrecordedCount > 0 ? 'Chưa nhập $unrecordedCount nhóm' : 'Đã nhập đủ 5 nhóm'}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F3), // Xanh pastel êm dịu
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EFE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề & Badge số nhóm
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng phát thải đã ghi nhận',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '$recordedCount/5 nhóm',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Số lượng CO2e lớn
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formattedTotal,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF143E26),
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'kg CO₂e',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF143E26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Dòng thông báo tăng giảm so với tháng trước
          Text(
            trendText,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: isDecrease
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
            ),
          ),
          const SizedBox(height: 12),

          const Divider(color: Color(0xFFDDEEE1), height: 1),
          const SizedBox(height: 10),

          // Ghi chú động theo các nhóm chưa nhập thực tế
          Text(
            unrecordedLabels.isNotEmpty
                ? '${unrecordedLabels.join(", ")} chưa nhập dữ liệu.'
                : 'Đã hoàn tất nhập liệu cho toàn bộ 5 nhóm phát thải tháng này.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Card 2: Biểu đồ Donut và Bảng chú thích phân loại
  Widget _buildClassificationDonutCard({
    required String curMM,
    required List<HouseholdEmission> records,
    required double totalCo2e,
    required int recordedCount,
    required List<String> unrecordedLabels,
  }) {
    // Nhóm phát thải thực tế theo từng category
    final categoryTotals = <String, double>{};
    for (final cat in _categoryTabs) {
      final sum = records
          .where((r) => r.category == cat)
          .fold<double>(0.0, (prev, e) => prev + e.co2eKg);
      categoryTotals[cat] = sum;
    }

    final segments = _categoryTabs.map((cat) {
      final val = categoryTotals[cat] ?? 0.0;
      return DonutChartSegment(
        category: cat,
        value: val,
        color: val > 0
            ? EmissionCategoryTheme.getColor(cat)
            : EmissionCategoryTheme.unrecorded,
      );
    }).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân loại phát thải đã ghi nhận tháng $curMM',
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2E1E),
            ),
          ),
          const SizedBox(height: 20),

          // Donut Chart + Chú thích bên phải
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Biểu đồ tròn dạng Donut
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(130, 130),
                      painter: _DonutChartPainter(
                        segments: segments,
                        strokeWidth: 22,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$recordedCount/5',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF143E26),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'nhóm',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Bảng chú thích từng phân loại
              Expanded(
                child: Column(
                  children: _categoryTabs.map((cat) {
                    final val = categoryTotals[cat] ?? 0.0;
                    final hasData = val > 0;
                    final pct = totalCo2e > 0 && hasData
                        ? (val / totalCo2e * 100).toStringAsFixed(2).replaceAll('.', ',')
                        : null;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.5),
                      child: Row(
                        children: [
                          Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: hasData
                                  ? EmissionCategoryTheme.getColor(cat)
                                  : EmissionCategoryTheme.unrecorded,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getCategoryDisplayLabel(cat),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: hasData
                                        ? const Color(0xFF1B2E1E)
                                        : Colors.grey.shade500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  hasData ? '$pct% · kg CO₂e' : 'Chưa nhập',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            hasData ? _formatCo2(val) : '—',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: hasData
                                  ? const Color(0xFF1B2E1E)
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Khung thông tin động
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recordedCount == 0
                        ? 'Chưa có bản ghi phát thải nào trong tháng $curMM.'
                        : (unrecordedLabels.isNotEmpty
                            ? 'Biểu đồ hiển thị $recordedCount nhóm đã nhập. Tổng ${_formatCo2(totalCo2e)} kg CO₂e chưa bao gồm ${unrecordedLabels.join(", ")}.'
                            : 'Biểu đồ hiển thị đầy đủ cả 5 nhóm phân loại phát thải đã ghi nhận.'),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade700,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Tiêu đề mục bản ghi
  Widget _buildRecordsSectionHeader(int totalCount, String curMM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Bản ghi tháng $curMM/$_selectedYear',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2E1E),
          ),
        ),
        Text(
          '$totalCount bản ghi',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// 6. Tab bar 5 phân loại theo yêu cầu người dùng
  Widget _buildCategoryTabBar(List<HouseholdEmission> allRecords) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categoryTabs.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categoryTabs[index];
          final isSelected = _selectedCategoryTabIndex == index;
          final catCount =
              allRecords.where((r) => r.category == cat).length;
          final label = _categoryTabLabels[cat] ?? cat;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategoryTabIndex = index;
              });
            },
            borderRadius: BorderRadius.circular(19),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1E5128)
                      : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1E5128).withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  catCount > 0 ? '$label ($catCount)' : label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 7. Danh sách bản ghi đã lọc theo tab
  Widget _buildFilteredRecordsList({
    required List<HouseholdEmission> records,
    required String activeCategory,
    required String curMM,
  }) {
    if (records.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              EmissionCategoryTheme.getIcon(activeCategory),
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _getCategoryDisplayLabel(activeCategory),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chưa có bản ghi nào cho phân loại này trong tháng $curMM',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 14),
            // ElevatedButton(
            //   onPressed: () {
            //     context.push('/emission/entry', extra: {
            //       'year': _selectedYear,
            //       'month': _selectedMonth,
            //       'category': activeCategory,
            //     });
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: const Color(0xFF2E7D32),
            //     foregroundColor: Colors.white,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            //   ),
            //   child: Text(
            //     '+ Nhập ${_categoryTabLabels[activeCategory] ?? "phân loại này"}',
            //     style: const TextStyle(
            //       fontSize: 13,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(record);
      },
    );
  }

  /// Card từng bản ghi phát thải thực tế
  Widget _buildRecordCard(HouseholdEmission record) {
    final catColor = EmissionCategoryTheme.getColor(record.category);
    final catIcon = EmissionCategoryTheme.getIcon(record.category);
    final formattedCo2 = _formatCo2(record.co2eKg);

    // Tiêu đề bản ghi
    final title = record.details.sourceLabel?.isNotEmpty == true
        ? record.details.sourceLabel!
        : _getDefaultSourceTitle(record);

    // Phụ đề phân loại chi tiết
    final subtitle = _getRecordSubtitle(record);

    // Ngày nhập
    final dt = record.createdAt;
    final dateStr =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

    // Đơn vị và lượng tiêu thụ gốc
    final primaryMeasurement = _getPrimaryMeasurementText(record);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Icon phân loại + Tên bản ghi + Ngày nhập
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: catColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(catIcon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2E1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Nhập ngày $dateStr',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Lượng CO2e và Đơn vị gốc
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$formattedCo2 kg CO₂e',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2E1E),
                ),
              ),
              Text(
                primaryMeasurement,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 8),

          // 3. Hai nút: Xem chi tiết & Chỉnh sửa (nav ra 2 màn khác)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  context.push('/emission/record-detail', extra: record);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Xem chi tiết',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  context.push('/emission/record-edit', extra: record);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Chỉnh sửa',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 8. Section: Item tháng trước (chạm để chuyển nhanh sang tháng trước)
  Widget _buildPreviousMonthCard({
    required List<HouseholdEmission> previousRecords,
    required double previousTotalCo2e,
  }) {
    final prevYear = _getPrevYearNumber();
    final prevMonth = _getPrevMonthNumber();
    final prevMM = prevMonth.toString().padLeft(2, '0');

    final prevRecordedSet = previousRecords.map((r) => r.category).toSet();
    final prevRecordedCount = prevRecordedSet.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tháng trước ($prevMM/$prevYear)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2E1E),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => _selectMonthYear(prevYear, prevMonth),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tháng $prevMM/$prevYear',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2E1E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      previousRecords.isNotEmpty
                          ? '$prevRecordedCount/5 nhóm đã ghi nhận'
                          : 'Chưa có bản ghi phát thải',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_formatCo2(previousTotalCo2e)} kg CO₂e',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF143E26),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          'Xem tháng này',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward,
                          size: 13,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 9. Nút Nhập dữ liệu tháng MM ở cuối trang
  Widget _buildInputDataBottomButton(String curMM) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          context.push('/emission/select-type', extra: {
            'year': _selectedYear,
            'month': _selectedMonth,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          '+ Nhập dữ liệu tháng $curMM',
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  /// Bottom Modal Chọn tháng & năm theo phong cách App
  void _showMonthPickerModal() {
    int pickerYear = _selectedYear;
    int pickerMonth = _selectedMonth;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle kéo
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header modal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chọn thời gian phát thải',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2E1E),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(bottomContext),
                        icon: const Icon(Icons.close, size: 20),
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Chọn Năm
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setModalState(() {
                              pickerYear--;
                            });
                          },
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text(
                          'Năm $pickerYear',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2E1E),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setModalState(() {
                              pickerYear++;
                            });
                          },
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lưới 12 tháng (3 x 4)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, i) {
                      final monthIndex = i + 1;
                      final isSelected =
                          pickerMonth == monthIndex && pickerYear == _selectedYear;

                      return InkWell(
                        onTap: () {
                          setModalState(() {
                            pickerMonth = monthIndex;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFF9FAF9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Tháng $monthIndex',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Nút hành động
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            final now = DateTime.now();
                            setModalState(() {
                              pickerYear = now.year;
                              pickerMonth = now.month;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Tháng hiện tại',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(bottomContext);
                            _selectMonthYear(pickerYear, pickerMonth);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Xác nhận',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Helper Methods ---

  int _getPrevMonthNumber() {
    final d = DateTime(_selectedYear, _selectedMonth - 1, 1);
    return d.month;
  }

  int _getPrevYearNumber() {
    final d = DateTime(_selectedYear, _selectedMonth - 1, 1);
    return d.year;
  }

  String _formatCo2(double val) {
    if (val % 1 == 0) return val.toInt().toString();
    return val.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _getCategoryDisplayLabel(String cat) {
    switch (cat) {
      case EmissionCategory.electricity:
        return 'Điện gia đình';
      case EmissionCategory.gas:
        return 'Gas';
      case EmissionCategory.waste:
        return 'Chất thải & nước thải';
      case EmissionCategory.refrigerant:
        return 'Môi chất làm lạnh';
      case EmissionCategory.transportation:
        return 'Phương tiện';
      default:
        return EmissionCategory.getLabel(cat);
    }
  }

  String _getDefaultSourceTitle(HouseholdEmission record) {
    switch (record.category) {
      case EmissionCategory.electricity:
        return 'Điện sinh hoạt';
      case EmissionCategory.gas:
        return 'Khí đốt gas';
      case EmissionCategory.waste:
        return 'Rác & nước thải';
      case EmissionCategory.refrigerant:
        return record.subCategory == 'refrigerator'
            ? 'Tủ lạnh'
            : 'Điều hòa không khí';
      case EmissionCategory.transportation:
        return 'Phương tiện di chuyển';
      default:
        return record.categoryLabel;
    }
  }

  String _getRecordSubtitle(HouseholdEmission record) {
    if (record.subCategoryLabel.isNotEmpty &&
        record.subCategoryLabel != record.categoryLabel) {
      return '${record.categoryLabel} · ${record.subCategoryLabel}';
    }
    return record.categoryLabel;
  }

  String _getPrimaryMeasurementText(HouseholdEmission record) {
    if (record.details is ElectricityDetails) {
      final d = record.details as ElectricityDetails;
      final val = d.calculatedKwh ?? d.inputValue;
      return '${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(1)} kWh';
    } else if (record.details is GasDetails) {
      final d = record.details as GasDetails;
      return '${d.weightKg.toStringAsFixed(2).replaceAll('.', ',')} kg gas';
    } else if (record.details is WasteDetails) {
      final d = record.details as WasteDetails;
      return '${d.quantity % 1 == 0 ? d.quantity.toInt() : d.quantity.toStringAsFixed(1)} ${d.unit}';
    } else if (record.details is RefrigerantDetails) {
      final d = record.details as RefrigerantDetails;
      return '${d.quantity.toStringAsFixed(2).replaceAll('.', ',')} kg ${d.refrigerantType}';
    } else if (record.details is TransportationDetails) {
      final d = record.details as TransportationDetails;
      return '${d.inputValue % 1 == 0 ? d.inputValue.toInt() : d.inputValue.toStringAsFixed(1)} ${d.isLiters ? "lít" : "kWh"}';
    }
    return '${record.co2eKgFormatted} kg CO₂e';
  }
}

/// Dữ liệu đoạn biểu đồ Donut
class DonutChartSegment {
  final String category;
  final double value;
  final Color color;

  const DonutChartSegment({
    required this.category,
    required this.value,
    required this.color,
  });
}

/// CustomPainter vẽ biểu đồ Donut Chart mượt mà
class _DonutChartPainter extends CustomPainter {
  final List<DonutChartSegment> segments;
  final double strokeWidth;

  _DonutChartPainter({
    required this.segments,
    this.strokeWidth = 22,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final total = segments.fold<double>(0.0, (prev, s) => prev + s.value);

    if (total <= 0) {
      final paint = Paint()
        ..color = const Color(0xFFE5E7EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    double startAngle = -math.pi / 2; // Bắt đầu ở đỉnh 12 giờ
    const gapAngle = 0.035; // Khoảng hở tinh tế giữa các lát

    for (final seg in segments) {
      if (seg.value <= 0) continue;

      final sweepAngle = (seg.value / total) * 2 * math.pi;
      final actualSweep = sweepAngle > gapAngle ? sweepAngle - gapAngle : sweepAngle;

      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle + gapAngle / 2, actualSweep, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
