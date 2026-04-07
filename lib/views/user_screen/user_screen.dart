import 'package:executive/config/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/home_bloc/home_bloc.dart';
import '../../bloc/home_bloc/home_event.dart';
import '../../bloc/user_bloc/user_bloc.dart';
import '../../bloc/user_bloc/user_event.dart';
import '../../bloc/user_bloc/user_state.dart';
import '../../config/routes/routes_name.dart';
import '../../config/session_manager/session_manager.dart';
import '../../model/user_model/blood_group_model.dart';
import '../../model/user_model/user_model.dart';
import '../../repository/user_repo/blood_groop_repository.dart';
import '../../repository/user_repo/category_repository.dart';

class UserScreen extends StatefulWidget {
  final bool showBackButton;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const UserScreen({super.key, this.showBackButton = false,required this.scaffoldKey});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late UserBloc userBloc;

  List<User> allUsers = [];
  List<User> displayedUsers = [];
  String? profileImage;


  @override
  void initState() {
    super.initState();

    _loadImage();
    userBloc = context.read<UserBloc>();
    userBloc.add(FetchUsers());

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {

        final state = userBloc.state;

        if (state is UserLoaded &&
            state.currentPage <= state.lastPage) {

          userBloc.add(FetchUsers());
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

  void _openAddUserBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          AddUserBottomSheet(userBloc: userBloc, rootContext: context),
    );
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() => displayedUsers = List.from(allUsers));
    } else {
      final filtered = allUsers.where((user) {
        final q = query.toLowerCase();
        return user.name.toLowerCase().contains(q) ||
            user.email.toLowerCase().contains(q) ||
            user.mobile.toLowerCase().contains(q);
      }).toList();

      setState(() => displayedUsers = filtered);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

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
                widget.scaffoldKey.currentState?.openDrawer();
              },
            );
          },
        ),

        /// 🔥 TITLE
        title: const Text(
          "Users ",
          style: TextStyle(
            fontSize: 19,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,

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

        /// 🔥 SEARCH BAR
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: _filterUsers,
              decoration: InputDecoration(
                hintText: "Search Users...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),

      body: BlocConsumer<UserBloc, UserState>(
        listenWhen: (prev, curr) =>
        curr is UserLoaded || curr is UserActionState,
        buildWhen: (prev, curr) => curr is! UserActionState,

        listener: (context, state) {
          if (state is UserLoaded) {
            allUsers = List.from(state.users);

            /// 🔥 IMPORTANT FIX
            if (searchController.text.isEmpty) {
              displayedUsers = List.from(allUsers);
            } else {
              _filterUsers(searchController.text);
            }

            setState(() {});
          }

          if (state is UserAdded) {
            userBloc.add(FetchUsers(reset: true));
          }
        },

        builder: (context, state) {
          if (state is UserLoading && allUsers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserError) {
            return const Center(child: Text("No Data Found"));
          }

          if (displayedUsers.isEmpty) {
            return const Center(child: Text("No Users Found"));
          }

          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),

            itemCount: displayedUsers.length +
                (state is UserLoading ? 1 : 0),

            itemBuilder: (_, index) {

              /// 🔥 LOADER AT BOTTOM
              if (index == displayedUsers.length) {
                return const Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final user = displayedUsers[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                      backgroundImage: NetworkImage(user.image),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(user.email),
                          const SizedBox(height: 4),
                          Text(user.mobile),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),


      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddUserBottomSheet,
        label: const Text(
          "Add User",
          style: TextStyle(color: AppColors.whiteColor),
        ),
        backgroundColor: AppColors.blue,
      ),


    );
  }
}

// AddUserBottomSh
class AddUserBottomSheet extends StatefulWidget {
  final UserBloc userBloc;
  final BuildContext rootContext;

  const AddUserBottomSheet({
    super.key,
    required this.userBloc,
    required this.rootContext,
  });

  @override
  State<AddUserBottomSheet> createState() =>
      _AddUserBottomSheetState();
}

class _AddUserBottomSheetState extends State<AddUserBottomSheet> {
  final name = TextEditingController();
  final email = TextEditingController();
  final mobile = TextEditingController();
  final dob = TextEditingController();

  String? gender;
  int? selectedBloodGroupId;
  int? selectedCategoryId;
  XFile? pickedImage;

  final ImagePicker _picker = ImagePicker();

  List<BloodGroup> bloodGroups = [];
  List<Category> categories = [];

  String? buttonMessage;
  Color buttonMessageColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _fetchDropdowns();
  }

  Future<void> _fetchDropdowns() async {
    final dio = widget.userBloc.userRepository.dioClient;

    bloodGroups = await BloodGroupRepository(dio).getBloodGroups();
    categories = await CategoryRepository(dio).getCategories();

    setState(() {});
  }

  void _showButtonMessage(String msg,
      {bool isError = true, }) {
    setState(() {
      buttonMessage = msg;
      buttonMessageColor =
      isError ? Colors.red : Colors.green;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => buttonMessage = null);
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final file = File(picked.path);
      final size = await file.length() / (1024 * 1024);

      if (size > 2) {
        _showButtonMessage("Image should be less than 2MB");
        return;
      }

      setState(() => pickedImage = picked);
    }
  }

  Widget _input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Padding(
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: const Text("Add User",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: pickedImage != null
                      ? FileImage(File(pickedImage!.path))
                      : null,
                  child: pickedImage == null
                      ? const Icon(Icons.camera_alt)
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              _input("Name", name),
              _input("Email", email),
              _input("Mobile", mobile),

              DropdownButtonFormField<String>(
                initialValue: gender,
                decoration: InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
                items: ["male", "female", "other"]
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => gender = v),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                initialValue: selectedBloodGroupId,
                decoration: InputDecoration(
                    labelText: "Blood Group",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
                items: bloodGroups
                    .map((e) =>
                    DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => setState(() => selectedBloodGroupId = v),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                initialValue: selectedCategoryId,
                decoration: InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
                items: categories
                    .map((e) =>
                    DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => setState(() => selectedCategoryId = v),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: dob,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "DOB",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
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

              const SizedBox(height: 20),

              if (buttonMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: buttonMessageColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(buttonMessage!,
                      style: const TextStyle(color: Colors.white)),
                ),

              BlocConsumer<UserBloc, UserState>(
                bloc: widget.userBloc,
                listener: (context, state) async {
                  if (state is UserAdded) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(widget.rootContext)
                        .showSnackBar(const SnackBar(
                      content: Text("User Added Successfully"),
                      backgroundColor: Colors.green,
                    ));
                  }

                  if (state is UserAddError) {
                    _showButtonMessage(state.message);
                  }
                },
                builder: (context, state) {
                  final loading = state is UserAdding;


                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue, // ✅ blue background
                        foregroundColor: Colors.white, // ✅ text color white
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // ✅ radius 10
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14), // optional height
                      ),
                      onPressed: loading
                          ? null
                          : () async {
                        if (name.text.isEmpty ||
                            email.text.isEmpty ||
                            mobile.text.isEmpty ||
                            gender == null ||
                            dob.text.isEmpty ||
                            selectedBloodGroupId == null ||
                            selectedCategoryId == null) {
                          _showButtonMessage("Please fill all fields");
                          return;
                        }

                        final userId = await SessionManager.getUserId();

                        widget.userBloc.add(AddUser(
                          name: name.text,
                          email: email.text,
                          mobile: mobile.text,
                          gender: gender!,
                          dob: dob.text,
                          bloodGroupId: selectedBloodGroupId!,
                          coverageCategoryId: selectedCategoryId!,
                          userId: userId!,
                          image: pickedImage != null
                              ? File(pickedImage!.path)
                              : null,
                        ));
                      },
                      child: loading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}