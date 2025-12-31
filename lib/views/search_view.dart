import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:scure_pass/controllers/pass_cubit.dart";
import "package:scure_pass/controllers/pass_state.dart";
import "package:scure_pass/data/repo/passwords_repo.dart";
import "package:scure_pass/models/password_model.dart";

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PasswordModel> _getFilteredPasswords(List<PasswordModel> allPasswords) {
    if (_searchQuery.isEmpty) {
      return allPasswords;
    }

    return allPasswords
        .where(
          (item) =>
              item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.username.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              (item.url?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                  false),
        )
        .toList();
  }

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

  @override
  Widget build(BuildContext context) {
    final passRepo = PasswordsRepo();

    return BlocBuilder<PasswordCubit, PasswordState>(
      builder: (context, state) {

        final allPasswords = state is PasswordLoaded
            ? state.passwords
            : state is PasswordOperationSuccess
            ? state.passwords
            : <PasswordModel>[];


        final filteredPasswords = _getFilteredPasswords(allPasswords);

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search passwords...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = "";
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
              ),
            ),

            // Results
            Expanded(
              child: state is PasswordLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredPasswords.isEmpty
                  ? _buildEmptyState(allPasswords.isEmpty)
                  : _buildResultsList(context, filteredPasswords, passRepo),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(bool noPasswords) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            noPasswords ? Icons.lock_outline : Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            noPasswords ? "No passwords yet" : "No results found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            noPasswords
                ? "Add your first password to get started"
                : "Try a different search term",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    List<PasswordModel> passwords,
    PasswordsRepo passRepo,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                item.title[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    );
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
            Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
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
                showPassword ? Icons.visibility : Icons.visibility_off,
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
}
