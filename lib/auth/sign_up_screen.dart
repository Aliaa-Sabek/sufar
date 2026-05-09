import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufar_project/auth/sign_in_screen.dart';
import 'package:sufar_project/auth/verify_code_screen.dart';
import 'package:sufar_project/services/api_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isEmailAutoFilled = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        _emailController.text = savedEmail;
        _isEmailAutoFilled = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();
      final name = _nameController.text.trim();

      if (email.isEmpty ||
          password.isEmpty ||
          name.isEmpty ||
          confirmPassword.isEmpty) {
        throw 'Please fill in all fields';
      }

      if (!_agreeToTerms) {
        throw 'Please agree to Terms & Conditions';
      }

      if (password != confirmPassword) {
        throw 'Passwords do not match';
      }

      final result = await ApiService.register(
        email: email,
        password: password,
        fullName: name,
      );

      if (result['message'] == null && result['error'] != null) {
        throw result['error'] ?? 'Registration failed';
      } else if (result['errors'] != null && result['errors'] is List && (result['errors'] as List).isNotEmpty) {
        throw result['errors'][0]['msg']?.toString() ?? 'Validation error';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registration successful! Please verify your email.',
            ),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyCodeScreen(email: email, isForSignup: true),
          ),
        );
      }

    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: isDesktop ? const Color(0xFF222222) : Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            width: isDesktop ? 1000 : double.infinity,
            height: isDesktop ? 700 : double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: Row(
              children: [
                // Left side - Form
                Expanded(
                  flex: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 60 : 28,
                          vertical: 0,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.height * 0.055),

                                // Back to login
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Row(
                                    children: [
                                      Icon(Icons.arrow_back, color: Color(0xFF1396D8), size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        'Back to login',
                                        style: TextStyle(
                                          color: Color(0xFF1396D8),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: size.height * 0.035),

                                Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Start your journey with us',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                SizedBox(height: size.height * 0.03),

                                // Full Name
                                Text(
                                  'Full Name',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                _buildTextField(
                                  controller: _nameController,
                                  hint: 'John Doe',
                                  prefixIcon: Icons.person_outline,
                                ),
                                SizedBox(height: size.height * 0.02),

                                // Email
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                _buildTextField(
                                  controller: _emailController,
                                  hint: 'your@email.com',
                                  prefixIcon: Icons.email_outlined,
                                  isAutoFilled: _isEmailAutoFilled,
                                ),
                                SizedBox(height: size.height * 0.02),

                                // Password
                                Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                _buildTextField(
                                  controller: _passwordController,
                                  hint: '••••••••',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: !_isPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      
                                    ),
                                    onPressed: () => setState(
                                      () => _isPasswordVisible =
                                          !_isPasswordVisible,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Min 8 characters',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                SizedBox(height: size.height * 0.015),

                                // Confirm Password
                                Text(
                                  'Confirm Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  hint: '••••••••',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: !_isConfirmPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      
                                    ),
                                    onPressed: () => setState(
                                      () => _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible,
                                    ),
                                  ),
                                ),

                                SizedBox(height: size.height * 0.022),

                                // Terms
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (value) {
                                          setState(() {
                                            _agreeToTerms = value ?? false;
                                          });
                                        },
                                        activeColor: const Color(0xFF1396D8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'I agree to the ',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'Terms & Conditions',
                                      style: TextStyle(
                                        color: Color(0xFF1396D8),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const Spacer(),
                                SizedBox(height: size.height * 0.025),

                                // Create Account Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 58,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _signUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF1396D8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Theme.of(context).cardColor,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Create Account',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).cardColor,
                                            ),
                                          ),
                                  ),
                                ),

                                SizedBox(height: size.height * 0.02),

                                // Sign in link
                                Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Already have an account? ',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignInScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Sign in',
                                          style: TextStyle(
                                            color: Color(0xFF1396D8),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: size.height * 0.04),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Right side - Image (only on desktop)
                if (isDesktop)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/Image (Travel illustration).png',
                          ),
                          fit: BoxFit.cover,
                        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    bool isAutoFilled = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isAutoFilled ? const Color(0xFFE9F0FD) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAutoFilled ? const Color(0xFF1396D8).withValues(alpha: 0.3) : Colors.grey.shade200, 
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: isAutoFilled ? const Color(0xFF1396D8) : Colors.grey.shade400, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
