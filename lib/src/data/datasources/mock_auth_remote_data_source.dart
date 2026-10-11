import '../../domain/entities/user.dart';

class MockAuthRemoteDataSource {
  // Giả lập lưu trữ tạm trên memory
  String? _tempPhone;
  String? _tempEmail;

  Future<User> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Giả lập delay mạng
    if (password != 'password123') {
      throw Exception('Tài khoản hoặc mật khẩu không chính xác.');
    }
    return const User(
      id: 'u_123',
      email: 'lan.nguyen@example.com',
      phone: '0912345678',
      fullName: 'Lan Nguyen',
      role: 'Người dùng • Dành cho gia đình',
    );
  }

  Future<void> registerInfo(String email, String phone, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (phone.length < 10) {
      throw Exception('Số điện thoại không hợp lệ.');
    }
    _tempEmail = email;
    _tempPhone = phone;
  }

  Future<void> resendOtp(String phone) async {
    await Future.delayed(const Duration(seconds: 1)); // Giả lập thời gian gửi SMS
    // Có thể thêm logic kiểm tra nếu cần
  }

  Future<User> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    if (otp != '000000') {
      throw Exception('Mã OTP không hợp lệ.');
    }
    return User(
      id: 'u_999',
      email: _tempEmail ?? 'newuser@example.com',
      phone: _tempPhone ?? phone,
      fullName: 'New User',
      role: 'Người dùng • Dành cho gia đình',
    );
  }

  Future<User?> checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return null; // Mặc định chưa đăng nhập
  }
}
