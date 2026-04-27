class WalletResponse {
  final int status;
  final String message;
  final WalletResult result;

  WalletResponse({
    required this.status,
    required this.message,
    required this.result,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      result: WalletResult.fromJson(json["result"] ?? {}),
    );
  }
}

class WalletResult {
  final UserInfo userInfo;
  final AccountSummary summary;
  final List<TransactionModel> transactions;
  final Pagination pagination;
  final StatementPeriod statementPeriod;

  WalletResult({
    required this.userInfo,
    required this.summary,
    required this.transactions,
    required this.pagination,
    required this.statementPeriod,
  });

  factory WalletResult.fromJson(Map<String, dynamic> json) {
    return WalletResult(
      userInfo: UserInfo.fromJson(json["user_info"] ?? {}),
      summary: AccountSummary.fromJson(json["account_summary"] ?? {}),
      transactions: (json["transactions"] as List? ?? [])
          .map((e) => TransactionModel.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json["pagination"] ?? {}),
      statementPeriod:
      StatementPeriod.fromJson(json["statement_period"] ?? {}),
    );
  }
}

class UserInfo {
  final String name;
  final String email;
  final String mobile;
  final String accountOpened;

  UserInfo({
    required this.name,
    required this.email,
    required this.mobile,
    required this.accountOpened,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      mobile: json["mobile"] ?? "",
      accountOpened: json["account_opened"] ?? "",
    );
  }
}

class AccountSummary {
  final int currentBalance;
  final int totalCredit;
  final int totalDebit;
  final int netBalance;
  final int totalTransactions;
  final int completedTransactions;
  final int pendingTransactions;

  AccountSummary({
    required this.currentBalance,
    required this.totalCredit,
    required this.totalDebit,
    required this.netBalance,
    required this.totalTransactions,
    required this.completedTransactions,
    required this.pendingTransactions,
  });

  factory AccountSummary.fromJson(Map<String, dynamic> json) {
    return AccountSummary(
      currentBalance:
      int.tryParse(json["current_balance"].toString()) ?? 0,
      totalCredit:
      int.tryParse(json["total_credit"].toString()) ?? 0,
      totalDebit:
      int.tryParse(json["total_debit"].toString()) ?? 0,
      netBalance:
      int.tryParse(json["net_balance"].toString()) ?? 0,
      totalTransactions:
      int.tryParse(json["total_transactions"].toString()) ?? 0,
      completedTransactions:
      int.tryParse(json["completed_transactions"].toString()) ?? 0,
      pendingTransactions:
      int.tryParse(json["pending_transactions"].toString()) ?? 0,
    );
  }
}

class TransactionModel {
  final String date;
  final String time;
  final String transactionId;
  final String debit;
  final String credit;
  final String status;

  TransactionModel({
    required this.date,
    required this.time,
    required this.transactionId,
    required this.debit,
    required this.credit,
    required this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      date: json["date"] ?? "",
      time: json["time"] ?? "",
      transactionId: json["transaction_id"] ?? "",
      debit: json["debit"]?.toString() ?? "",
      credit: json["credit"]?.toString() ?? "",
      status: json["status"] ?? "",
    );
  }
}

class Pagination {
  final int currentPage;
  final int lastPage;

  Pagination({
    required this.currentPage,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json["current_page"] ?? 0,
      lastPage: json["last_page"] ?? 0,
    );
  }
}

class StatementPeriod {
  final String startDate;
  final String endDate;

  StatementPeriod({
    required this.startDate,
    required this.endDate,
  });

  factory StatementPeriod.fromJson(Map<String, dynamic> json) {
    return StatementPeriod(
      startDate: json["start_date"] ?? "",
      endDate: json["end_date"] ?? "",
    );
  }
}