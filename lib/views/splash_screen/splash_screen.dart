import 'package:executive/config/session_manager/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/update_bloc/update_bloc.dart';
import '../../bloc/update_bloc/update_event.dart';
import '../../bloc/update_bloc/update_state.dart';
import '../../config/routes/routes_name.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/update_response/update_response.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);

    /// Check for updates
    context.read<UpdateBloc>().add(CheckUpdateEvent());
  }

  void _checkLogin() async {
    if (!mounted) return;

    final token = await SessionManager.getToken();

    if (token != null && token.isNotEmpty) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.homeScreen,
            (route) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.loginScreen,
            (route) => false,
      );
    }
  }

  /// Show OPTIONAL update dialog (user can dismiss)
  void _showOptionalUpdateDialog(UpdateResult result) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.system_update, color: Colors.orange),
              const SizedBox(width: 10),
              const Text("Update Available"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.message),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current version: ${result.currentVersion}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "New version: ${result.yourVersion}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isDialogShowing = false;
                // User dismissed, proceed to login
                context.read<UpdateBloc>().add(UserDismissedUpdateEvent());
              },
              child: const Text("Later"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isDialogShowing = false;
                // User wants to update
                const packageName = "com.medrayder.executive";
                final updateUrl = "https://play.google.com/store/apps/details?id=$packageName";
                context.read<UpdateBloc>().add(UserClickedUpdateEvent(updateUrl));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text("Update Now"),
            ),
          ],
        );
      },
    );
  }

  /// Show FORCE update dialog (cannot dismiss)
  void _showForceUpdateDialog(UpdateResult result) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent back button
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 10),
                const Text("Update Required"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(result.message),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your version: ${result.yourVersion}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Required version: ${result.currentVersion}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // User must update
                  const packageName = "com.medrayder.executive";
                  final updateUrl = "https://play.google.com/store/apps/details?id=$packageName";
                  context.read<UpdateBloc>().add(UserClickedUpdateEvent(updateUrl));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("Update Now"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateBloc, UpdateState>(
      listener: (context, state) {
        /// FORCE UPDATE (must update)
        if (state is ForceUpdateRequired) {
          _showForceUpdateDialog(state.result);
        }

        /// NEW VERSION AVAILABLE (optional)
        else if (state is NewVersionAvailable) {
          _showOptionalUpdateDialog(state.result);
        }

        /// NAVIGATE TO PLAY STORE
        else if (state is NavigateToPlayStore) {
          _launchPlayStore(state.updateUrl);
        }

        /// NO UPDATE NEEDED
        else if (state is UpdateNotRequired) {
          _checkLogin();
        }

        /// ERROR - still allow login
        else if (state is UpdateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          _checkLogin();
        }
      },
      child: Scaffold(
        body: Center(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                child: SvgPicture.asset(
                  "assets/med.svg",
                  height: 120,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _launchPlayStore(String url) async {
    final Uri playStoreUri = Uri.parse(url);
    if (await canLaunchUrl(playStoreUri)) {
      await launchUrl(
        playStoreUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
