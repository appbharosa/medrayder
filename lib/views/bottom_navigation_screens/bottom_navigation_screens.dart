import 'package:dio/dio.dart';
import 'package:executive/bloc/subscription_bloc/subscription_bloc.dart';
import 'package:executive/repository/subscriptions_repository/subscriptions_repository.dart';
import 'package:flutter/material.dart';
import '../../bloc/agent_bloc/agent_bloc.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../bloc/user_bloc/user_bloc.dart';
import '../../config/session_manager/session_manager.dart';
import '../../network/dio_network/dio_client.dart';
import '../../network/dio_network/network_info.dart';
import '../../repository/agent_repo/agent_repository.dart';
import '../../repository/agent_repo/post_agent_repository.dart';
import '../../repository/profile_repo/profile_repository.dart';
import '../../repository/profile_repo/update_profile_repository.dart';
import '../../repository/user_repo/user_post_repository.dart';
import '../../repository/user_repo/user_repository.dart';
import '../../repository/user_repo/user_sendotp_repository.dart';
import '../../repository/user_repo/verify_userotp_repository.dart';
import '../agent_screen/agent_screen.dart';
import '../home_screen/app_drawer.dart';
import '../home_screen/home_screen.dart';
import '../profile_screen/profile_screen.dart';
import '../subscription_screen/subscription_screen.dart';
import '../user_screen/user_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class BottomNavigationScreens extends StatefulWidget {
  const BottomNavigationScreens({super.key});

  @override
  State<BottomNavigationScreens> createState() =>
      _BottomNavigationScreensState();
}

class _BottomNavigationScreensState
    extends State<BottomNavigationScreens> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int currentIndex = 0;
  String userType = "";

  late final DioClient dioClient;

  @override
  void initState() {
    super.initState();
    _loadUserType();

    dioClient = DioClient(
      dio: Dio(),
      networkInfo: NetworkInfo(),
      tokenProvider: () async => await SessionManager.getToken(),
    );
  }

  Future<void> _loadUserType() async {
    final type = await SessionManager.getType();

    setState(() {
      userType = type ?? "";
    });
  }

  ///  NAV ITEMS (Dynamic)
  List<Map<String, dynamic>> getNavItems() {
    List<Map<String, dynamic>> items = [
      {"icon": Icons.home, "label": "Home"},
      {"icon": Icons.point_of_sale_sharp, "label": "Sales"},
      {"icon": Icons.people, "label": "Users"},
    ];

    ///  Show Agents only if NOT Agent
    if (userType != "Agent") {
      items.add({"icon": Icons.groups, "label": "Agents"});
    }

    items.add({"icon": Icons.person, "label": "Profile"});

    return items;
  }

  ///  PAGES (Dynamic with Bloc)
  List<Widget> getPages() {
    List<Widget> pages = [

      ///  PASS CORRECT KEY
      HomeScreen(scaffoldKey: scaffoldKey),


      MultiBlocProvider(
        providers: [
          BlocProvider<SubscriptionBloc>(
            create: (_) => SubscriptionBloc(
            subscriptionsRepository  : SubscriptionsRepository(dioClient),
            ),
          ),
        ],
        child:  SubscriptionScreen(scaffoldKey: scaffoldKey)),


      /// USERS
      MultiBlocProvider(
        providers: [
          BlocProvider<UserBloc>(
            create: (_) => UserBloc(
              userRepository: UserRepository(dioClient),
              userPostRepository: UserPostRepository(dioClient),

              sendOtpRepository: UserSendOtpRepository(dioClient),
              verifyOtpRepository: UserOtpVerifyRepository(dioClient),
            ),
          ),
        ],
        child:  UserScreen(scaffoldKey: scaffoldKey,),
      ),
    ];

    ///  Agents only for Partner
    if (userType != "Agent") {
      pages.add(
        BlocProvider<AgentBloc>(
          create: (_) => AgentBloc(
            agentRepository: AgentRepository(dioClient),
            postAgentRepository: PostAgentRepository(dioClient),
          ),
          child:  AgentScreen(scaffoldKey: scaffoldKey),
        ),
      );
    }

    /// PROFILE
    pages.add(
      BlocProvider<ProfileBloc>(
        create: (_) => ProfileBloc(
          ProfileRepository(dioClient),
          UpdateProfileRepository(dioClient),
        ),
        child: const ProfileScreen(),
      ),
    );

    return pages;
  }

  @override
  Widget build(BuildContext context) {

    final navItems = getNavItems();
    final pages = getPages();

    ///  SAFETY (important)
    if (currentIndex >= pages.length) {
      currentIndex = 0;
    }

    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        // drawer: AppDrawer(rootContext: context),
        // /// 🔷 BODY
        // body: pages[currentIndex],
      
        key: scaffoldKey,   //  IMPORTANT
        drawer: AppDrawer(rootContext: context),
        body: pages[currentIndex],
      
        /// 🔷 BOTTOM NAV
        bottomNavigationBar: Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10)
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
      
              return _navItem(
                item["icon"],
                item["label"],
                index,
              );
            }),
          ),
        ),
      
      ),
    );
  }

  ///  NAV ITEM
  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: isSelected ? 13 : 11,
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
