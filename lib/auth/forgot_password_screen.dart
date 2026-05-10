import 'package:flutter/material.dart';
import 'package:sufar_project/auth/verify_code_screen.dart';
import 'package:sufar_project/auth/sign_in_screen.dart';

import 'package:sufar_project/services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.forgotPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'OTP sent successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyCodeScreen(email: email),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
            height: isDesktop ? 600 : double.infinity,
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
                                SizedBox(height: size.height * 0.06),

                                // Logo
                                Image.asset(
                                  'assets/Sufar Logo Blue.png',
                                  height: 72,
                                ),
                                SizedBox(height: size.height * 0.04),

                                // Back to login
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignInScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_ios,
                                        size: 14,
                                        
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Back to login',
                                        style: TextStyle(
                                          
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: size.height * 0.045),

                                // Title
                                Text(
                                  'Forgot your password?',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                                SizedBox(height: 14),
                                Text(
                                  "Don't worry, happens to all of us. Enter your email below to recover your password",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    height: 1.6,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.05),

                                // Email Field
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(fontSize: 15),
                                    decoration: InputDecoration(
                                      hintText: 'your@email.com',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: Colors.grey.shade400,
                                        size: 20,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 18,
                                      ),
                                    ),
                                  ),
                                ),

                                const Spacer(),
                                SizedBox(height: size.height * 0.03),

                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 58,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submit,
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
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Theme.of(context).cardColor,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Submit',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).cardColor,
                                            ),
                                          ),
                                  ),
                                ),

                                SizedBox(height: size.height * 0.03),

                                // Or login with
                                Row(
                                  children: [
                                    Expanded(
                                        child: Divider(
                                            color: Colors.grey[200])),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(
                                        'Or login with',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: Divider(
                                            color: Colors.grey[200])),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.025),

                                // Social Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildSocialButton(
                                        Icons.facebook, Colors.blue[800]!),
                                    SizedBox(width: 16),
                                    _buildSocialButton(
                                      Icons.g_mobiledata,
                                      Colors.red,
                                      isLargeIcon: true,
                                    ),
                                    SizedBox(width: 16),
                                    _buildSocialButton(
                                        Icons.apple, Colors.black),
                                  ],
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

                // Right side - Illustration (only on desktop)
                if (isDesktop)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FA),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/image 7.png',
                              height: 400,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.help_outline,
                                      size: 120,
                                      color: const Color(
                                        0xFF1396D8,
                                      ).withOpacity(0.5),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Illustration PlaceHolder',
                                      style:
                                          TextStyle(color: Colors.grey[400]),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
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

  Widget _buildSocialButton(
    IconData icon,
    Color color, {
    bool isLargeIcon = false,
  }) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: isLargeIcon ? 34 : 24),
        onPressed: () {},
      ),
    );
  }
}
