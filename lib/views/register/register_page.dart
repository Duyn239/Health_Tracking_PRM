import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/register_vm.dart';
import '../login/login_page.dart';
import 'custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    for (var controller in [_nameController, _emailController, _passwordController, _confirmPasswordController]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onRegister(RegisterViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await viewModel.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      _showSnackBar('Đăng ký thành công !!', Colors.green);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
          );
        }
      });
    } else {
      _showSnackBar(viewModel.errorMessage ?? 'Đăng ký thất bại', Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/logo-removebg.png', height: 100),
                const Text('Tạo Tài Khoản', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),


                /// Họ và Tên
                CustomInput.buildLabel('Họ và Tên'),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: CustomInput.decoration(hint: 'Nhập họ và tên', icon: Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập họ tên';

                    // Chỉ cho phép chữ cái a-z, A-Z và khoảng trắng \s
                    final nameRegExp = RegExp(r"^[a-zA-Z\s]+$");

                    if (!nameRegExp.hasMatch(value)) return 'Chỉ được chứa chữ cái và khoảng trắng !!';
                    return null;
                  },
                ),
                const SizedBox(height: 20),


                /// EMAIL
                CustomInput.buildLabel('Email'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: CustomInput.decoration(hint: 'example@gmail.com', icon: Icons.email_outlined),
                  validator: (v) => (v != null && v.endsWith('@gmail.com')) ? null : 'Email phải có đuôi @gmail.com',
                ),
                const SizedBox(height: 20),


                /// PASSWORD
                CustomInput.buildLabel('Mật khẩu'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  decoration: CustomInput.decoration(
                    hint: '7-8 ký tự (chữ và số)', icon: Icons.lock_outline, isPassword: true,
                    obscured: _isPasswordObscured, onToggle: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';

                    // Độ dài từ 7 đến 8 và chỉ chứa chữ cái + số
                    final passwordRegExp = RegExp(r"^[a-zA-Z0-9]{7,8}$");

                    if (!passwordRegExp.hasMatch(value)) {
                      return 'Mật khẩu 7-8 ký tự (chữ và số)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),


                /// CONFIRM PASSWORD
                CustomInput.buildLabel('Xác nhận mật khẩu'),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmPasswordObscured,
                  decoration: CustomInput.decoration(
                    hint: 'Nhập lại mật khẩu', icon: Icons.lock_reset, isPassword: true,
                    obscured: _isConfirmPasswordObscured, onToggle: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                  ),
                  validator: (v) => (v == _passwordController.text) ? null : 'Mật khẩu không khớp',
                ),
                const SizedBox(height: 30),

                Consumer<RegisterViewModel>(
                  builder: (context, vm, _) => ElevatedButton(
                    onPressed: vm.isLoading ? null : () => _onRegister(vm),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: vm.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Đăng Ký', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Đã có tài khoản? ', style: TextStyle(color: Color(0xFF757575))),
          InkWell(
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
            child: const Text('Đăng nhập', style: TextStyle(color: Color(0xFF4A90E2), fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 30),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset('assets/healthtracking_loginpage.webp', fit: BoxFit.cover),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}