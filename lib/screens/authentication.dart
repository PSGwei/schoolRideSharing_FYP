import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_ride_sharing/utilities/authentication_method.dart';
import 'package:school_ride_sharing/utilities/common_methods.dart';
import 'package:school_ride_sharing/screens/tabs.dart';
import 'package:school_ride_sharing/widgets/decorations/square_tile.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMethods authMethods = AuthMethods();

  final _form = GlobalKey<FormState>();
  bool hidePassword = true;
  bool _isLogin = true; // default is login page

  String enteredUsername = '';
  String enteredEmail = '';
  String enteredPassword = '';
  String gender = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();
    final String result;

    if (!isValid) return;

    _form.currentState!.save();

    try {
      // login
      if (_isLogin) {
        result = await authMethods.loginUser(enteredEmail, enteredPassword);
      } else {
        // sign up
        result = await authMethods.signUp(
          email: enteredEmail,
          password: enteredPassword,
          username: enteredUsername,
          gender: gender,
          imagePath: 'assets/images/avatarman.png',
        );
      }
      if (!context.mounted) return;
      displaySnackbar(result, context);

      if (result == 'Success') {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TabsScreen()));
      }
    } on FirebaseAuthException catch (error) {
      if (!context.mounted) return;
      if (error.code == 'wrong-password') {
        displaySnackbar('Wrong email or password', context);
      }

      // displaySnackbar(error.message ?? 'Failed to sign up', context);
    }
  }

  void googleSignIn() async {
    final result = await authMethods.signInWithGoogle();

    if (!context.mounted) return;
    if (result == "Success") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const TabsScreen()));
    }

    displaySnackbar('Failed to sign in with Google', context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Form(
              key: _form,
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  // logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    height: 200,
                  ),
                  _isLogin
                      ? const Text(
                          'Sign in now!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Text(
                          'Create a User\'s Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 40),
                  // Username
                  if (!_isLogin)
                    TextFormField(
                      maxLength: 20,
                      decoration: InputDecoration(
                        label: _isLogin
                            ? const Text('Username/Email')
                            : const Text('Username'),
                        border: const OutlineInputBorder(),
                        counterText: '',
                      ),
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length < 5) {
                          return 'username should be at least 5 characters';
                        } else if (value.trim().length > 20) {
                          return 'username should not exceed 20 characters';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        enteredUsername = value!.trim();
                      },
                    ),
                  const SizedBox(height: 30),
                  // Email
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text('Email Address'),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final RegExp emailRegex =
                          RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

                      if (value == null || !emailRegex.hasMatch(value)) {
                        return 'email address invalid';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      enteredEmail = value!.trim();
                    },
                  ),
                  const SizedBox(height: 30),
                  // Password
                  TextFormField(
                    decoration: InputDecoration(
                      label: const Text('Password'),
                      border: const OutlineInputBorder(),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        child: hidePassword
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility),
                      ),
                    ),
                    obscureText: hidePassword,
                    validator: (value) {
                      if (value == null || value.trim().length < 6) {
                        return 'password should be at least 5 characters';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      enteredPassword = value!.trim();
                    },
                  ),

                  const SizedBox(height: 30),
                  // Sign up button
                  ElevatedButton(
                    onPressed: _submit,
                    child: _isLogin
                        ? const Text('Sign In')
                        : const Text('Sign Up'),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                        ),
                      ),
                      Text('Or continue with'),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Sign in with Google account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareTile(
                        imagePath: 'assets/images/google_icon.png',
                        onTap: googleSignIn,
                      ),
                    ],
                  ),
                  // Direct to Sign In page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLogin
                          ? const Text('Doesn\'t have an account?')
                          : const Text('Already have an account?'),
                      TextButton(
                        onPressed: () {
                          //checkConnectivity(context);
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        style: const ButtonStyle(
                          overlayColor:
                              MaterialStatePropertyAll(Colors.transparent),
                        ),
                        child: _isLogin
                            ? const Text('Sign Up here')
                            : const Text('Sign In here'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
