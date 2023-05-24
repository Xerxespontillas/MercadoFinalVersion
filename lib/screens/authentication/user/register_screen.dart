// ignore_for_file: unused_field

import 'package:flutter/material.dart';

import 'package:merkado/screens/authentication/user/validators.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
  static const routeName = '/register';
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final orgController = TextEditingController();
  final roleController = TextEditingController();
  bool _farmerOrgVisible = false;
  var _value = 1;

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
    orgController.dispose();
    roleController.dispose();
    super.dispose();
  }

  Widget myDropdownButton(TextEditingController controller) {
    return DropdownButtonFormField<int>(
      value: 0,
      onChanged: (value) {
        setState(() {
          _value = value!;
          if (value == 0) {
            controller.text = 'Select a User Type';
            _farmerOrgVisible = false;
          } else if (value == 1) {
            controller.text = 'Customer';
            _farmerOrgVisible = false;
          } else if (value == 2) {
            controller.text = 'Farmer';
            _farmerOrgVisible = false;
          } else if (value == 3) {
            controller.text = 'Organization';
            _farmerOrgVisible = true;
          }
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        labelStyle: const TextStyle(
          color: Colors.black,
        ),
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
      ),
      items: const [
        DropdownMenuItem<int>(
          value: 0,
          child: Text(
            'Select a User Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DropdownMenuItem<int>(
          value: 1,
          child: Text(
            'Customer',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DropdownMenuItem<int>(
          value: 2,
          child: Text(
            'Farmer',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DropdownMenuItem<int>(
          value: 3,
          child: Text(
            'Organization',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40.0),
                    const Center(
                      child: Text(
                        'SIGN UP',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Personal Information',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        )),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your Full Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            width: 2.0, // Set the width of the border
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        labelStyle: const TextStyle(
                          color: Colors.black,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      validator: validateDisplayName,
                      onChanged: (value) {
                        // Do something with the user input
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        hintText: 'Enter your Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        labelStyle: const TextStyle(
                          color: Colors
                              .black, // Set the color of the label text to black
                        ),
                        hintStyle: const TextStyle(
                          color: Colors
                              .grey, // Set the color of the hint text to black
                        ),
                      ),
                      validator: validateAddress,
                      onChanged: (value) {
                        // Do something with the user input
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter your Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        labelStyle: const TextStyle(
                          color: Colors
                              .black, // Set the color of the label text to black
                        ),
                        hintStyle: const TextStyle(
                          color: Colors
                              .grey, // Set the color of the hint text to black
                        ),
                      ),
                      validator: validatePhoneNumber,
                      onChanged: (value) {
                        // Do something with the user input
                      },
                    ),
                    const SizedBox(height: 25),
                    const Text('User Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        )),
                    const SizedBox(height: 5),
                    myDropdownButton(roleController),
                    Visibility(
                      visible: _farmerOrgVisible,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: orgController,
                            decoration: InputDecoration(
                              labelText: 'Organization Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              prefixIcon: const Icon(
                                Icons.groups_2_rounded,
                                color: Colors.black,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              labelStyle: const TextStyle(
                                color: Colors
                                    .black, // Set the color of the label text to black
                              ),
                              hintStyle: const TextStyle(
                                color: Colors
                                    .grey, // Set the color of the hint text to black
                              ),
                            ),
                            validator: (value) {
                              if (_farmerOrgVisible && value!.isEmpty) {
                                return 'Please enter your organization name.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        labelStyle: const TextStyle(
                          color: Colors
                              .black, // Set the color of the label text to black
                        ),
                        hintStyle: const TextStyle(
                          color: Colors
                              .grey, // Set the color of the hint text to black
                        ),
                      ),
                      validator: validateEmail,
                      onChanged: (value) {
                        // Do something with the user input
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.black,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        labelStyle: const TextStyle(
                          color: Colors
                              .black, // Set the color of the label text to black
                        ),
                        hintStyle: const TextStyle(
                          color: Colors
                              .grey, // Set the color of the hint text to black
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      validator: validatePassword,
                      onChanged: (value) {
                        // Do something with the user input
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.black,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        labelStyle: const TextStyle(
                          color: Colors
                              .black, // Set the color of the label text to black
                        ),
                        hintStyle: const TextStyle(
                          color: Colors
                              .grey, // Set the color of the hint text to black
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Confirm password is required';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                      onChanged: (value) {
                        // Do something with the user input
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 5.0,
                            ),
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(90, 15, 90, 15),
                          child: Text(
                            "SIGN UP",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          if (formKey.currentState?.validate() ?? false) {
                            await authProvider.register(
                              formKey: formKey,
                              emailController: emailController,
                              passwordController: passwordController,
                              fullNameController: fullNameController,
                              addressController: addressController,
                              phoneNumberController: phoneNumberController,
                              roleController: roleController,
                              orgController: orgController,
                            );

                            if (authProvider.isAuthenticated) {
                              // Determine the user's role type
                              String role = roleController.text;
                              String snackbarMessage = '';

                              if (role == 'Customer') {
                                snackbarMessage =
                                    'Successfully registered as a Customer!';
                              } else if (role == 'Farmer') {
                                snackbarMessage =
                                    'Successfully registered as a Farmer!';
                              } else if (role == 'Organization') {
                                snackbarMessage =
                                    'Successfully registered as an Organization!';
                              }

                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(snackbarMessage)),
                              );

                              // ignore: use_build_context_synchronously
                              Navigator.pushReplacementNamed(
                                  context, '/login-user');
                            } else {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Registration failed.')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 30, 0, 20),
                      //child: Text('Don\'t have an account? Create'),
                      child: const Text(
                        "Already have an account?",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(
                              color: Colors.black,
                              width: 5.0,
                            ),
                          ),
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(90, 15, 90, 15),
                          child: Text(
                            "LOG IN",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, '/login-user');
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
