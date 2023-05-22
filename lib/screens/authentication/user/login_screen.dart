import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';

import 'register_screen.dart';
import 'forgot_password.dart';
import 'connectivity_utils.dart';
import 'login_validator.dart';

import '/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/login_user';
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

late ConnectivityResult _connectivityResult;

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Check for internet connectivity when the screen is loaded
    Connectivity().checkConnectivity().then((result) {
      setState(() {
        _connectivityResult = result;
        if (_connectivityResult == ConnectivityResult.none) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("No Internet Connection"),
                content: const Text(
                    "Please check your internet connection and try again."),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                margin: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Column(
                  children: [
                    const Text(
                      'LOG IN',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 65,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30.0),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.black,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: validateEmail,
                            onChanged: (value) {
                              // Do something with the user input
                            },
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.black,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: _togglePasswordVisibility,
                              ),
                            ),
                            validator: validatePassword,
                          ),
                          const SizedBox(height: 10.0),
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                            alignment: Alignment.topLeft,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, ForgotPasswordScreen.routeName);
                              },
                              child: const Text(
                                "Forgot your password?",
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
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
                              padding: EdgeInsets.fromLTRB(90, 20, 90, 20),
                              child: Text(
                                "LOG IN",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              bool isConnected =
                                  await checkConnectivityAndHandleLogin(
                                      context);
                              if (isConnected) {
                                // ignore: use_build_context_synchronously
                                authProvider.login(
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  context: context,
                                );
                              }
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 40, 10, 20),
                            child: Row(
                              children: const [
                                Expanded(
                                  child: Divider(
                                    color: Colors.black,
                                    height: 1,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.black,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                            //child: Text('Don\'t have an account? Create'),
                            child: const Text(
                              "Don't have an account?",
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 5.0,
                                ),
                              ),
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 0, 0),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(90, 20, 90, 20),
                              child: Text(
                                "SIGN UP",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen()));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
