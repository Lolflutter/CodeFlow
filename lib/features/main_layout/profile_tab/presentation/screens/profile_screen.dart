import 'package:flutter/material.dart';
import 'package:graduation_project/core/theme/app_colors.dart';
import 'package:graduation_project/features/auth/presentation/manager/auth_view_model.dart';
import 'package:graduation_project/features/auth/presentation/widgets/custom_button.dart';
import 'package:graduation_project/features/main_layout/profile_tab/presentation/widgets/custom_profile_containers.dart';
import 'package:provider/provider.dart';
import '../../../../../core/routes/app_routes_name.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../manager/user_view_model.dart';


class ProfileScreen extends StatefulWidget {
  final void Function({int subTabIndex})? navigateToHomeTab;

   const ProfileScreen({super.key,  this.navigateToHomeTab});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<UserViewModel>(context, listen: false).fetchUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    var local =AppLocalizations.of(context);
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.gray,
        title: Text(
          local!.account,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.gray,
      body: Consumer2<AuthViewModel,UserViewModel>(
        builder:
            (context, authVm,userVm ,child) => Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.03),
                  Container(
                    height: size.height * 0.15,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      shape: BoxShape.circle
                    ),
                    child: Center(child: Icon(Icons.person_outline,color: AppColors.white,size: 48,)),
                  ),
                  SizedBox(height: size.height * 0.03),

                  Text(
                    '${local.hi},${userVm.usernameController.text}',
                    style: TextStyle(color: AppColors.white, fontSize: 20),
                  ),
                  Text(
                    userVm.emailController.text,
                    style: TextStyle(color: AppColors.white, fontSize:11 ),
                  ),
                  SizedBox(height: size.height * 0.03),

                  CustomProfileContainers(
                      text: local.profile,
                      onTap:() {
                        Navigator.pushNamed(context, AppRoutesName.profileDetails);

                      },
                    icon:Icon(Icons.person, color: AppColors.white,size: 19,) ,
                  ),
                  SizedBox(height: 17,),
                  CustomProfileContainers(
                    text: local.myProjects,
                    onTap:() {
                      widget.navigateToHomeTab!(subTabIndex: 1);
                    },
                    icon:Icon(Icons.file_copy, color: AppColors.white,size: 19,) ,
                  ),
                  SizedBox(height: 17,),
                  CustomProfileContainers(
                    text: local.importLink,
                    onTap:() {
                      widget.navigateToHomeTab!(subTabIndex: 3);
                    },
                    icon:Icon(Icons.link_rounded, color: AppColors.white,size: 19,) ,
                  ),
                  SizedBox(height: 17,),

                  Spacer(),
                  CustomButton(
                    text: local.logout,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.gray,
                          title: Text(
                            local.confirmLogout,
                            style: TextStyle(color: AppColors.white),
                          ),
                          content: Text(
                            local.areYouSureYouWantToLogout,
                            style: TextStyle(color: AppColors.white),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text(local.cancel, style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context); // Close the dialog first
                                await authVm.logout();
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutesName.loginScreen,
                                );
                              },
                              child: Text(local.logout, style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },

                    icon: Icon(Icons.logout_rounded, color: AppColors.white),
                  ),
                ],
              ),
            ),
      ),

    );
  }
}
