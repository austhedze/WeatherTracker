

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xam_ap/services/auth/authservice.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmPhoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePhone = true;
  bool _obscureConfirmPhone = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.registerWithStudentId(
        _studentIdController.text.trim(),
        _phoneController.text.trim(),
        _studentIdController.text.trim(), // Use student ID as display name
      );
      
      // Navigate to home after successful registration
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (errorMessage.contains('email-already-in-use')) {
        errorMessage = 'This student ID is already registered';
      } else if (errorMessage.contains('weak-password')) {
        errorMessage = 'Phone number must be at least 6 characters';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _phoneController.dispose();
    _confirmPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade800,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Back Button and Title
                Row(
                  children: [
                  
                    const SizedBox(width: 10),
                    Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

              Icon(Icons.app_registration, size: 100, color: Colors.white),
                const SizedBox(height: 30),

                // Registration Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _studentIdController,
                        label: 'Student ID (Username)',
                        hint: 'e.g., bit-001-22',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your student ID';
                          }
                          if (!RegExp(r'^[a-zA-Z]{3}-\d{3}-\d{2}$').hasMatch(value)) {
                            return 'Please enter a valid student ID\nFormat: xxx-001-22';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildPhoneField(
                        controller: _phoneController,
                        label: 'Phone Number (Password)',
                        isObscure: _obscurePhone,
                        onToggle: () {
                          setState(() {
                            _obscurePhone = !_obscurePhone;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length != 10) {
                            return 'Phone number must be exactly 10 digits';
                          }
                          if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                            return 'Please enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildPhoneField(
                        controller: _confirmPhoneController,
                        label: 'Confirm Phone Number',
                        isObscure: _obscureConfirmPhone,
                        onToggle: () {
                          setState(() {
                            _obscureConfirmPhone = !_obscureConfirmPhone;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your phone number';
                          }
                          if (value != _phoneController.text) {
                            return 'Phone numbers do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // Info text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade800.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade400),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade300, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Student ID = Username | Phone Number = Password',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            disabledBackgroundColor: Colors.blue.shade400,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Create Account',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.poppins(
                                color: Colors.blue.shade300,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
    required String label,
    String? hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      validator: validator,
    );
  }

  Widget _buildPhoneField({
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    required VoidCallback onToggle,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(Icons.phone, color: Colors.white.withOpacity(0.7)),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            isObscure ? Icons.visibility : Icons.visibility_off,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      validator: validator,
    );
  }
}