import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final formKey =
  GlobalKey<FormState>();

  final passwordController =
  TextEditingController();

  final confirmPasswordController =
  TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  Future<void> updatePassword() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          password:
          passwordController.text.trim(),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password updated successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(
        const Duration(
          milliseconds: 700,
        ),
      );

      await Supabase.instance.client.auth.signOut();

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (error) {
      debugPrint(
        'Update password error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update password. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    const navy =
    Color(0xFF0B2344);

    return Scaffold(
      backgroundColor:
      const Color(
        0xFFF3F6FA,
      ),

      appBar: AppBar(
        title: const Text(
          'Reset Password',
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(24),

          child: Form(
            key: formKey,

            child: Column(
              children: [
                const SizedBox(
                  height: 35,
                ),

                const CircleAvatar(
                  radius: 45,

                  backgroundColor:
                  navy,

                  child: Icon(
                    Icons.lock_reset_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                const Text(
                  'Create New Password',

                  style: TextStyle(
                    color: navy,
                    fontSize: 26,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  'Enter your new password below.',

                  textAlign:
                  TextAlign.center,

                  style: TextStyle(
                    color:
                    Color(
                      0xFF7B8494,
                    ),

                    fontSize: 14,
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                Container(
                  padding:
                  const EdgeInsets.all(
                    22,
                  ),

                  decoration:
                  BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                    BorderRadius.circular(
                      22,
                    ),

                    border: Border.all(
                      color:
                      const Color(
                        0xFFE3E8EF,
                      ),
                    ),
                  ),

                  child: Column(
                    children: [
                      TextFormField(
                        controller:
                        passwordController,

                        obscureText:
                        hidePassword,

                        decoration:
                        InputDecoration(
                          labelText:
                          'New Password',

                          prefixIcon:
                          const Icon(
                            Icons.lock_outline,
                          ),

                          suffixIcon:
                          IconButton(
                            onPressed:
                                () {
                              setState(() {
                                hidePassword =
                                !hidePassword;
                              });
                            },

                            icon: Icon(
                              hidePassword
                                  ? Icons
                                  .visibility_off_outlined
                                  : Icons
                                  .visibility_outlined,
                            ),
                          ),
                        ),

                        validator:
                            (value) {
                          if (value ==
                              null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return 'Please enter a new password';
                          }

                          if (value.length <
                              6) {
                            return 'Password must be at least 6 characters';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextFormField(
                        controller:
                        confirmPasswordController,

                        obscureText:
                        hideConfirmPassword,

                        decoration:
                        InputDecoration(
                          labelText:
                          'Confirm New Password',

                          prefixIcon:
                          const Icon(
                            Icons.lock_outline,
                          ),

                          suffixIcon:
                          IconButton(
                            onPressed:
                                () {
                              setState(() {
                                hideConfirmPassword =
                                !hideConfirmPassword;
                              });
                            },

                            icon: Icon(
                              hideConfirmPassword
                                  ? Icons
                                  .visibility_off_outlined
                                  : Icons
                                  .visibility_outlined,
                            ),
                          ),
                        ),

                        validator:
                            (value) {
                          if (value ==
                              null ||
                              value
                                  .isEmpty) {
                            return 'Please confirm your new password';
                          }

                          if (value !=
                              passwordController.text) {
                            return 'Passwords do not match';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      SizedBox(
                        width:
                        double.infinity,

                        child:
                        ElevatedButton(
                          onPressed:
                          isLoading
                              ? null
                              : updatePassword,

                          child:
                          isLoading
                              ? const SizedBox(
                            width: 22,
                            height: 22,

                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2.5,

                              color:
                              Colors.white,
                            ),
                          )
                              : const Text(
                            'Update Password',

                            style:
                            TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(
                  'After updating your password, you will return to the login page.',

                  textAlign:
                  TextAlign.center,

                  style: TextStyle(
                    color:
                    Color(
                      0xFF7B8494,
                    ),

                    fontSize: 12,
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