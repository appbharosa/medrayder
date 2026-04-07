import 'package:executive/config/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/agent_bloc/agent_bloc.dart';
import '../../bloc/agent_bloc/agent_event.dart';
import '../../bloc/agent_bloc/agent_state.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../config/routes/routes_name.dart';
import '../../config/session_manager/session_manager.dart';
import '../../model/agent_model/agent_model.dart';


class AgentScreen extends StatefulWidget {
  final bool showBackButton;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const AgentScreen({super.key,this.showBackButton = false,required this.scaffoldKey});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late AgentBloc agentBloc;
  String? profileImage;
  List<Agent> allAgents = []; // Store all agents for local search
  List<Agent> displayedAgents = []; // Display filtered agents

  @override
  void initState() {
    super.initState();
    _loadImage();
    agentBloc = context.read<AgentBloc>();
    agentBloc.add(FetchAgents());

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        final state = agentBloc.state;
        if (state is AgentLoaded && state.currentPage <= state.lastPage) {
          agentBloc.add(FetchAgents());
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

  void _openAddAgentBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddAgentBottomSheet(agentBloc: agentBloc),
    );
  }

  void _filterAgents(String query) {
    if (query.isEmpty) {
      setState(() {
        displayedAgents = List.from(allAgents);
      });
    } else {
      final filtered = allAgents.where((agent) {
        final lowerQuery = query.toLowerCase();
        return agent.name.toLowerCase().contains(lowerQuery) ||
            agent.email.toLowerCase().contains(lowerQuery) ||
            agent.mobile.toLowerCase().contains(lowerQuery);
      }).toList();

      setState(() {
        displayedAgents = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),

        /// 🔥 LEFT SIDE
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

        /// 🔥 TITLE
        title: const Text(
          "Agents",
          style: TextStyle(
            fontSize: 19,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),

        /// 🔥 RIGHT SIDE (ONLY FOR DRAWER MODE)
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Agents...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _filterAgents,
            ),
          ),

          // Agents List
          Expanded(
            child: BlocConsumer<AgentBloc, AgentState>(
              listener: (context, state) {
                if (state is AgentLoaded) {
                  // Update local agent lists
                  allAgents = state.agents;
                  displayedAgents = List.from(allAgents);
                }
              },
              builder: (context, state) {
                if (state is AgentLoading && state is! AgentLoaded) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AgentError) {
                  return const Center(child: Text("No data"));
                } else if (state is AgentLoaded) {
                  if (displayedAgents.isEmpty) {
                    return const Center(child: Text("No agents found"));
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: displayedAgents.length,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemBuilder: (_, index) {
                      final agent = displayedAgents[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
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
                              radius: 42,
                              backgroundImage: NetworkImage(agent.image),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(agent.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4,),
                                  SizedBox(height: 4,),
                                  Text(agent.mobile),
                                  SizedBox(height: 4,),
                                  Text('Subscriptions :${agent.subscriptionData?.totalSubscription ?? 0}'),
                                  SizedBox(height: 4,),
                                  Text('single Subscriptions :${agent.subscriptionData?.totalFamilySubscription ?? 0}'),
                                  SizedBox(height: 4,),
                                  Text('Family Subscriptions :${agent.subscriptionData?.totalFamilySubscription ?? 0}'),
                                                                 ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAgentBottomSheet,
        label: const Text(
          "Add Agent",
          style: TextStyle(color: AppColors.whiteColor),
        ),
        backgroundColor: AppColors.blue,
      ),
    );
  }
}

// ---------------- Add Agent Bottom Sheet ---------------- //
class AddAgentBottomSheet extends StatefulWidget {
  final AgentBloc agentBloc;
  const AddAgentBottomSheet({super.key, required this.agentBloc});

  @override
  State<AddAgentBottomSheet> createState() => _AddAgentBottomSheetState();
}

class _AddAgentBottomSheetState extends State<AddAgentBottomSheet> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController occupation = TextEditingController();
  String? gender;
  XFile? pickedImage;
  final ImagePicker _picker = ImagePicker();

  String? buttonMessage;
  Color buttonMessageColor = Colors.red;

  Future<void> _pickImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Select Image Source"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, ImageSource.camera), child: const Text("Camera")),
          TextButton(onPressed: () => Navigator.pop(ctx, ImageSource.gallery), child: const Text("Gallery")),
        ],
      ),
    );

    if (source == null) return;

    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      final file = File(picked.path);
      final sizeInMB = await file.length() / (1024 * 1024);
      if (sizeInMB > 2) {
        _showButtonMessage("Image should be less than 2MB", isError: true);
        return;
      }
      setState(() => pickedImage = picked);
    }
  }

  void _showButtonMessage(
      String msg, {
        bool isError = true,
        bool isSuccess = false,
      }) {
    setState(() {
      buttonMessage = msg;
      buttonMessageColor = isError
          ? Colors.red
          : (isSuccess ? Colors.green : Colors.grey.shade800);
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => buttonMessage = null);
      }
    });
  }

  Widget _input(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add Agent",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Profile image
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: pickedImage != null
                        ? FileImage(File(pickedImage!.path))
                        : null,
                    child: pickedImage == null
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Form fields
              _input("Name", name),
              _input("Email", email, keyboardType: TextInputType.emailAddress),
              _input("Mobile", mobile, keyboardType: TextInputType.phone),

              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<String>(
                  initialValue: gender,
                  decoration: InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: ["male", "female", "other"]
                      .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => gender = val),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: dob,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Date of Birth",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (picked != null) {
                      dob.text =
                      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
              ),

              _input("Occupation", occupation),

              const SizedBox(height: 10),

              //  MESSAGE CONTAINER (UPDATED)
              if (buttonMessage != null)
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: buttonMessageColor,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: Text(
                    buttonMessage!,
                    style: const TextStyle(
                      color: Colors.white, //  white text
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Save button
              BlocConsumer<AgentBloc, AgentState>(
                bloc: widget.agentBloc,
                listener: (context, state) {
                  if (state is AgentAdded) {
                    _showButtonMessage(
                      "Agent Added Successfully",
                      isError: false,
                      isSuccess: true,
                    );

                    Future.delayed(
                      const Duration(milliseconds: 500),
                          () => Navigator.pop(context),
                    );
                  } else if (state is AgentAddError) {
                    _showButtonMessage(state.message, isError: true);
                  }
                },
                builder: (context, state) {
                  final loading = state is AgentAdding;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: loading
                          ? null
                          : () async {
                        if (name.text.isEmpty ||
                            email.text.isEmpty ||
                            mobile.text.isEmpty ||
                            gender == null ||
                            dob.text.isEmpty ||
                            occupation.text.isEmpty) {
                          _showButtonMessage(
                              "Please fill all required fields");
                          return;
                        }

                        final userId =
                        await SessionManager.getUserId();

                        widget.agentBloc.add(
                          AddAgent(
                            name: name.text,
                            email: email.text,
                            mobile: mobile.text,
                            gender: gender!,
                            dob: dob.text,
                            occupation: occupation.text,
                            image: pickedImage != null
                                ? File(pickedImage!.path)
                                : null,
                            userId: userId!,
                          ),
                        );
                      },
                      child: loading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text("Save"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}