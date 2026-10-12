import 'package:flutter/material.dart';

/// Hiển thị bottom sheet chọn Tháng và Năm
Future<DateTime?> showEmissionMonthPickerSheet({
  required BuildContext context,
  required int initialYear,
  required int initialMonth,
}) async {
  int pickerYear = initialYear;
  int pickerMonth = initialMonth;

  return showModalBottomSheet<DateTime>(
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
                      'Chọn tháng ghi nhận',
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, idx) {
                    final monthIndex = idx + 1;
                    final isSelected = monthIndex == pickerMonth;

                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          pickerMonth = monthIndex;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFF4F6F4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2E7D32)
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          'Tháng $monthIndex',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF2C3E2D),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Nút Xác nhận
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        bottomContext,
                        DateTime(pickerYear, pickerMonth),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
