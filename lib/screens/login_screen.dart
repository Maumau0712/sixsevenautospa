import 'package:flutter/material.dart';

import '../services/database_helper.dart';
import '../services/user_session.dart';
import 'main_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final formKey =
  GlobalKey<FormState>();

  final emailController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String email =
      emailController.text
          .trim()
          .toLowerCase();

      String password =
          passwordController.text;

      final user =
      await DatabaseHelper.instance
          .loginUser(
        email,
        password,
      );

      if (!mounted) {
        return;
      }

      if (user == null) {
        setState(() {
          isLoading = false;
        });

        showMessage(
          'Unable to login.',
          true,
        );

        return;
      }

      UserSession.login(
        user,
      );

      setState(() {
        isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const MainNavigationScreen(),
        ),
            (route) => false,
      );
    } catch (error) {
      debugPrint(
        'Login error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      String message =
          'Unable to login. Please check your email and password.';

      String errorText =
      error.toString().toLowerCase();

      if (errorText.contains(
        'email not confirmed',
      )) {
        message =
        'Please verify your email before logging in.';
      }

      showMessage(
        message,
        true,
      );
    }
  }

  Future<void> forgotPassword() async {
    String email =
    emailController.text
        .trim()
        .toLowerCase();

    if (email.isEmpty ||
        !email.contains('@')) {
      showMessage(
        'Enter your email first.',
        true,
      );

      return;
    }

    try {
      await DatabaseHelper.instance
          .sendPasswordReset(
        email,
      );

      if (!mounted) {
        return;
      }

      showMessage(
        'Password reset email has been sent.',
        false,
      );
    } catch (error) {
      debugPrint(
        'Reset password error: $error',
      );

      if (!mounted) {
        return;
      }

      showMessage(
        'Unable to send password reset email.',
        true,
      );
    }
  }

  void showMessage(
      String message,
      bool error,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        backgroundColor:
        error
            ? Colors.red
            : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    const navy =
    Color(0xFF0B2344);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(24),

          child: Form(
            key: formKey,

            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),

                const CircleAvatar(
                  radius: 45,
                  backgroundColor: navy,
                  child: Icon(
                    Icons.directions_car_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(
                  '67AutoSpa',
                  style: TextStyle(
                    color: navy,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Color(0xFF7B8494),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 35,
                ),

                Container(
                  padding:
                  const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                    BorderRadius.circular(22),

                    border: Border.all(
                      color:
                      const Color(0xFFE3E8EF),
                    ),
                  ),

                  child: Column(
                    children: [
                      TextFormField(
                        controller:
                        emailController,

                        keyboardType:
                        TextInputType.emailAddress,

                        decoration:
                        const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                          ),
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter your email';
                          }

                          if (!value.contains('@') ||
                              !value.contains('.')) {
                            return 'Please enter a valid email';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      TextFormField(
                        controller:
                        passwordController,
                        obscureText:
                        hidePassword,

                        decoration: InputDecoration(
                          labelText: 'Password',

                          prefixIcon:
                          const Icon(
                            Icons.lock_outline,
                          ),

                          suffixIcon: IconButton(
                            onPressed: () {
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

                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Please enter your password';
                          }

                          return null;
                        },
                      ),

                      Align(
                        alignment:
                        Alignment.centerRight,

                        child: TextButton(
                          onPressed:
                          forgotPassword,
                          child: const Text(
                            'Forgot Password?',
                          ),
                        ),
                      ),

                      SizedBox(
                        width:
                        double.infinity,

                        child: ElevatedButton(
                          onPressed:
                          isLoading
                              ? null
                              : login,

                          child: isLoading
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
                            'Login',
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
                  height: 18,
                ),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                            const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Register',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}