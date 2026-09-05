import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/database_helper.dart';
import '../services/user_session.dart';
import 'main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final formKey =
  GlobalKey<FormState>();

  final nameController =
  TextEditingController();

  final emailController =
  TextEditingController();

  final phoneController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final confirmPasswordController =
  TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String name =
      nameController.text.trim();

      String email =
      emailController.text
          .trim()
          .toLowerCase();

      String phone =
      phoneController.text.trim();

      String password =
          passwordController.text;

      final response =
      await DatabaseHelper.instance
          .registerUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      if (response.session != null) {
        final user =
        await DatabaseHelper.instance
            .createOrGetProfile();

        if (user != null) {
          UserSession.login(
            user,
          );

          if (!mounted) {
            return;
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const MainNavigationScreen(),
            ),
                (route) => false,
          );

          return;
        }
      }


      showVerificationDialog(
        email,
      );
    } catch (error) {

      debugPrint(
        'REGISTER ERROR: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      String errorText =
      error.toString().toLowerCase();

      String message =
          'Unable to create account. Please try again later.';


      if (errorText.contains(
        'over_email_send_rate_limit',
      ) ||
          errorText.contains(
            'email rate limit exceeded',
          )) {
        message =
        'Too many email requests. Please wait a while and try again.';
      }

      else if (errorText.contains(
        'user already registered',
      ) ||
          errorText.contains(
            'already registered',
          )) {
        message =
        'This email is already registered. Please login instead.';
      }

      else if (errorText.contains(
        'socket',
      ) ||
          errorText.contains(
            'network',
          ) ||
          errorText.contains(
            'connection',
          )) {
        message =
        'Unable to connect. Please check your internet connection.';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
          backgroundColor:
          Colors.red,
          duration:
          const Duration(
            seconds: 4,
          ),
        ),
      );
    }
  }

  void showVerificationDialog(
      String email,
      ) {
    showDialog(
      context: context,
      barrierDismissible:
      false,

      builder: (context) {
        return AlertDialog(
          icon: const Icon(
            Icons
                .mark_email_read_outlined,
            color:
            Color(
              0xFF0B2344,
            ),
            size: 48,
          ),

          title:
          const Text(
            'Check Your Email',
          ),

          content: Text(
            'A verification email has been sent to:\n\n$email\n\nPlease verify your email before logging in.',
            textAlign:
            TextAlign.center,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );

                Navigator.pop(
                  context,
                );
              },

              child:
              const Text(
                'Back to Login',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
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
      appBar: AppBar(
        title:
        const Text(
          'Create Account',
        ),
      ),

      body: SafeArea(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets.all(
            24,
          ),

          child: Form(
            key:
            formKey,

            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,

                  backgroundColor:
                  navy,

                  child: Icon(
                    Icons
                        .directions_car_rounded,

                    size: 44,

                    color:
                    Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                const Text(
                  'Join 67AutoSpa',

                  style:
                  TextStyle(
                    color:
                    navy,

                    fontSize:
                    25,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                const Text(
                  'Create an account to manage your vehicles and bookings.',

                  textAlign:
                  TextAlign.center,

                  style:
                  TextStyle(
                    color:
                    Color(
                      0xFF7B8494,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                TextFormField(
                  controller:
                  nameController,

                  textCapitalization:
                  TextCapitalization
                      .words,

                  decoration:
                  const InputDecoration(
                    labelText:
                    'Full Name',

                    prefixIcon:
                    Icon(
                      Icons
                          .person_outline,
                    ),
                  ),

                  validator:
                      (value) {
                    if (value ==
                        null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Please enter your name';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 15,
                ),


                TextFormField(
                  controller:
                  emailController,

                  keyboardType:
                  TextInputType
                      .emailAddress,

                  decoration:
                  const InputDecoration(
                    labelText:
                    'Email',

                    prefixIcon:
                    Icon(
                      Icons
                          .email_outlined,
                    ),
                  ),

                  validator:
                      (value) {
                    if (value ==
                        null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Please enter your email';
                    }

                    if (!value
                        .contains('@') ||
                        !value
                            .contains('.')) {
                      return 'Please enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 15,
                ),

                TextFormField(
                  controller:
                  phoneController,

                  keyboardType:
                  TextInputType
                      .phone,

                  inputFormatters: [
                    FilteringTextInputFormatter
                        .allow(
                      RegExp(
                        r'[0-9+]',
                      ),
                    ),
                  ],

                  decoration:
                  const InputDecoration(
                    labelText:
                    'Phone Number',

                    prefixIcon:
                    Icon(
                      Icons
                          .phone_outlined,
                    ),
                  ),

                  validator:
                      (value) {
                    if (value ==
                        null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Please enter your phone number';
                    }

                    if (value
                        .trim()
                        .length <
                        9) {
                      return 'Please enter a valid phone number';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 15,
                ),

                TextFormField(
                  controller:
                  passwordController,

                  obscureText:
                  hidePassword,

                  decoration:
                  InputDecoration(
                    labelText:
                    'Password',

                    prefixIcon:
                    const Icon(
                      Icons
                          .lock_outline,
                    ),

                    suffixIcon:
                    IconButton(
                      onPressed:
                          () {
                        setState(
                              () {
                            hidePassword =
                            !hidePassword;
                          },
                        );
                      },

                      icon:
                      Icon(
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
                        value.isEmpty) {
                      return 'Please enter a password';
                    }

                    if (value.length <
                        6) {
                      return 'Password must have at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 15,
                ),

                TextFormField(
                  controller:
                  confirmPasswordController,

                  obscureText:
                  hideConfirmPassword,

                  decoration:
                  InputDecoration(
                    labelText:
                    'Confirm Password',

                    prefixIcon:
                    const Icon(
                      Icons
                          .lock_outline,
                    ),

                    suffixIcon:
                    IconButton(
                      onPressed:
                          () {
                        setState(
                              () {
                            hideConfirmPassword =
                            !hideConfirmPassword;
                          },
                        );
                      },

                      icon:
                      Icon(
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
                        value.isEmpty) {
                      return 'Please confirm your password';
                    }

                    if (value !=
                        passwordController
                            .text) {
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
                        : register,

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
                      'Create Account',

                      style:
                      TextStyle(
                        fontSize:
                        16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children: [
                    const Text(
                      'Already have an account?',
                    ),

                    TextButton(
                      onPressed:
                          () {
                        Navigator.pop(
                          context,
                        );
                      },

                      child:
                      const Text(
                        'Login',
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