import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'splash_screen.dart';
import 'police_home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _badgeController = TextEditingController();
  final _stationController = TextEditingController();
  
  bool _isSignUp = true;
  String _selectedRole = 'Citizen';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (_isSignUp) {
      final name = _nameController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (name.isEmpty) {
        _showError('Please enter your name.');
        return;
      }
      if (password != confirmPassword) {
        _showError('Passwords do not match.');
        return;
      }

      if (_selectedRole == 'Citizen') {
        final phone = _phoneController.text.trim();
        if (phone.isEmpty) {
          _showError('Please enter your phone number.');
          return;
        }
        await prefs.setString('userPhone', phone);
      } else {
        final badge = _badgeController.text.trim();
        final station = _stationController.text.trim();
        if (badge.isEmpty || station.isEmpty) {
          _showError('Please enter badge number and jurisdiction.');
          return;
        }
        await prefs.setString('userBadge', badge);
        await prefs.setString('userStation', station);
      }

      await prefs.setString('userName', name);
      await prefs.setString('userEmail', email);
      await prefs.setString('userPassword', password); // Simulated saving
      await prefs.setString('userRole', _selectedRole);
    } else {
      // Login mode - simple simulation
      final savedEmail = prefs.getString('userEmail');
      final savedPassword = prefs.getString('userPassword');
      final savedRole = prefs.getString('userRole') ?? 'Citizen';

      if (savedEmail != null && savedPassword != null) {
        if (email != savedEmail || password != savedPassword) {
           _showError('Invalid credentials.');
           return;
        }
        _selectedRole = savedRole; // Use the saved role for routing
      } else {
        // Fallback for demo purposes if no user saved
        await prefs.setString('userName', 'Demo User');
        await prefs.setString('userEmail', email);
        await prefs.setString('userRole', 'Citizen');
        _selectedRole = 'Citizen';
      }
    }

    if (mounted) {
      if (_selectedRole == 'Police') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PoliceHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.highRed,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _badgeController.dispose();
    _stationController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: AppColors.textDark),
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textLight,
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'NammaShield',
                  style: AppTextStyles.title.copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  _isSignUp ? 'Create your account' : 'Log in to your account',
                  style: AppTextStyles.caption.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                if (_isSignUp) ...[
                  Text('Select Account Type', style: AppTextStyles.caption),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = 'Citizen'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'Citizen' ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _selectedRole == 'Citizen' ? AppColors.primary : AppColors.divider),
                            ),
                            child: Text(
                              'Citizen',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedRole == 'Citizen' ? Colors.white : AppColors.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = 'Police'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'Police' ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _selectedRole == 'Police' ? AppColors.primary : AppColors.divider),
                            ),
                            child: Text(
                              'Police Official',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedRole == 'Police' ? Colors.white : AppColors.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'Full Name',
                  ),
                ],

                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                ),

                if (_isSignUp && _selectedRole == 'Citizen') ...[
                  _buildTextField(
                    controller: _phoneController,
                    hintText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                  ),
                ],

                if (_isSignUp && _selectedRole == 'Police') ...[
                  _buildTextField(
                    controller: _badgeController,
                    hintText: 'Badge Number / Police ID',
                  ),
                  _buildTextField(
                    controller: _stationController,
                    hintText: 'Jurisdiction / Station Name',
                  ),
                ],

                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                ),

                if (_isSignUp) ...[
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ],

                SizedBox(height: 24),

                // Submit Button
                GestureDetector(
                  onTap: _submit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      _isSignUp ? 'Sign Up' : 'Log In',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Toggle Mode
                GestureDetector(
                  onTap: () => setState(() {
                    _isSignUp = !_isSignUp;
                    // Reset fields
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                  }),
                  child: Text(
                    _isSignUp ? 'Already have an account? Log In' : 'Need an account? Sign Up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
}
