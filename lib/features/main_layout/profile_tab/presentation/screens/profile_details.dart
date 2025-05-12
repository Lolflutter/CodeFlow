import 'package:flutter/material.dart';
import 'package:graduation_project/core/theme/app_colors.dart';
import 'package:graduation_project/features/main_layout/profile_tab/presentation/manager/user_view_model.dart';
import 'package:graduation_project/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserViewModel>(context, listen: false).fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    var local = AppLocalizations.of(context)!;
    var size = MediaQuery.of(context).size;

    return Consumer2<UserViewModel, LanguageProvider>(
      builder: (context, userVm, langProvider, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.gray,
          iconTheme: const IconThemeData(color: AppColors.white),
          title: Text(local.profile, style: const TextStyle(color: AppColors.white)),
          actions: [
            if (userVm.hasChanges)
              TextButton(
                onPressed: () async {
                  await userVm.updateUserInfo(
                    newUsername: userVm.usernameController.text,
                    newEmail: userVm.emailController.text,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("profileUpdatedSuccessfully")),
                    );
                  }
                },
                child: const Text('Save', style: TextStyle(color: AppColors.white)),
              ),
          ],
          centerTitle: true,
        ),
        backgroundColor: AppColors.gray,
        body: userVm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(local.name, style: const TextStyle(color: AppColors.white, fontSize: 13)),
              const SizedBox(height: 10),
              _buildTextField(userVm.usernameController),
              const SizedBox(height: 20),
              Text(local.email, style: const TextStyle(color: AppColors.white, fontSize: 13)),
              const SizedBox(height: 10),
              _buildTextField(userVm.emailController),
              const SizedBox(height: 20),
              Text(local.language, style: const TextStyle(color: AppColors.white, fontSize: 13)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: size.height * 0.07,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.lightGray,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: langProvider.lang,
                    dropdownColor: Colors.grey[850],
                    style: const TextStyle(color: Colors.white),
                    iconEnabledColor: Colors.white,
                    alignment: AlignmentDirectional.centerEnd,
                    items: langProvider.languages.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(entry.value, style: const TextStyle(color: Colors.white)),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        langProvider.setLanguage(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.lightGray,
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.lightGray),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.lightGray),
            borderRadius: BorderRadius.circular(16),
          ),
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }
}

