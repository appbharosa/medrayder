import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/contact_bloc/conatct_state.dart';
import '../../bloc/contact_bloc/contact_bloc.dart';
import '../../bloc/contact_bloc/contact_event.dart';
import '../../config/colors/app_colors.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final messageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, //  IMPORTANT
     backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Contact Us",
          style: TextStyle(
            fontSize: 19,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),

      /// ================= BODY =================
      body: BlocConsumer<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state is ContactSuccess) {
            _showMsg(state.message, isSuccess: true);
          }

          if (state is ContactError) {
            _showMsg(state.message, isError: true);
          }
        },

        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                MediaQuery.of(context).viewInsets.bottom + 20, //  KEY FIX
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    /// NAME
                    _field(
                      controller: nameController,
                      hint: "Enter Name",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter your name";
                        }
                        if (value.length < 3) {
                          return "Name must be at least 3 characters";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    /// EMAIL
                    _field(
                      controller: emailController,
                      hint: "Enter Email",
                      type: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter email";
                        }

                        final emailRegex = RegExp(
                          r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$',
                        );

                        if (!emailRegex.hasMatch(value)) {
                          return "Enter valid email";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    /// MOBILE
                    _field(
                      controller: mobileController,
                      hint: "Enter Mobile",
                      type: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter mobile number";
                        }

                        if (value.length != 10) {
                          return "Enter 10-digit mobile number";
                        }

                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return "Only numbers allowed";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    /// MESSAGE
                    _field(
                      controller: messageController,
                      hint: "Enter Message",
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter message";
                        }

                        if (value.length < 5) {
                          return "Message too short";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      /// ================= BOTTOM BUTTON =================
      bottomNavigationBar: BlocBuilder<ContactBloc, ContactState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 10,
                bottom:
                MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 16,
              ),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  onPressed: state is ContactLoading
                      ? null
                      : () {
                    FocusScope.of(context).unfocus(); //  hide keyboard

                    if (_formKey.currentState!.validate()) {
                      context.read<ContactBloc>().add(
                        SubmitContactEvent(
                          name: nameController.text.trim(),
                          email: emailController.text.trim(),
                          mobile: mobileController.text.trim(),
                          message: messageController.text.trim(),
                        ),
                      );
                    }
                  },

                  child: state is ContactLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white, fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ================= FIELD =================
  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? type,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// ================= SNACKBAR =================
  void _showMsg(String msg,
      {bool isError = false, bool isSuccess = false}) {
    Color bgColor = Colors.grey.shade800;

    if (isError) bgColor = Colors.red;
    if (isSuccess) bgColor = Colors.green;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          content: Text(
            msg,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
  }
}
