import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_ride_sharing/methods/common_methods.dart';
import 'package:school_ride_sharing/screens/authentication/auth_services.dart';
import 'package:school_ride_sharing/screens/tabs.dart';
import 'package:school_ride_sharing/widgets/decorations/square_tile.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  bool hidePassword = true;
  bool _isLogin = true; // default is login page

  String _enteredUsername = '';
  String _enteredEmail = '';
  String _enteredPassword = '';

  void _submit() async {
    CommonMethods.checkConnectivity(context);

    final isValid = _form.currentState!.validate();

    if (!isValid) return;

    _form.currentState!.save();

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _enteredEmail, password: _enteredPassword);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
        });
      }
      if (!context.mounted) return;
      CommonMethods.displaySnackbar('Log in successfully', context);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const TabsScreen()));
    } on FirebaseAuthException catch (error) {
      if (!context.mounted) return;
      if (error.code == 'wrong-password') {
        CommonMethods.displaySnackbar('Wrong email or password', context);
      }

      CommonMethods.displaySnackbar(
          error.message ?? 'Failed to sign up', context);
    }
  }

  void googleSignIn() async {
    final googleUser = await AuthServices().signInWithGoogle();

    if (!context.mounted) return;

    if (googleUser == null) {
      CommonMethods.displaySnackbar('Failed to sign in with Google', context);
    }

    final User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      CommonMethods.displaySnackbar('Please try again later', context);
      return;
    }

    CommonMethods.storeUserData({
      'username': googleUser!.displayName,
      'email': googleUser.email,
    }, firebaseUser.uid);

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const TabsScreen()));
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
                          CommonMethods.displaySnackbar(
                              'username should be at least 5 characters',
                              context);
                        } else if (value.trim().length > 20) {
                          CommonMethods.displaySnackbar(
                              'username should not exceed 20 characters',
                              context);
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredUsername = value!.trim();
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
                      if (value == null || !value.contains('@')) {
                        CommonMethods.displaySnackbar(
                            'email address invalid', context);
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredEmail = value!.trim();
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
                        CommonMethods.displaySnackbar(
                            'password should be at least 5 characters',
                            context);
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredPassword = value!.trim();
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
                          //commonMethods.checkConnectivity(context);
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
