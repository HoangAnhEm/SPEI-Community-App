import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/emission_details.dart';
import 'package:spei_community/src/core/constants/app_colors.dart';

// Màu riêng của màn này
const Color _kGreenLightF1F8F2 = Color(0xFFF1F8F2);

/// Màn hình chọn loại chất thải (gồm 10 loại chia làm 3 nhóm: Chất thải rắn, Nguy hại, Nước thải)
class SelectWasteTypeScreen extends StatefulWidget {
  final WasteTypeItem? initialSelected;

  const SelectWasteTypeScreen({
    super.key,
    this.initialSelected,
  });

  @override
  State<SelectWasteTypeScreen> createState() => _SelectWasteTypeScreenState();
}

class _SelectWasteTypeScreenState extends State<SelectWasteTypeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late WasteTypeItem _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialSelected ?? WasteTypeItem.all.first;
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WasteTypeItem> _filterItems(List<WasteTypeItem> items) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items.where((item) {
      final nameMatches = item.name.toLowerCase().contains(query);
      final codeMatches = item.wasteCode?.toLowerCase().contains(query) ?? false;
      final methodMatches = item.treatmentMethod.toLowerCase().contains(query);
      return nameMatches || codeMatches || methodMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final solidList = _filterItems(
      WasteTypeItem.all.where((e) => e.key == 'solid_waste').toList(),
    );
    final hazardousList = _filterItems(
      WasteTypeItem.all
          .where((e) => e.key != 'solid_waste' && e.key != 'wastewater')
          .toList(),
    );
    final wastewaterList = _filterItems(
      WasteTypeItem.all.where((e) => e.key == 'wastewater').toList(),
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14.5, color: AppColors.gray800),
                  decoration: const InputDecoration(
                    hintText: 'Tìm tên hoặc mã chất thải',
                    hintStyle: TextStyle(fontSize: 14, color: AppColors.gray400),
                    prefixIcon: Icon(Icons.search, color: AppColors.gray500, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Danh sách cuộn
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card thông báo xanh
                    _buildTopCallout(),
                    const SizedBox(height: 18),

                    // Nhóm 1: Chất thải rắn
                    if (solidList.isNotEmpty) ...[
                      _buildSectionHeader('Chất thải rắn', '${solidList.length} loại'),
                      const SizedBox(height: 10),
                      ...solidList.map((item) => _buildWasteCard(item)),
                      const SizedBox(height: 20),
                    ],

                    // Nhóm 2: Chất thải nguy hại
                    if (hazardousList.isNotEmpty) ...[
                      _buildSectionHeader('Chất thải nguy hại', '${hazardousList.length} loại'),
                      const SizedBox(height: 10),
                      ...hazardousList.map((item) => _buildWasteCard(item)),
                      const SizedBox(height: 20),
                    ],

                    // Nhóm 3: Nước thải
                    if (wastewaterList.isNotEmpty) ...[
                      _buildSectionHeader('Nước thải', '${wastewaterList.length} loại'),
                      const SizedBox(height: 10),
                      ...wastewaterList.map((item) => _buildWasteCard(item)),
                      const SizedBox(height: 20),
                    ],

                    // Cảnh báo vàng: Giới hạn hệ số nước thải
                    _buildWastewaterWarningBanner(),
                    const SizedBox(height: 12),

                    // Ghi chú cuối
                    const Center(
                      child: Text(
                        'Giữ nguyên mã và phương pháp trong bảng. "HR" là ký hiệu gốc; cần xác minh ý nghĩa trước khi áp dụng.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.gray500,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Nút cố định ở dưới đáy
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop(_selectedItem);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Chọn ${_selectedItem.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Nút quay lại
          InkWell(
            onTap: () => context.pop(),
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
                color: AppColors.greenDark,
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
                  'Chọn loại chất thải',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '10 loại • Theo bảng 2.6 đính kèm',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),

          // Logo avatar tròn
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

  /// Thông báo xanh trên đầu
  Widget _buildTopCallout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blueSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blueBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, size: 20, color: AppColors.blueMedium),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Chọn đúng nhóm của nhà mình',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Hệ số chỉ dùng với đúng loại và cách xử lý trong bảng. Loại nguy hại không dùng thay cho rác sinh hoạt.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.blueDark,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// Tiêu đề section
  Widget _buildSectionHeader(String title, String countText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.gray800,
          ),
        ),
        Text(
          countText,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }

  /// Thẻ card cho từng loại chất thải
  Widget _buildWasteCard(WasteTypeItem item) {
    final isSelected = item.key == _selectedItem.key;
    final codeString =
        item.wasteCode != null ? item.wasteCode! : 'Không có mã trong bảng';
    final factorString = item.emissionFactor
        .toStringAsFixed(5)
        .replaceAll('.', ',')
        .replaceFirst(RegExp(r',00000$'), '')
        .replaceFirst(RegExp(r'0+$'), '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? _kGreenLightF1F8F2 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.greenPrimary : AppColors.gray200,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedItem = item;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray800,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$codeString • ${item.treatmentMethod}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$factorString ${item.emissionFactorUnit} • Nhập ${item.defaultUnit}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.greenPrimary,
                          size: 22,
                        )
                      : Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.gray300, width: 1.5),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Cảnh báo vàng: Giới hạn hệ số nước thải
  Widget _buildWastewaterWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.amber600),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Giới hạn hệ số nước thải',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amber700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '0,18574 kg CO2e/m³ chỉ thuộc hệ thống xử lý nước thải KCN trong ảnh, không áp chung cho nước thải gia đình.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.amber800,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
