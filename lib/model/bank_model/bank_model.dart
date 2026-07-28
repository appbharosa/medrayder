class BankModel {
  final int id;
  final int userId;
  final String? bankName;      // ✅ nullable
  final String? branchName;    // already nullable
  final String accountName;
  final String accountNumber;
  final String ifscCode;
  final String? accountType;   // ✅ nullable

  BankModel({
    required this.id,
    required this.userId,
    this.bankName,
    this.branchName,
    required this.accountName,
    required this.accountNumber,
    required this.ifscCode,
    this.accountType,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      bankName: json['bank_name'] as String?,      // can be null
      branchName: json['branch_name'] as String?,
      accountName: json['account_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      accountType: json['account_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bank_name': bankName,
      'branch_name': branchName,
      'account_name': accountName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'account_type': accountType,
    };
  }
}