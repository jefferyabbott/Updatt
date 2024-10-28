import 'package:flutter/material.dart';
import 'package:upddat/components/spinner.dart';
import 'package:upddat/services/auth/auth_service.dart';
import 'package:upddat/services/database/database_service.dart';
import '../components/action_button.dart';
import '../components/input_text_field.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // auth service
  final _auth = AuthService();
  final _db = DatabaseService();

  // textfield controllers:
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  void register() async {
    // passwords match
    if (passwordController.text == passwordConfirmationController.text) {
      // show loading circle
      showLoadingSpinner(context);
      // attempt to register user
      try {
        await _auth.registerEmailPassword(
          emailController.text,
          passwordController.text,
        );
        // finsihed loading
        if (mounted) hideLoadingSpinner(context);
        // once registered, create and save user profile
        await _db.saveUserInfoInFirebase(
            name: nameController.text, email: emailController.text);
      } catch (e) {
        if (mounted) hideLoadingSpinner(context);
        // notify user of the error
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                e.toString(),
              ),
            ),
          );
        }
      }
    }
    // passwords don't math
    else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords don't match"),
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
                    "Let's create an account for you!",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  // name textfield
                  InputTextField(
                    controller: nameController,
                    hintText: 'enter name',
                    obscureText: false,
                  ),
                  const SizedBox(
                    height: 10,
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
                  // password confirmation textfield
                  InputTextField(
                    controller: passwordConfirmationController,
                    hintText: 'confirm password',
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  // sign in button
                  ActionButton(
                    text: 'Sign up',
                    onTap: register,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  // already a member? login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already a member?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Login',
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
