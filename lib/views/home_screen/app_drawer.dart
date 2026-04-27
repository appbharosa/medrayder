import 'package:executive/config/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/session_manager/session_manager.dart';


class AppDrawer extends StatefulWidget {
  final BuildContext rootContext;
  const AppDrawer({super.key, required this.rootContext});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String name = "";
  String type = "";
  String uniqueCode = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userName = await SessionManager.getName();
    final userType = await SessionManager.getType();
    final uniQueCode = await SessionManager.getUniqueId();
    final userEmail = await SessionManager.getEmail();

    if (!mounted) return;
    setState(() {
      name = userName ?? "";
      type = userType ?? "";
      uniqueCode = uniQueCode ?? "";
      email = userEmail ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [


      UserAccountsDrawerHeader(
      margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
        ),


        currentAccountPictureSize: const Size(60, 60),

        accountName: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            name.isNotEmpty ? name : "User Name",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),

        ///  REFERRAL + SHARE
        accountEmail: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Referral Code : $uniqueCode",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  /// 🔹 SHARE ICON
                  GestureDetector(
                    onTap: () {
                      final referralLink =
                     "https://medrayder.in/bharosa/registration/medrayder_partners?referral_id=$uniqueCode";

                      SharePlus.instance.share(
                        ShareParams(
                          text: "Join using my referral link:\n$referralLink",
                          subject: "Referral Link",
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 14),
                      child: Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5,),
              Text(
                 type,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14 ,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

        ),

        ///  PROFILE CIRCLE
        currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : "U",
            style: TextStyle(
              fontSize: 22,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

          /// ================= MENU =================
          _drawerItem(
            icon: Icons.person,
            title: "Profile",
            onTap: () {
              Navigator.of(widget.rootContext)
                  .pushNamed(RoutesName.profileScreen);
            },
          ),

          _drawerItem(
            icon: Icons.account_balance,
            title: "Bank Details",
            onTap: () {
              Navigator.of(widget.rootContext)
                  .pushNamed(RoutesName.bankDetails);
            },
          ),

          _drawerItem(
            icon: Icons.contact_phone_outlined,
            title: "Contact Us",
            onTap: () {
              Navigator.of(widget.rootContext)
                  .pushNamed(RoutesName.contactUsScreen);
            },
          ),

          _drawerItem(
            icon: Icons.info_outline,
            title: "About",
            onTap: () {
              Navigator.of(widget.rootContext)
                  .pushNamed(RoutesName.aboutScreen);
            },
          ),

          ///  LOGOUT (MOVED HERE)
          _drawerItem(
            icon: Icons.logout,
            title: "Logout",
            color: Colors.red,
            onTap: () async {
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 250));

              showDialog(
                context: widget.rootContext,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.all(24),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Are you sure you want to logout?",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
                                await SessionManager.clearSession();

                                if (widget.rootContext.mounted) {
                                  Navigator.of(widget.rootContext)
                                      .pushNamedAndRemoveUntil(
                                    RoutesName.loginScreen,
                                        (route) => false,
                                  );
                                }
                              },
                              child: const Text("Logout"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Spacer(),

          const Divider(),

          /// ================= BOTTOM LINKS =================
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Terms & Conditions
                GestureDetector(
                  onTap: () {
                    Navigator.of(widget.rootContext).pushNamed(RoutesName.termsScreen);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6,horizontal: 4),
                    child: Text(
                      "Terms & Conditions",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Privacy Policy (centered)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(widget.rootContext).pushNamed(RoutesName.privacyScreen);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        "Privacy Policy",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// ================= COMMON DRAWER ITEM =================
  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}