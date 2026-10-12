import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../src/core/constants/app_colors.dart';
import '../../blocs/chat/chat_cubit.dart';
import '../../blocs/chat/chat_state.dart';
import '../../widgets/custom_app_bar.dart';

class MamAiScreen extends StatefulWidget {
  const MamAiScreen({super.key});

  @override
  State<MamAiScreen> createState() => _MamAiScreenState();
}

class _MamAiScreenState extends State<MamAiScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _chatController.text;
    if (text.trim().isEmpty) return;

    final cubit = context.read<ChatCubit>();
    if (!cubit.state.canSendMessage) return;

    cubit.sendMessage(text.trim());
    _chatController.clear();
    _scrollToBottom();
  }

  void _confirmResetChat() {
    final cubit = context.read<ChatCubit>();
    if (cubit.state.messages.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Làm mới cuộc trò chuyện?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          content: const Text(
            'Toàn bộ tin nhắn hiện tại sẽ được làm mới và bắt đầu phiên hỏi đáp mới với Bạn Mầm AI.',
            style: TextStyle(fontSize: 13, color: AppColors.subText, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Hủy', style: TextStyle(color: AppColors.subText)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                cubit.resetChat();
              },
              child: const Text('Bắt đầu mới'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Bạn Mầm AI',
              subtitle: 'Bạn đồng hành học sống xanh',
              showBackButton: false,
              trailing: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  return IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    tooltip: 'Đoạn chat mới',
                    onPressed: state.messages.isEmpty ? null : _confirmResetChat,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: _buildBannerCard(),
            ),
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  _scrollToBottom();
                },
                builder: (context, state) {
                  if (state.messages.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildMessageList(state);
                },
              ),
            ),
            _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/ic_sprout_smile.png',
            width: 36,
            height: 36,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.eco, color: AppColors.primary, size: 36),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hỏi nhỏ, học điều xanh',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 2),
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

  /// Giao diện khi chưa có tin nhắn nào
  Widget _buildEmptyState() {
    final suggestions = [
      'Làm sao phân loại rác thải sinh hoạt tại nhà?',
      'Cách tiết kiệm điện hiệu quả trong mùa hè?',
      'Làm thế nào để tái chế vỏ chai nhựa cùng bé?',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.successBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/ic_sprout_smile.png',
                width: 44,
                height: 44,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.eco, color: AppColors.primary, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chào bạn, mình là Bạn Mầm!',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hỏi Mầm bất cứ điều gì về bảo vệ môi trường, cách phân loại rác, tiết kiệm năng lượng và xây dựng lối sống xanh cho gia đình nhé.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.subText,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'GỢI Ý CÂU HỎI NHANH',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w700,
                color: AppColors.subText,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...suggestions.map(
            (suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => _sendMessage(suggestion),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.darkText,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: AppColors.subText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Danh sách tin nhắn hội thoại
  Widget _buildMessageList(ChatState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];

        if (message.isUser) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildUserMessage(message.content),
          );
        }

        // Tin nhắn của trợ lý Bạn Mầm
        // Nếu bot chưa có nội dung và đang loading -> hiển thị loading animation
        if (message.content.isEmpty && message.isStreaming) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildLoadingBubble(),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildBotMessage(
            message.content,
            isStreaming: message.isStreaming,
          ),
        );
      },
    );
  }

  Widget _buildUserMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 48),
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
        child: SelectableText(
          text,
          style: const TextStyle(fontSize: 13.5, color: Colors.white, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildBotMessage(String text, {bool isStreaming = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(
            color: AppColors.successBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/ic_sprout_smile.png',
              width: 18,
              height: 18,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.eco, color: AppColors.primary, size: 16),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.divider),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  text,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.darkText,
                    height: 1.5,
                  ),
                ),
                if (isStreaming) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Đang soạn...',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppColors.subText,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Khung bubble hiển thị hiệu ứng loading khi đang chờ AI bắt đầu trả lời
  Widget _buildLoadingBubble() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(
            color: AppColors.successBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/ic_sprout_smile.png',
              width: 18,
              height: 18,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.eco, color: AppColors.primary, size: 16),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _BouncingDotsIndicator(),
              const SizedBox(width: 10),
              const Text(
                'Mầm đang suy nghĩ...',
                style: TextStyle(fontSize: 12, color: AppColors.subText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatInput() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final isBusy = state.isLoading || state.isStreaming;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.divider.withValues(alpha: 0.6))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: isBusy ? AppColors.divider : AppColors.primary.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        focusNode: _focusNode,
                        enabled: !isBusy,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (val) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: isBusy
                              ? 'Bạn Mầm đang trả lời...'
                              : 'Hỏi Mầm về sống xanh...',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.subText),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 13.5, color: AppColors.darkText),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: isBusy ? AppColors.greyText.withValues(alpha: 0.4) : AppColors.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: isBusy ? null : () => _sendMessage(),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          child: isBusy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_upward_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'AI có thể mắc lỗi. Vui lòng kiểm tra lại thông tin quan trọng.',
                style: TextStyle(fontSize: 10, color: AppColors.subText),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget hiệu ứng 3 chấm nhảy (Bouncing Dots Animation)
class _BouncingDotsIndicator extends StatefulWidget {
  const _BouncingDotsIndicator();

  @override
  State<_BouncingDotsIndicator> createState() => _BouncingDotsIndicatorState();
}

class _BouncingDotsIndicatorState extends State<_BouncingDotsIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = (_controller.value - (index * 0.2)) % 1.0;
        final offsetY = (progress < 0.5) ? -progress * 8 : -(1.0 - progress) * 8;

        return Transform.translate(
          offset: Offset(0, offsetY),
          child: Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0),
        _buildDot(1),
        _buildDot(2),
      ],
    );
  }
}
