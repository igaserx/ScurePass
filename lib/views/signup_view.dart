import 'package:flutter/material.dart';
import 'package:scure_pass/views/login_view.dart';
import 'package:scure_pass/widgets/custom_button.dart';
import 'package:scure_pass/widgets/logo.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  //! ---- FormKey
  final formKey = GlobalKey<FormState>();
  //! ---- Controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConController = TextEditingController();
  //! ---- passwordsVisibility
  bool _isHidden = true;
  bool _isHidden2 = true;
  //! ---- Focus
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final passwordConFocus = FocusNode();


  @override
  void dispose() {
    //! ---- Controllers
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConController.dispose();
    //! ---- Focus
    emailFocus.dispose();
    passwordFocus.dispose();
    passwordConFocus.dispose();
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
            child: signUpForm(context),
          ),
        ),
      ),
    );
  }

  Form signUpForm(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //! ---- Logo
          Logo(),
          const SizedBox(height: 16),

          //! ---- Text
          _headerText(),
          const SizedBox(height: 40),

          //! ---- User Name
          userNameField(context),

          const SizedBox(height: 20),

          //! ---- Email
          emailField(context),

          const SizedBox(height: 20),

          //! ---- Password
          passwordField(context),

          const SizedBox(height: 20),

          //! ---- Password Confirmation
          passwordConfirmationField(),

          //! Go Sign In
          _goSignIn(context),

          const SizedBox(height: 30),

          //! ---- Done Button
          _doneButton(context),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  TextFormField userNameField(BuildContext context) {
    return TextFormField(
      controller: usernameController,
      validator: (value) => value!.isEmpty ? 'Required' : null,
      autofocus: true,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(emailFocus);
      },
      decoration: InputDecoration(
        labelText: "Username",
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  TextFormField emailField(BuildContext context) {
    return TextFormField(
      controller: emailController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Email is required";
        }
        if (!value.contains("@")) {
          return "Enter a valid email";
        }
        return null;
      },
      focusNode: emailFocus,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(passwordFocus);
      },
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Email",
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  TextFormField passwordField(BuildContext context) {
    return TextFormField(
      controller: passwordController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password is required";
        }
        if (value != passwordConController.text) {
          return "Passwords aren't the same";
        }
        return null;
      },
      focusNode: passwordFocus,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(passwordConFocus);
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

  TextFormField passwordConfirmationField() {
    return TextFormField(
      controller: passwordConController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password is required";
        }
        if (value != passwordController.text) {
          return "Passwords aren't the same";
        }

        return null;
      },
      focusNode: passwordConFocus,
      obscureText: _isHidden2,
      decoration: InputDecoration(
        labelText: "Password Confirmation",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_isHidden2 ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _isHidden2 = !_isHidden2;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Padding _goSignIn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text("You already have an account? "),
          InkWell(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (BuildContext context) => LoginView()),
            ),
            child: Text(
              "Sign in",
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

  CustomButton _doneButton(BuildContext context) {
    return CustomButton(
      text: "Done",
      onTap: () {
        // todo Sign Up
      },
    );
  }

  Column _headerText() {
    return Column(
      children: [
        const Text(
          "Sign Up",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          "Sign up to your Password Manager",
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
