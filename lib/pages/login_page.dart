import 'package:flutter/material.dart';
import 'package:upddat/components/action_button.dart';
import 'package:upddat/components/input_text_field.dart';
import 'package:upddat/components/spinner.dart';
import 'package:upddat/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // auth service
  final _auth = AuthService();

  // textfield controllers:
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    // show loading spinner
    showLoadingSpinner(context);

    try {
      await _auth.loginEmailPassword(
          emailController.text, passwordController.text);
      // finished loading
      if (mounted) hideLoadingSpinner(context);
    } catch (e) {
      if (mounted) hideLoadingSpinner(context);
      // show the user an error message
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Invalid credentials'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  // logo
                  Icon(
                    Icons.lock_open_rounded,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  // welcome back
                  Text(
                    'Welcome back, you\'ve been missed!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  // email textfield
                  InputTextField(
                    controller: emailController,
                    hintText: 'enter email address',
                    obscureText: false,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // password textfield
                  InputTextField(
                    controller: passwordController,
                    hintText: 'enter password',
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // forgot password?
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  // sign in button
                  ActionButton(
                    text: 'Login',
                    onTap: login,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  // not a member? register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Register now',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
