import 'dart:io';
import 'package:executive/config/colors/app_colors.dart';
import 'package:executive/model/profile_model/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../bloc/profile_bloc/profile_event.dart';
import '../../bloc/profile_bloc/profile_state.dart';


class ProfileScreen extends StatefulWidget {
  final bool showBackButton;
  const ProfileScreen({super.key,this.showBackButton = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  final occupation = TextEditingController();
  final uniqueId = TextEditingController();
  final panController = TextEditingController();

  String? selectedGender;
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  final List<String> genderList = ["male", "female"];

  ProfileModel? profile; // Holds loaded profile data

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(GetProfileEvent());
  }

  /// ================= IMAGE PICK =================
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Image"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final sizeInMB = await file.length() / (1024 * 1024);
      if (sizeInMB > 2) {
        _showMsg("Image should be less than 2MB", isError: true);
        return;
      }
      setState(() {
        selectedImage = file;
      });
    }
  }

  /// ================= BODY =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: widget.showBackButton
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
            : null,
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return IconButton(
                  icon: Icon(state.isEditable ? Icons.check : Icons.edit, color: Colors.white),
                  onPressed: () => context.read<ProfileBloc>().add(ToggleEditEvent()),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),

      /// ================= UPDATE BUTTON =================
      bottomNavigationBar: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          bool showButton = state is ProfileLoaded && state.isEditable;
          return showButton
              ? SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    context.read<ProfileBloc>().add(
                      UpdateProfileEvent(
                        name: nameController.text.trim(),
                        gender: selectedGender ?? "",
                        occupation: occupation.text.trim(),
                        dob: dobController.text.trim(),
                        image: selectedImage,
                        panCard: panController.text.trim(),
                      ),
                    );
                  },
                  child: const Text(
                    "Update Profile",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          )
              : const SizedBox();
        },
      ),

      /// ================= BODY =================
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && state.message != null) {
            _showMsg(state.message!, isSuccess: true);
          }
          if (state is ProfileError) {
            _showMsg(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileUpdating) {
            return Stack(
              children: [
                _buildForm(isEditable: true, profile: profile),
                const Center(child: CircularProgressIndicator()),
              ],
            );
          }

          if (state is ProfileLoaded) {
            profile = state.profile;


            // SET DATA ONLY ONCE
            if (nameController.text.isEmpty) {
              nameController.text = profile!.name;
              mobileController.text = profile!.mobile;
              emailController.text = profile!.email;
              occupation.text = profile!.occupation ?? "";
              dobController.text = profile!.dob ?? "";
              panController.text = profile!.panCard ;
              uniqueId.text = profile!.uniqueId ;
              selectedGender = profile!.gender;

              print("datatat:${  panController.text = profile!.panCard }");
            }

            return _buildForm(isEditable: state.isEditable, profile: profile);
          }

          if (state is ProfileError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  /// ================= BUILD FORM =================
  Widget _buildForm({bool isEditable = false, ProfileModel? profile}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // IMAGE
        Center(
          child: GestureDetector(
            onTap: isEditable ? _showImagePickerDialog : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!) as ImageProvider
                      : (profile != null && profile.image != null
                      ? NetworkImage(profile.image!)
                      : const AssetImage("assets/icon.png")),
                ),
                if (isEditable)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        _label("Name"),
        _textField(controller: nameController, hint: "Enter name", enabled: isEditable),
        const SizedBox(height: 15),
        _label("Mobile"),
        _textField(controller: mobileController, hint: "Enter mobile", enabled: false),
        const SizedBox(height: 15),
        _label("Email"),
        _textField(controller: emailController, hint: "Enter email", enabled: false),
        const SizedBox(height: 15),
        _label("Gender"),
        DropdownButtonFormField<String>(
          initialValue: selectedGender,
          items: genderList
              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.black))))
              .toList(),
          onChanged: isEditable
              ? (value) {
            setState(() {
              selectedGender = value;
            });
          }
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: isEditable ? Colors.grey.shade100 : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 15),
        _label("Date Of Birth"),
        GestureDetector(
          onTap: isEditable ? _selectDate : null,
          child: AbsorbPointer(
            child: _textField(controller: dobController, hint: "Select Date Of Birth", enabled: isEditable),
          ),
        ),
        const SizedBox(height: 15),
        _label("Occupation"),
        _textField(controller: occupation, hint: "Enter Occupation", enabled: isEditable),
        const SizedBox(height: 15),
        _label("Pan Number"),
        _textField(controller: panController, hint: "Enter PanNumber", enabled: isEditable),
        const SizedBox(height: 15),
        _label("Referral ID"),
        _textField(controller: uniqueId, hint: "", enabled: false),
      ]),
    );
  }

  /// ================= COMMON WIDGETS =================
  void _showMsg(
      String msg, {
        bool isError = false,
        bool isSuccess = false,
      }) {
    // Determine background color
    Color bgColor = Colors.grey.shade800;
    if (isError) bgColor = Colors.red;
    if (isSuccess) bgColor = Colors.green;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(
            msg,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
  );

  Widget _textField({required TextEditingController controller, required String hint, bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = "${picked.day}-${picked.month}-${picked.year}";
      setState(() {});
    }
  }
}
