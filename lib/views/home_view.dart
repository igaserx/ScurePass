import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:scure_pass/controllers/pass_cubit.dart";
import "package:scure_pass/data/repo/passwords_repo.dart";
import "package:scure_pass/models/password_model.dart";
import "package:scure_pass/models/user_model.dart";
import "package:scure_pass/views/password_generator.dart";
import "package:scure_pass/views/passwords_view.dart";
import "package:scure_pass/views/profile_view.dart";
import "package:scure_pass/views/search_view.dart";
import "package:scure_pass/widgets/logo.dart";

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.user});
  final User user;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final passRepo = PasswordsRepo();
  int currentIndex = 0;

  List<Widget> get _pages => [
    const PasswordsView(),
    const SearchView(),
    const PasswordGenerator(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Logo(size: 24),
        title: const Text(
          "Scure Pass",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 2,
      ),
      body: _pages[currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPasswordDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search_rounded),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.password_outlined),
          activeIcon: Icon(Icons.password),
          label: "Generate",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }

  void _showAddPasswordDialog() {
    final titleController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final urlController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isHidden = true;

    final cubit = context.read<PasswordCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.add_circle_outline),
              SizedBox(width: 8),
              Text("Add New Password"),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter a title";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter a username";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: isHidden,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            isHidden = !isHidden;
                          });
                        },
                        icon: Icon(
                          isHidden ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a password";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      labelText: "URL (Optional)",
                      prefixIcon: Icon(Icons.link),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext);

                  await cubit.addPassword(
                    PasswordModel(
                      title: titleController.text.trim(),
                      username: usernameController.text.trim(),
                      encryptedPassword: passRepo.encryptPassword(
                        passwordController.text,
                      ),
                      url: urlController.text.trim().isEmpty
                          ? null
                          : urlController.text.trim().startsWith("http")
                          ? urlController.text.trim()
                          : "https://${urlController.text.trim()}",
                      userId: widget.user.id!,
                      createdAt: DateTime.now(),
                    ),
                  );
                }
              },
              label: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
