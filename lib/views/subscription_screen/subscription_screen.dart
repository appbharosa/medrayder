import 'package:executive/config/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/subscription_bloc/subscription_bloc.dart';
import '../../bloc/subscription_bloc/subscription_event.dart';
import '../../bloc/subscription_bloc/subscription_state.dart';
import '../../config/routes/routes_name.dart';
import '../../config/session_manager/session_manager.dart';
import '../../model/subscription_model/subscription_model.dart';

class SubscriptionScreen extends StatefulWidget {
  final bool showBackButton;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const SubscriptionScreen({super.key,this.showBackButton = false,required this.scaffoldKey});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int selectedTab = 0;
  final ScrollController scrollController = ScrollController();

  final List<String> tabs = ["All", "Single", "Family"];

  List<Subscription> allList = [];

  late SubscriptionBloc bloc;

  String? profileImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
    bloc = context.read<SubscriptionBloc>();

    if (bloc.subscriptions.isEmpty) {
      bloc.add(FetchSubscriptions());
    }
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {

        final state = bloc.state;

        if (state is SubscriptionLoaded &&
            state.currentPage <= state.lastPage) {
          bloc.add(FetchSubscriptions());
        }
      }
    });
  }

  Future<void> _loadImage() async {
    final img = await SessionManager.getProfileImage();

    setState(() {
      profileImage = img;
    });
  }

  List<Subscription> getFilteredList() {
    if (selectedTab == 0) return allList;

    if (selectedTab == 1) {
      return allList
          .where((e) => e.plan.toLowerCase().contains("single"))
          .toList();
    }

    return allList
        .where((e) => e.plan.toLowerCase().contains("family"))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),

        ///  LEFT SIDE
        leading: widget.showBackButton
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
            : Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                widget.scaffoldKey?.currentState?.openDrawer();
              },
            );
          },
        ),

        ///  TITLE
        title: const Text(
          "Subscriptions",
          style: TextStyle(
            fontSize: 19,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),

        ///  RIGHT SIDE (ONLY FOR DRAWER MODE)
        actions: widget.showBackButton
            ? null
            : [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RoutesName.notificationScreen,
                );
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(
                  Icons.notifications,
                  color: AppColors.blue,
                  size: 20,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: (profileImage != null &&
                  profileImage!.isNotEmpty)
                  ? NetworkImage(profileImage!)
                  : const AssetImage("assets/userLogo.png")
              as ImageProvider,
            ),
          ),
        ],
      ),

      body: Column(
        children: [

          /// 🔷 TABS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: List.generate(tabs.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => selectedTab = index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedTab == index
                            ? Colors.blue
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Center(
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: selectedTab == index
                                ? Colors.white
                                : Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          /// 🔷 LIST
          Expanded(
            child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
              listener: (context, state) {
                if (state is SubscriptionLoaded) {
                  allList = List.from(state.list);
                }
              },
              builder: (context, state) {

                if (state is SubscriptionLoading && allList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SubscriptionError) {
                  return Center(child: Text(state.message));
                }

                final list = getFilteredList();

                if (list.isEmpty) {
                  return const Center(child: Text("No Data"));
                }

                return ListView.builder(
                  controller: scrollController,
                  itemCount: list.length +
                      (state is SubscriptionLoading ? 1 : 0),
                  itemBuilder: (context, index) {

                    if (index == list.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final item = list[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              blurRadius: 3,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [

                          CircleAvatar(
                            radius: 35,
                            backgroundImage: item.userImage.isNotEmpty
                                ? NetworkImage(item.userImage)
                                : null,
                            child: item.userImage.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 4,),
                                Text(item.plan,
                                    style: const TextStyle(
                                        fontSize: 13 )),
                                SizedBox(height: 4,),
                                Text("${item.date} • ${item.time}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        )),
                              ],
                            ),
                          ),

                          Text(
                            "₹${item.amount}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}