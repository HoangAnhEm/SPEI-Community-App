import 'package:flutter/material.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class MamAiScreen extends StatefulWidget {
  const MamAiScreen({super.key});

  @override
  State<MamAiScreen> createState() => _MamAiScreenState();
}

class _MamAiScreenState extends State<MamAiScreen> {
  final TextEditingController _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Bạn Mầm AI',
              subtitle: 'Bạn đồng hành học sống xanh',
              showBackButton: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBannerCard(),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'HỘI THOẠI MINH HỌA • HÔM NAY',
                        style: TextStyle(fontSize: 10, color: AppColors.subText, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildUserMessage('Mầm ơi, làm sao dạy bé An 6 tuổi phân loại rác ở nhà?'),
                    const SizedBox(height: 16),
                    _buildBotMessage('Mình thử trò "rác về đúng nhà" nhé!\n\n• Rác thức ăn: vỏ chuối, rau thừa.\n• Rác tái chế: giấy, chai sạch và khô.\n• Rác còn lại: giấy bẩn, túi bẩn.\n\nDán hình lên 3 thùng, để bé chọn chỗ cho từng món. Nhớ theo hướng dẫn thu gom ở nơi mình sống nhé!'),
                    const SizedBox(height: 16),
                    _buildUserMessage('Còn pin đã dùng thì sao?'),
                    const SizedBox(height: 16),
                    _buildBotMessage('Pin để riêng và nhờ người lớn mang đến điểm thu gom phù hợp. Bé không tự cầm pin rò rỉ hay vật sắc nhọn nhé. Mình có thể bắt đầu bằng 3 vỏ hộp sạch!'),
                    const SizedBox(height: 32),
                    const Text(
                      'Cả nhà có thể hỏi thêm',
                      style: TextStyle(fontSize: 11, color: AppColors.subText),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSuggestionChip('Trò chơi tiết kiệm điện', AppColors.successBg, AppColors.primary),
                        const SizedBox(width: 8),
                        _buildSuggestionChip('Trồng cây cùng bé', AppColors.blueBg, AppColors.bluePrimary),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildChatInput(),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'AI có thể sai. Phụ huynh kiểm tra thông tin trước khi làm cùng trẻ. Bản mẫu chưa kết nối AI.',
                        style: TextStyle(fontSize: 10, color: AppColors.subText),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Bản mẫu giao diện • Dữ liệu minh họa',
                        style: TextStyle(fontSize: 10, color: AppColors.greyText),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/ic_sprout_smile.png',
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, color: AppColors.primary, size: 40),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hỏi nhỏ, học điều xanh',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                SizedBox(height: 4),
                Text(
                  'Gợi ý ngắn, dễ thực hành cùng con.',
                  style: TextStyle(fontSize: 12, color: AppColors.subText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildBotMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.successBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/ic_sprout_smile.png',
              width: 18,
              height: 18,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, color: AppColors.primary, size: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.divider),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppColors.darkText, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: const InputDecoration(
                hintText: 'Hỏi Mầm về sống xanh...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.subText),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 13, color: AppColors.darkText),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
