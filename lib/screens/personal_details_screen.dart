import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_model.dart';
import '../services/database_helper.dart';
import '../services/user_session.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({
    super.key,
  });

  @override
  State<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState
    extends State<PersonalDetailsScreen> {

  final formKey = GlobalKey<FormState>();

  final nameController =
  TextEditingController();

  final emailController =
  TextEditingController();

  final phoneController =
  TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final user =
        UserSession.currentUser;

    if (user != null) {
      nameController.text =
          user.name;

      emailController.text =
          user.email;

      phoneController.text =
          user.phone;
    }
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!
        .validate()) {
      return;
    }

    final user =
        UserSession.currentUser;

    if (user == null ||
        user.id == null) {
      showMessage(
        'Please login again.',
        Colors.red,
      );

      return;
    }

    String name =
    nameController.text.trim();

    String phone =
    phoneController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      UserModel updatedUser =
      UserModel(
        id: user.id,
        name: name,
        email: user.email,
        phone: phone,
      );

      await DatabaseHelper.instance
          .updateUser(
        updatedUser,
      );

      UserSession.login(
        updatedUser,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Personal details updated successfully.',
          ),
          backgroundColor:
          Colors.green,
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      debugPrint(
        'Update profile error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      showMessage(
        'Unable to update profile.',
        Colors.red,
      );
    }
  }

  void showMessage(
      String message,
      Color color,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        backgroundColor:
        color,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(
        0xFFF3F6FA,
      ),

      appBar: AppBar(
        title: const Text(
          'Personal Details',
        ),
      ),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(
          20,
        ),

        child: Form(
          key: formKey,

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .stretch,

            children: [
              const SizedBox(
                height: 10,
              ),

              const CircleAvatar(
                radius: 50,
                backgroundColor:
                Color(
                  0xFFEAF1FA,
                ),

                child: Icon(
                  Icons.person_rounded,
                  color:
                  Color(
                    0xFF0B2344,
                  ),
                  size: 55,
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              const Text(
                'Account Information',
                style: TextStyle(
                  color:
                  Color(
                    0xFF0B2344,
                  ),
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              const Text(
                'Update your personal information.',
                style: TextStyle(
                  color:
                  Colors.grey,
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              TextFormField(
                controller:
                nameController,

                keyboardType:
                TextInputType.name,

                textCapitalization:
                TextCapitalization
                    .words,

                decoration:
                const InputDecoration(
                  labelText:
                  'Full Name',

                  prefixIcon:
                  Icon(
                    Icons.person_outline,
                  ),
                ),

                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Please enter your name';
                  }

                  if (value
                      .trim()
                      .length <
                      2) {
                    return 'Please enter a valid name';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                emailController,

                enabled: false,

                decoration:
                const InputDecoration(
                  labelText:
                  'Email',

                  prefixIcon:
                  Icon(
                    Icons.email_outlined,
                  ),

                  helperText:
                  'Email is used for your login account.',
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                phoneController,

                keyboardType:
                TextInputType.phone,

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
                    Icons.phone_outlined,
                  ),
                ),

                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Please enter phone number';
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
                height: 25,
              ),

              SizedBox(
                height: 52,

                child: ElevatedButton(
                  onPressed:
                  isLoading
                      ? null
                      : updateProfile,

                  style:
                  ElevatedButton
                      .styleFrom(
                    backgroundColor:
                    const Color(
                      0xFF0B2344,
                    ),

                    foregroundColor:
                    Colors.white,
                  ),

                  child: isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,

                    child:
                    CircularProgressIndicator(
                      color:
                      Colors.white,
                      strokeWidth:
                      2.5,
                    ),
                  )
                      : const Text(
                    'Save Changes',
                    style:
                    TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}