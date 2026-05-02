class ProfileModel {
  final int id;
  final String uniqueId;
  final String name;
  final String mobile;
  final String email;
  final String gender;
  final String? dob;
  final String kycStatus;

  final String gst;
  final String tds;
  final String? image;
  final int stateId;
  final int districtId;
  final int mandalId;
  final String? occupation;
  final int availability;
  final String? profileImage;
  final String status;
  final String panCard;

  ProfileModel({
    required this.id,
    required this.uniqueId,
    required this.name,
    required this.mobile,
    required this.email,
    required this.gender,
    this.dob,
    required this.kycStatus,
    required this.gst,
    required this.tds,
    this.image,
    required this.stateId,
    required this.districtId,
    required this.mandalId,
    this.occupation,
    required this.availability,
    this.profileImage,
    required this.status,
    required this.panCard
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json["result"];

    return ProfileModel(
      id: data["id"] ?? 0,
      uniqueId: data["unique_id"] ?? "",
      name: data["name"] ?? "",
      mobile: data["mobile"] ?? "",
      email: data["email"] ?? "",
      gender: data["gender"] ?? "",
      dob: data["dob"],
      kycStatus: data["kyc_status"] ?? "",

      gst: data["gst"] ?? "",
      tds: data["tds"] ?? "",
      image: data["image"],
      stateId: data["state_id"] ?? 0,
      districtId: data["district_id"] ?? 0,
      mandalId: data["mandal_id"] ?? 0,
      occupation: data["occupation"],
      availability: data["availability"] ?? 0,
      profileImage: data["profile_image"],
      status: data["status"] ?? "",
      panCard: data["pancard"] ?? "",
    );
  }
}