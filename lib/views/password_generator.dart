import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:random_password_generator/random_password_generator.dart";

class PasswordGenerator extends StatefulWidget {
  const PasswordGenerator({super.key});

  @override
  State<PasswordGenerator> createState() => _PasswordGeneratorState();
}

class _PasswordGeneratorState extends State<PasswordGenerator> {
  bool isHidden = false;
  final genPassController = TextEditingController();
  final lengthController = TextEditingController();

  //! ---- Options
  bool letters = true;
  bool numbers = false;
  bool uppercase = false;
  bool specialChar = false;
  double passwordLength = 8.0;

  //! ---- Password Generator
  final password = RandomPasswordGenerator();

  @override
  void initState() {
    super.initState();
    lengthController.text = passwordLength.toInt().toString();
    generateNewPassword();
  }

  @override
  void dispose() {
    genPassController.dispose();
    lengthController.dispose();
    super.dispose();
  }

  void generateNewPassword() {
    final pass = password.randomPassword(
      letters: letters,
      numbers: numbers,
      passwordLength: passwordLength,
      specialChar: specialChar,
      uppercase: uppercase,
    );
    setState(() {
      genPassController.text = pass;
    });
  }

  double passwordStrength(String pass) {
    return password.checkPassword(password: pass);
  }

  String getPasswordQuality(double strength) {
    if (strength < 0.3) {
      return "Weak";
    } else if (strength < 0.7) {
      return "Good";
    } else {
      return "Excellent";
    }
  }

  Color getStrengthColor(double strength) {
    if (strength < 0.3) {
      return Colors.red;
    } else if (strength < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  void updatePasswordLength(double value) {
    setState(() {
      passwordLength = value;
      lengthController.text = value.toInt().toString();
      generateNewPassword();
    });
  }

  void updateLengthFromTextField(String value) {
    final intValue = int.tryParse(value);
    if (intValue != null && intValue >= 8 && intValue <= 32) {
      setState(() {
        passwordLength = intValue.toDouble();
        generateNewPassword();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = passwordStrength(genPassController.text);
    final quality = getPasswordQuality(strength);
    final strengthColor = getStrengthColor(strength);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //! ---- Password Field
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
                      TextField(
                        controller: genPassController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        obscureText: isHidden,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isHidden = !isHidden;
                              });
                            },
                            icon: Icon(
                              isHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            tooltip: isHidden
                                ? "Show Password"
                                : "Hide Password",
                          ),
                          border: const OutlineInputBorder(gapPadding: 0),
                        ),
                      ),

                      const SizedBox(height: 8),

                      //! ---- Password Strength Indicator
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Colors.grey.shade300,
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: strength,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: strengthColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: generateNewPassword,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: "Generate New Password",
                ),
              ),
              SizedBox(width: 8),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: genPassController.text),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password Copied to Clipboard"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, color: Colors.white),
                  tooltip: "Copy Password",
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          //! ---- Password Quality
          Row(
            children: [
              const Text("Password Quality: ", style: TextStyle(fontSize: 14)),
              Text(
                quality,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: strengthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          //! ---- Length Slider
          Row(
            children: [
              const Text("Length:", style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: passwordLength,
                  min: 8,
                  max: 32,
                  label: passwordLength.toInt().toString(),
                  onChanged: updatePasswordLength,
                ),
              ),
              Container(
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: TextField(
                  controller: lengthController,
                  textAlign: TextAlign.center,
                  readOnly: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    var val = double.parse(value);
                    setState(() {
                      passwordLength = val;
                      generateNewPassword();
                    });
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          //! ---- Character Options
          Row(
            children: [
              _buildOptionButton(
                label: "A-Z",
                isSelected: uppercase,
                onTap: () {
                  setState(() {
                    uppercase = !uppercase;
                    generateNewPassword();
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildOptionButton(
                label: "a-z",
                isSelected: letters,
                onTap: () {
                  setState(() {
                    letters = !letters;
                    generateNewPassword();
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildOptionButton(
                label: "0-9",
                isSelected: numbers,
                onTap: () {
                  setState(() {
                    numbers = !numbers;
                    generateNewPassword();
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildOptionButton(
                label: "/*+&...",
                isSelected: specialChar,
                onTap: () {
                  setState(() {
                    specialChar = !specialChar;
                    generateNewPassword();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
