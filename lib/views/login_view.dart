import "package:flutter/material.dart";
import "package:scure_pass/data/db/sqlite.dart";
import "package:scure_pass/models/user_model.dart";
import "package:scure_pass/views/home_view.dart";
import "package:scure_pass/views/signup_view.dart";
import "package:scure_pass/widgets/custom_button.dart";
import "package:scure_pass/widgets/logo.dart";

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  //! ---- Key
  final formKey = GlobalKey<FormState>();
  //! ---- Controllers
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  //! ---- Focus
  final passwordFocus = FocusNode();
  //! ---- Password
  bool _isHidden = true;

  final db = DBHelper();

  //! ---- Login 
  login() async {
    final isLogin = await db.login(
      User(
        username: userNameController.text,
        hashedPassword: db.hashPassword(passwordController.text),
      ),
    );
    if (!mounted) return;
    if (isLogin) {
      // Login Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful"),
          backgroundColor: Colors.green,
        ),
      );
      //If login is correct,
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid username or password"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    //! ----
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),

            //! ---- Form
            child: loginForm(context),
          ),
        ),
      ),
    );
  }

  Form loginForm(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //! ---- Logo
          Logo(),

          const SizedBox(height: 16),

          //! ---- Welcome Text
          _welcomeText(),

          const SizedBox(height: 40),

          //! ------- Email
          userNameField(context),

          const SizedBox(height: 20),

          //! ---- Password
          passwordField(),

          //! ---- Go Sign Up
          _goSignUp(context),

          const SizedBox(height: 30),

          //! ---- Login Button
          _loginButton(context),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Column _welcomeText() {
    return Column(
      children: [
        const Text(
          "Welcome Back",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          "Sign in to your Password Manager",
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Padding _goSignUp(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text("You don't have an account? "),
          InkWell(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => SignUpView(),
              ),
            ),
            child: Text(
              "Sign up",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  CustomButton _loginButton(BuildContext context) {
    return CustomButton(
      text: "Sign In",
      onTap: () {
        if (formKey.currentState!.validate()) {
          login();
        }
      },
    );
  }

  TextFormField userNameField(BuildContext context) {
    return TextFormField(
      controller: userNameController,
      autofocus: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Username is required";
        }

        return null;
      },
      onFieldSubmitted: (_) =>
          FocusScope.of(context).requestFocus(passwordFocus),
      decoration: InputDecoration(
        labelText: "Username",
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  TextFormField passwordField() {
    return TextFormField(
      controller: passwordController,
      focusNode: passwordFocus,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password is required";
        }

        return null;
      },
      obscureText: _isHidden,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_isHidden ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _isHidden = !_isHidden;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
