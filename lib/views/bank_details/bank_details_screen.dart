import 'package:executive/config/session_manager/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/bank_bloc/bank_bloc.dart';
import '../../bloc/bank_bloc/bank_event.dart';
import '../../bloc/bank_bloc/bank_state.dart';
import '../../config/colors/app_colors.dart';
import '../../model/bank_model/bank_model.dart';


class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  List<BankModel> _banks = [];

  @override
  void initState() {
    super.initState();
    context.read<BankBloc>().add(FetchBanks());
  }

  void _showMsg(String msg, {Color bgColor = Colors.grey, required BuildContext ctx}) {
    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(msg, style: const TextStyle(color: Colors.white)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.blue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Bank Details",
            style: TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),

        body: BlocConsumer<BankBloc, BankState>(
          listener: (context, state) {
            if (state is BankError) {
              _showMsg(state.message, bgColor: Colors.red, ctx: context);
            } else if (state is BankLoaded) {
              _banks = state.banks;
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                // Show list or "No Bank Details Found"
                if (_banks.isEmpty)
                  const Center(child: Text("No Bank Details Found"))
                else
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _banks.length,
                    itemBuilder: (_, i) {
                      final bank = _banks[i];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(bank.accountName,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _openBottomSheet(bank: bank),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              _buildField("Bank Name", bank.bankName.toString()),
                              _buildField("Branch", bank.branchName ?? "-"),
                              _buildField("Account Number", bank.accountNumber),
                              _buildField("IFSC Code", bank.ifscCode),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // Loader overlay
                if (state is BankLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openBottomSheet(),
          icon: const Icon(Icons.add),
          label: const Text("Add Bank"),
        ),
      ),
    );
  }

  Widget _buildField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _openBottomSheet({BankModel? bank}) async {
    final name = TextEditingController(text: bank?.accountName);
    final accNo = TextEditingController(text: bank?.accountNumber);
    final ifsc = TextEditingController(text: bank?.ifscCode);
    final bankName = TextEditingController(text: bank?.bankName);
    final branch = TextEditingController(text: bank?.branchName);

    final userId = await SessionManager.getUserId();
    final bankBloc = context.read<BankBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        String? msg;
        Color msgColor = Colors.grey;

        return StatefulBuilder(
          builder: (context, setState) {
            return BlocConsumer<BankBloc, BankState>(
              bloc: bankBloc,
              listener: (context, state) {
                if (state is BankError) {
                  setState(() {
                    msg = state.message;
                    msgColor = Colors.red;
                  });
                } else if (state is BankSuccess) {
                  setState(() {
                    msg = "Bank Details Saved";
                    msgColor = Colors.green;
                  });

                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.pop(bottomSheetContext);
                    bankBloc.add(FetchBanks()); // refresh main list
                  });
                }
              },
              builder: (context, state) {
                return Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 20,
                        bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (msg != null)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: msgColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(msg!, style: const TextStyle(color: Colors.white)),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(bank == null ? "Add Bank Details" : "Update Bank Details",
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.pop(bottomSheetContext),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _input("Account Holder Name", name),
                            _input("Account Number", accNo),
                            _input("IFSC Code", ifsc),
                            _input("Bank Name", bankName),
                            _input("Branch Name", branch),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  if (name.text.isEmpty || accNo.text.isEmpty || ifsc.text.isEmpty) {
                                    setState(() {
                                      msg = "Please fill all required fields";
                                      msgColor = Colors.red;
                                    });
                                    return;
                                  }

                                  final body = {
                                    "user_id": userId,
                                    "account_name": name.text,
                                    "account_number": accNo.text,
                                    "ifsc_code": ifsc.text,
                                    "bank_name": bankName.text,
                                    "account_type": "savings",
                                    "branch_name": branch.text,
                                  };

                                  if (bank == null) {
                                    bankBloc.add(AddBank(body));
                                  } else {
                                    bankBloc.add(UpdateBank(bank.id, body));
                                  }
                                },
                                child: const Text("Save", style: TextStyle(fontSize: 16)),
                              ),
                            ),

                            SizedBox(height: 30,)
                          ],
                        ),
                      ),
                    ),
                    if (state is BankLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black45,
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
