import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/create_household/create_household_cubit.dart';
import '../../blocs/create_household/create_household_state.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';

class CreateHouseholdScreen extends StatefulWidget {
  const CreateHouseholdScreen({super.key});

  @override
  State<CreateHouseholdScreen> createState() => _CreateHouseholdScreenState();
}

class _CreateHouseholdScreenState extends State<CreateHouseholdScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = 'Vui lòng nhập tên hộ gia đình';
      });
      return;
    }
    if (name.length < 2) {
      setState(() {
        _nameError = 'Tên hộ gia đình phải có ít nhất 2 ký tự';
      });
      return;
    }

    setState(() {
      _nameError = null;
    });

    context.read<CreateHouseholdCubit>().createHousehold(name);
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Tạo hộ gia đình',
              subtitle: 'Gia đinh thân thuộc cho hành trình xanh.',
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: BlocConsumer<CreateHouseholdCubit, CreateHouseholdState>(
                  listener: (context, state) {
                    if (state is CreateHouseholdSuccess) {
                      context.pushReplacement('/family/create/success', extra: state.household);
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is CreateHouseholdLoading;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Mầm xanh thông tin
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF3E4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/icons/ic_sprout_smile.png',
                                width: 48,
                                height: 48,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.eco, size: 48, color: AppColors.primary),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Bạn sẽ trở thành chủ hộ và có thể mời mọi người sau khi tạo.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF2D4F3C),
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form nhập tên hộ gia đình
                        CustomTextField(
                          label: 'Tên hộ gia đình',
                          hintText: 'Nhà Mầm xanh',
                          controller: _nameController,
                          errorText: _nameError,
                          onChanged: (value) {
                            if (_nameError != null) {
                              setState(() {
                                _nameError = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Info lưu ý
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF3E4),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: Color(0xFF2D4F3C), size: 18),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Chỉ cần tên hộ. Không yêu cầu địa chỉ hay thông tin thành viên ở bước này.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2D4F3C),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Banner thông báo lỗi từ API (như ảnh 2)
                        if (state is CreateHouseholdFailure) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEEFEF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFF5C6CB)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/icons/ic_info.png',
                                  width: 18,
                                  height: 18,
                                  color: const Color(0xFFC94A4A),
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error_outline, size: 18, color: Color(0xFFC94A4A)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    state.error,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFC94A4A),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Nút Tạo hộ gia đình
                        InkWell(
                          onTap: isLoading ? null : _submit,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Tạo hộ gia đình',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Nút Để sau
                        InkWell(
                          onTap: () => context.pop(),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8DE)),
                            ),
                            child: const Center(
                              child: Text(
                                'Để sau',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D4F3C),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Footer
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
