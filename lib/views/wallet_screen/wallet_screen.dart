import 'package:executive/config/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/wallet_bloc/wallet_bloc.dart';
import '../../bloc/wallet_bloc/wallet_event.dart';
import '../../bloc/wallet_bloc/wallet_state.dart';
import '../../model/wallet_model/wallet_model.dart';


// ==================== WALLET SCREEN WITH DROPDOWN FILTER ====================

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController scrollController = ScrollController();
  String selectedFilter = "All"; // Filter options: All, Credit, Debit

  @override
  void initState() {
    super.initState();

    context.read<WalletBloc>().add(FetchWallet());

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        context.read<WalletBloc>().add(LoadMoreWallet());
      }
    });
  }

  void _openWithdrawSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: context.read<WalletBloc>(),
          child: const WithdrawBottomSheet(),
        );
      },
    );
  }

  // Filter transactions based on selected filter
  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> transactions) {
    if (selectedFilter == "All") {
      return transactions;
    } else if (selectedFilter == "Credit") {
      return transactions.where((tx) => tx.credit != "-" && tx.credit != "").toList();
    } else if (selectedFilter == "Debit") {
      return transactions.where((tx) => tx.debit != "-" && tx.debit != "").toList();
    }
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,

        /// APPBAR
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.blue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Wallet",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),

        /// WITHDRAW BUTTON
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
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
              onPressed: _openWithdrawSheet,
              child: const Text("Withdraw"),
            ),
          ),
        ),

        /// BODY
        body: BlocConsumer<WalletBloc, WalletState>(
          listener: (context, state) {
            if (state is WalletWithdrawSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is WalletWithdrawError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is WalletLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WalletError) {
              return Center(child: Text(state.message));
            }

            if (state is WalletLoaded) {
              final result = state.result;
              final allTransactions = state.transactions;
              final filteredTransactions = _getFilteredTransactions(allTransactions);

              return Column(
                children: [
                  const SizedBox(height: 20),

                  /// BALANCE CARD
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.green, Colors.lightGreen],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Current Balance",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "₹ ${result.summary.currentBalance}",
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _miniItem(
                              "Total Credit",
                              result.summary.totalCredit,
                              Colors.white,
                              Icons.arrow_downward,
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            _miniItem(
                              "Total Debit",
                              result.summary.totalDebit,
                              Colors.white,
                              Icons.arrow_upward,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// DROPDOWN FILTER SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Transactions",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedFilter,
                              icon: const Icon(Icons.filter_list, color: AppColors.blue),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              items: const [
                                DropdownMenuItem(
                                  value: "All",
                                  child: Row(
                                    children: [
                                      Icon(Icons.list, size: 18),
                                      SizedBox(width: 8),
                                      Text("All"),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: "Credit",
                                  child: Row(
                                    children: [
                                      Icon(Icons.arrow_downward, size: 18, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text("Credit", style: TextStyle(color: Colors.green)),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: "Debit",
                                  child: Row(
                                    children: [
                                      Icon(Icons.arrow_upward, size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text("Debit", style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedFilter = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// TRANSACTIONS LIST
                  Expanded(
                    child: filteredTransactions.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No ${selectedFilter != "All" ? selectedFilter : ""} Transactions",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredTransactions.length +
                          (state is CircularProgressIndicator ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == filteredTransactions.length && state is CircularProgressIndicator) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final tx = filteredTransactions[i];
                        final isDebit = tx.debit != "-" && tx.debit != "";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: isDebit
                                    ? Colors.red.shade50
                                    : Colors.green.shade50,
                                child: Icon(
                                  isDebit
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: isDebit ? Colors.red : Colors.green,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Txn ID: ${tx.transactionId}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${tx.date} • ${tx.time}",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    isDebit
                                        ? "- ₹${tx.debit}"
                                        : "+ ₹${tx.credit}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDebit ? Colors.red : Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tx.status.toLowerCase() == "success"
                                          ? Colors.green.shade50
                                          : Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      tx.status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: tx.status.toLowerCase() == "success"
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// ==================== WITHDRAW BOTTOM SHEET ====================

class WithdrawBottomSheet extends StatefulWidget {
  const WithdrawBottomSheet({super.key});

  @override
  State<WithdrawBottomSheet> createState() => _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends State<WithdrawBottomSheet> {
  final TextEditingController amountController = TextEditingController();
  String? error;

  void _showError(String msg) {
    setState(() => error = msg);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => error = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletWithdrawSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<WalletBloc>().add(FetchWallet());
          }

          if (state is WalletWithdrawError) {
            _showError(state.message);
          }
        },
        builder: (context, state) {
          final loading = state is WalletWithdrawing;

          return SafeArea(
            bottom: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Withdraw Amount",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter the amount you want to withdraw",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter Amount",
                    prefixIcon: const Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                /// ERROR MESSAGE
                if (error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: loading
                        ? null
                        : () {
                      final amount = double.tryParse(amountController.text);

                      if (amountController.text.isEmpty) {
                        _showError("Please enter amount");
                        return;
                      }

                      if (amount == null || amount <= 0) {
                        _showError("Please enter a valid amount");
                        return;
                      }

                      if (amount > 100000) {
                        _showError("Maximum withdrawal limit is ₹1,00,000");
                        return;
                      }

                      context
                          .read<WalletBloc>()
                          .add(WithdrawWallet(amount.toString()));
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
                      "Submit Withdrawal Request",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== HELPER WIDGET ====================

Widget _miniItem(String title, int value, Color color, IconData icon) {
  return Column(
    children: [
      Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(title, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        "₹ $value",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ],
  );
}
