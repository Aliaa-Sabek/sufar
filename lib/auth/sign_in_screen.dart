import 'package:flutter/material.dart';
import 'package:sufar_project/auth/sign_up_screen.dart';
import 'package:sufar_project/auth/forgot_password_screen.dart';
import 'package:sufar_project/main.dart';
import 'package:sufar_project/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        throw 'Please fill in all fields';
      }

      final result = await ApiService.login(
        email: email,
        password: password,
      );

      if (result['token'] == null) {
        String errMsg = 'Login failed';
        if (result['message'] != null) {
          errMsg = result['message'].toString();
        } else if (result['errors'] != null && result['errors'] is List && (result['errors'] as List).isNotEmpty) {
          errMsg = result['errors'][0]['msg']?.toString() ?? 'Validation error';
        }
        throw errMsg;
      }

      await ApiService.saveToken(result['token']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_in_email', email);
      final user = result['user'];
      if (user is Map) {
        final name = (user['fullName'] ?? user['name'])?.toString();
        if (name != null && name.isNotEmpty) {
          await prefs.setString('logged_in_name', name);
        }
      }

      if (_rememberMe) {
        await prefs.setString('saved_email', email);
        await prefs.setString('saved_password', password);
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
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
                                SizedBox(height: size.height * 0.07),

                                // Logo
                                Image.asset(
                                  'assets/Sufar Logo Blue.png',
                                  height: 72,
                                ),
                                SizedBox(height: size.height * 0.05),

                                Text(
                                  'Welcome Back',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1396D8),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Sign in to continue your journey',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
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
                                SizedBox(height: 8),
                                _buildTextField(
                                  controller: _emailController,
                                  hint: 'your@gmail.com',
                                  prefixIcon: Icons.email_outlined,
                                ),
                                SizedBox(height: size.height * 0.025),

                                // Password Field
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
                                  hint: 'Password',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: !_isPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => setState(
                                      () => _isPasswordVisible =
                                          !_isPasswordVisible,
                                    ),
                                  ),
                                ),

                                // Remember me / Forgot password
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          activeColor: const Color(0xFF1396D8),
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                        ),
                                        Text(
                                          'Remember me',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                          color: Color(0xFF1396D8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const Spacer(),
                                SizedBox(height: size.height * 0.03),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 58,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _signIn,
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
                                            'Login',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).cardColor,
                                            ),
                                          ),
                                  ),
                                ),

                                SizedBox(height: size.height * 0.025),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                        child: Divider(
                                            color: Colors.grey[300])),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(
                                        'or',
                                        style: TextStyle(
                                            color: Colors.grey[400]),
                                      ),
                                    ),
                                    Expanded(
                                        child: Divider(
                                            color: Colors.grey[300])),
                                  ],
                                ),

                                SizedBox(height: size.height * 0.025),

                                // Sign up link
                                Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUpScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Create an account',
                                          style: TextStyle(
                                            color: Color(0xFF1396D8),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: Colors.grey.shade400, size: 20),
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
