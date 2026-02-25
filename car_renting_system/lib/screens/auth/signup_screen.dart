import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../buyer/buyer_main_screen.dart';
import '../seller/seller_main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  String _selectedRole = 'buyer';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRole,
    );

    if (success && mounted) {
      final screen = _selectedRole == 'seller'
          ? const SellerMainScreen()
          : const BuyerMainScreen();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => screen),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildRoleSelector(),
                const SizedBox(height: 24),
                _buildFields(),
                const SizedBox(height: 30),
                _buildSignupButton(),
                const SizedBox(height: 24),
                _buildLoginLink(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Create Account",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          "Join us to rent or list vehicles",
          style: TextStyle(color: AppColors.textGrey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "I want to",
          style: TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildRoleOption(
                label: "Rent a Car",
                icon: Icons.car_rental,
                value: 'buyer',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleOption(
                label: "List My Car",
                icon: Icons.sell_outlined,
                value: 'seller',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleOption({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : AppColors.textGrey,
                size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFields() {
    return Column(
      children: [
        CustomTextField(
          controller: _nameController,
          hint: "Full name",
          prefixIcon: Icons.person_outline,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Enter your name' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          hint: "Email address",
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter your email';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _phoneController,
          hint: "Phone number",
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Enter your phone number' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _passwordController,
          hint: "Password",
          prefixIcon: Icons.lock_outline,
          obscureText: !_showPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _showPassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textGrey,
              size: 20,
            ),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter a password';
            if (v.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _confirmPasswordController,
          hint: "Confirm password",
          prefixIcon: Icons.lock_outline,
          obscureText: !_showPassword,
          validator: (v) {
            if (v != _passwordController.text) return 'Passwords do not match';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(auth.error!),
                backgroundColor: AppColors.error,
              ),
            );
            auth.clearError();
          });
        }

        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : _signup,
            child: auth.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textDark,
                    ),
                  )
                : const Text("Create Account"),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? ",
            style: TextStyle(color: AppColors.textGrey)),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            "Sign In",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
