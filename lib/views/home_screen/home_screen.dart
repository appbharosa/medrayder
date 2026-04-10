import 'package:executive/bloc/home_bloc/home_event.dart';
import 'package:executive/config/colors/app_colors.dart';
import 'package:executive/config/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/home_bloc/home_bloc.dart';
import '../../bloc/home_bloc/home_state.dart';
import '../../bloc/notification_bloc/notification_bloc.dart';
import '../../bloc/notification_bloc/notification_state.dart';
import '../../config/session_manager/session_manager.dart';
import 'app_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomeScreen({
    super.key,
    required this.scaffoldKey,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  String name = "";
  String type ="";


  @override void initState() {
    super.initState();
    _loadUserData();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.read<HomeBloc>().add(FetchHomeData());
  }

  Future<void> openWhatsApp(String phone) async {
    final url = Uri.parse("whatsapp://send?phone=$phone");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // 👉 Redirect to Play Store
      final playStore = Uri.parse(
          "https://wa.me/919010492345");
      await launchUrl(playStore);
    }
  }

  Future<void> makeCall(String phone) async {
    final url = Uri.parse("tel:$phone");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // 👉 Optional fallback
      throw "Call not supported";
    }
  }

  Future<void> _loadUserData() async {
    final userName = await SessionManager.getName();
    final userType = await SessionManager.getType();

    setState(() {
      name = userName ?? "";
      type = userType ?? "";

    }); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: AppColors.whiteColor,
     drawer: AppDrawer(rootContext: context),


      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,

        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                widget.scaffoldKey.currentState?.openDrawer();
              },
            );
          },
        ),

        title: SvgPicture.asset(
          "assets/logo.svg",
          height: 28,
        ),

        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              int unread = 0;

              if (state is NotificationLoaded) {
                unread = state.unreadCount;
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, RoutesName.notificationScreen);
                    },
                  ),


                  if (unread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unread > 9 ? "9+" : unread.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          /// 🔥 PROFILE IMAGE FROM API
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                String image = "";

                if (state is HomeLoaded) {
                  image = state.data.image;
                }

                return CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  backgroundImage: (image.isNotEmpty && image.startsWith("http"))
                      ? NetworkImage(image)
                      : const AssetImage("assets/userLogo.png") as ImageProvider,
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: SpeedDial(
        icon: Icons.support_agent,
        activeIcon: Icons.close,
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        spacing: 10,
        spaceBetweenChildren: 10,

        children: [

          //  WhatsApp
          SpeedDialChild(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                "assets/whatsapp.webp",
                fit: BoxFit.contain,
              ),
            ),
            backgroundColor: Colors.white, // better for image visibility
            label: "WhatsApp",
            onTap: () {
              openWhatsApp(""); // your number
            },
          ),

          //  Call
          SpeedDialChild(
            child: const Icon(Icons.call, color: Colors.white),
            backgroundColor: Colors.blue,
            label: "Call",
            onTap: () {
              makeCall("9010492345");
            },
          ),
        ],
      ),

      /// ================= BODY =================
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {

          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(child: Text(state.message));
          }

          if (state is HomeLoaded) {

            final data = state.data;



            return SingleChildScrollView(
              child: Column(
                children: [

                  const SizedBox(height: 20),

                  /// 🔷 HEADER
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade900,
                            Colors.blue.shade500,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Welcome, ${data.name}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.8,
                            children: [

                              _buildStatCard(
                                "Total Subscriptions",
                                data.totalSubscriptions.toString(),
                                Colors.blue,
                                  onTap: () {
                                    Navigator.pushNamed(context, RoutesName.subscriptionScreen);
                                  }
                              ),

                              _buildStatCard(
                                "Monthly Earnings",
                                data.monthlyEarnings.toString(),
                                Colors.blue.shade700,
                              ),

                              _buildStatCard(
                                "Users",
                                data.users.toString(),
                                Colors.orange,
                                  onTap: () {
                                    Navigator.pushNamed(context, RoutesName.userScreen);

                                  }
                              ),

                              if (type != "Agent")
                                _buildStatCard(
                                  "Agents",
                                  data.agents.toString(),
                                  Colors.blue.shade600,
                                    onTap: () {
                                      Navigator.pushNamed(context, RoutesName.agentScreen);

                                    }
                                ),

                              _buildStatCard(
                                "Tutorials",
                                data.tutorials.toString(),
                                Colors.green,
                                  onTap: () {
                                    Navigator.pushNamed(context, RoutesName.tutorialScreen);

                                  }
                              ),

                              _buildStatCard(
                                "Wallet Balance",
                                data.walletBalance.toString(),
                                Colors.deepOrange,
                                  onTap: () {
                                    Navigator.pushNamed(context, RoutesName.walletScreen);

                                  }
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle("Recent Payments"),

                  /// 🔥 DYNAMIC PAYMENTS
                  ...data.recentPayments.map((e) {
                    final date = DateTime.parse(e.date);

                    return _paymentTile(
                      date.day.toString(),
                      _getMonth(date.month),
                      e.name,
                      "₹${e.amount}",
                      "Completed",
                    );
                  }).toList(),

                  const SizedBox(height: 20),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),

    );
  }

  String _getMonth(int m) {
    const months = [
      "JAN","FEB","MAR","APR","MAY","JUN",
      "JUL","AUG","SEP","OCT","NOV","DEC"
    ];
    return months[m - 1];
  }

  /// ================= STAT CARD =================
  Widget _buildStatCard(
      String title,
      String value,
      Color color, {
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 14)
        ],
      ),
    );
  }



  /// ================= PAYMENT TILE =================
  Widget _paymentTile(
      String day,
      String month,
      String name,
      String amount,
      String status,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Colors.grey,
              blurRadius: 3,
              offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [

          /// 🔷 LEFT DATE BOX (like camp card)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  month,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          /// 🔷 NAME + TIME
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "11:23 AM",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          /// 🔷 RIGHT SIDE (Amount + Status)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: status == "Completed"
                      ? Colors.green
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}