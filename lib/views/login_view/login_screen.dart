import 'package:executive/config/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/login_bloc/login_bloc.dart';
import '../../bloc/login_bloc/login_event.dart';
import '../../bloc/login_bloc/login_state.dart';
import '../../config/routes/routes_name.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child:BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showMsg(state.message);
            });
          }

          if (state is LoginSuccess) {
            Navigator.pushNamed(
              context,
              RoutesName.otpScreen,
              arguments: {
                "userId": state.response.result.userId,
              },
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: true,

            /// ================= BUTTON =================
            bottomNavigationBar: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom > 0
                    ? MediaQuery.of(context).viewInsets.bottom
                    : 16,
                top: 10,
              ),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: state is LoginLoading
                      ? null
                      : () {
                    FocusScope.of(context).unfocus(); //  dismiss keyboard
                    if (_formKey.currentState!.validate()) {
                      context.read<LoginBloc>().add(
                        LoginButtonPressed(
                          phoneController.text.trim(),
                        ),
                      );
                    }
                  },
                  child: state is LoginLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),

            /// ================= BODY =================
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(), //  dismiss on tap
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag, //  iOS fix
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80),

                        /// IMAGE
                        Center(
                          child: SvgPicture.asset(
                            "assets/med.svg",
                            height: 180,
                            width: 150,
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// TITLE
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// PHONE FIELD
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: InputDecoration(
                            hintText: "Enter Phone Number",
                            counterText: "",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter phone number";
                            }
                            if (value.length != 10) {
                              return "Enter valid 10 digit number";
                            }
                            return null;
                          },
                        ),
                      ],
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

  /// ================= SNACKBAR =================
  void _showMsg(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.red, //  background
          behavior: SnackBarBehavior.floating,
          content: Text(
            msg,
            style: const TextStyle(
              color: Colors.white, //  text color
            ),
          ),
        ),
      );
  }
}