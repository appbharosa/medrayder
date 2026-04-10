import 'package:executive/config/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/otp_bloc/otp_bloc.dart';
import '../../bloc/otp_bloc/otp_event.dart';
import '../../bloc/otp_bloc/otp_state.dart';
import '../../config/routes/routes_name.dart';
import 'package:flutter_svg/flutter_svg.dart';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OtpVerifyScreen extends StatefulWidget {
  final int userId;

  const OtpVerifyScreen({
    super.key,
    required this.userId,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {

  final List<TextEditingController> controllers =
  List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
  List.generate(6, (_) => FocusNode());

  String getOtp() {
    return controllers.map((e) => e.text).join();
  }

  @override
  void initState() {
    super.initState();

    /// Auto focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.blue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "OTP Verification",
            style: TextStyle(
              fontSize: 19,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
        ),

        body: BlocConsumer<OtpBloc, OtpState>(
          listener: (context, state) {
            if (state is OtpSuccess) {
              _showMsg("OTP Verified Successfully", bgColor: Colors.green);

              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesName.homeScreen,
                    (route) => false,
              );
            }

            if (state is OtpError) {
              _showMsg(state.message, bgColor: Colors.red);
            }
          },

          builder: (context, state) {
            return Column(
              children: [

                /// ===== CONTENT =====
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [

                        SizedBox(
                          height: 160,
                          child: SvgPicture.asset("assets/med.svg"),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          "Enter OTP",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Enter the 6-digit OTP sent to your number",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 30),

                        /// ✅ FIXED OTP FIELDS
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: List.generate(6, (index) {
                        //     return SizedBox(
                        //       width: 45,
                        //       child: RawKeyboardListener(
                        //         focusNode: FocusNode(),
                        //         onKey: (event) {
                        //           if (event is RawKeyDownEvent &&
                        //               event.logicalKey ==
                        //                   LogicalKeyboardKey.backspace) {
                        //             if (controllers[index].text.isEmpty &&
                        //                 index > 0) {
                        //               focusNodes[index - 1].requestFocus();
                        //             }
                        //           }
                        //         },
                        //         child: TextField(
                        //           controller: controllers[index],
                        //           focusNode: focusNodes[index],
                        //           keyboardType: TextInputType.number,
                        //           textInputAction: index == 5
                        //               ? TextInputAction.done
                        //               : TextInputAction.next,
                        //           inputFormatters: [
                        //             FilteringTextInputFormatter.digitsOnly
                        //           ],
                        //           maxLength: 1,
                        //           textAlign: TextAlign.center,
                        //           style: const TextStyle(
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //           decoration: InputDecoration(
                        //             counterText: "",
                        //             filled: true,
                        //             fillColor: Colors.white,
                        //             border: OutlineInputBorder(
                        //               borderRadius: BorderRadius.circular(10),
                        //             ),
                        //           ),
                        //
                        //           /// ✅ FIXED FOR iPad
                        //           onChanged: (value) {
                        //             if (value.isNotEmpty) {
                        //               if (index < 5) {
                        //                 focusNodes[index + 1].requestFocus();
                        //               } else {
                        //                 focusNodes[index].unfocus();
                        //               }
                        //             }
                        //           },
                        //
                        //           onTap: () {
                        //             focusNodes[index].requestFocus();
                        //           },
                        //         ),
                        //       ),
                        //     );
                        //   }),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 45,
                              child: TextField(
                                controller: controllers[index],
                                focusNode: focusNodes[index],
                                keyboardType: TextInputType.number,
                                textInputAction:
                                index == 5 ? TextInputAction.done : TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                maxLength: 1,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),

                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    if (index < 5) {
                                      FocusScope.of(context)
                                          .requestFocus(focusNodes[index + 1]);
                                    } else {
                                      focusNodes[index].unfocus();
                                    }
                                  } else {
                                    if (index > 0) {
                                      FocusScope.of(context)
                                          .requestFocus(focusNodes[index - 1]);
                                    }
                                  }
                                },
                              ),
                            );
                          }),
                        )
                      ],
                    ),
                  ),
                ),

                /// ===== VERIFY BUTTON =====
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      onPressed: state is OtpLoading
                          ? null
                          : () {
                        final otp = getOtp();

                        if (otp.length != 6) {
                          _showMsg("Enter valid 6-digit OTP",
                              bgColor: Colors.red);
                          return;
                        }

                        context.read<OtpBloc>().add(
                          SubmitOtpEvent(
                            userId: widget.userId,
                            otp: otp,
                          ),
                        );
                      },

                      child: state is OtpLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Verify OTP",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showMsg(String msg, {Color bgColor = Colors.grey}) {
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
}
