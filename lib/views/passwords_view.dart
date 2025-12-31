import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:scure_pass/controllers/pass_cubit.dart";
import "package:scure_pass/controllers/pass_state.dart";
import "package:scure_pass/data/repo/passwords_repo.dart";
import "package:scure_pass/models/password_model.dart";


class PasswordsView extends StatelessWidget {
  const PasswordsView({super.key});

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deletePassword(
    BuildContext context,
    PasswordModel passwordModel,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Password"),
        content: Text(
          "Are you sure you want to delete '${passwordModel.title}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete",style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<PasswordCubit>().deletePassword(passwordModel.id!);
    }
  }

  void _showPasswordDetails(
    BuildContext context,
    PasswordModel passwordModel,
    PasswordsRepo passRepo,
  ) {
    bool showPassword = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.key, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  passwordModel.title,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // URL Section
                if (passwordModel.url != null &&
                    passwordModel.url!.isNotEmpty) ...[
                  _buildInfoSection(
                    context: context,
                    label: "URL",
                    value: passwordModel.url!,
                    icon: Icons.link,
                    onCopy: () => _copyToClipboard(
                      context,
                      passwordModel.url!,
                      "URL Copied",
                    ),
                  ),
                  const Divider(height: 24),
                ],

                // Username Section
                _buildInfoSection(
                  context: context,
                  label: "Username",
                  value: passwordModel.username,
                  icon: Icons.person,
                  onCopy: () => _copyToClipboard(
                    context,
                    passwordModel.username,
                    "Username Copied",
                  ),
                ),
                const Divider(height: 24),

                // Password Section
                _buildPasswordSection(
                  context: context,
                  passwordModel: passwordModel,
                  passRepo: passRepo,
                  showPassword: showPassword,
                  onToggleVisibility: () {
                    setDialogState(() {
                      showPassword = !showPassword;
                    });
                  },
                  onCopy: () => _copyToClipboard(
                    context,
                    passRepo.decryptPassword(passwordModel.encryptedPassword),
                    "Password Copied",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deletePassword(context, passwordModel);
              },
              icon: const Icon(Icons.delete),
              label: const Text("Delete"),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: onCopy,
              tooltip: "Copy",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordSection({
    required BuildContext context,
    required PasswordModel passwordModel,
    required PasswordsRepo passRepo,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
    required VoidCallback onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              "Password",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                showPassword
                    ? passRepo.decryptPassword(passwordModel.encryptedPassword)
                    : "••••••••",
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: showPassword ? 0 : 2,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                showPassword ? Icons.visibility :Icons.visibility_off,
                size: 20,
              ),
              onPressed: onToggleVisibility,
              tooltip: showPassword ? "Hide" : "Show",
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: onCopy,
              tooltip: "Copy",
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final  passRepo = PasswordsRepo();
    return BlocConsumer<PasswordCubit, PasswordState>(
      listener: (context, state) {
        if (state is PasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is PasswordOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is PasswordLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PasswordError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.read<PasswordCubit>().getPasswords(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        final passwords = state is PasswordLoaded
            ? state.passwords
            : state is PasswordOperationSuccess
                ? state.passwords
                : <PasswordModel>[];

        return Column(
          children: [
            Expanded(
              child: passwords.isEmpty
                  ? _buildEmptyState()
                  : _buildPasswordsList(context, passwords,passRepo),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No passwords yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your first password to get started",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordsList(
    BuildContext context,
    List<PasswordModel> passwords,
    PasswordsRepo passRepo,
  ) {
    return RefreshIndicator(
      onRefresh: () => context.read<PasswordCubit>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: passwords.length,
        itemBuilder: (context, index) {
          final item = passwords[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).primaryColor.withValues(alpha:  0.1),
                child: Icon(
                  Icons.key,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  item.username,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showPasswordDetails(context, item, passRepo),
            ),
          );
        },
      ),
    );
  }
}