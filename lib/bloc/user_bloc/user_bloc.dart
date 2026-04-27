import 'package:bloc/bloc.dart';
import 'package:executive/bloc/user_bloc/user_event.dart';
import 'package:executive/bloc/user_bloc/user_state.dart';

import '../../model/user_model/user_model.dart';
import '../../repository/user_repo/user_post_repository.dart';
import '../../repository/user_repo/user_repository.dart';
import '../../repository/user_repo/user_sendotp_repository.dart';
import '../../repository/user_repo/verify_userotp_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  final UserPostRepository userPostRepository;

  final UserSendOtpRepository sendOtpRepository;
  final UserOtpVerifyRepository verifyOtpRepository;

  List<User> users = [];
  int currentPage = 1;
  int lastPage = 1;

  UserBloc({
    required this.userRepository,
    required this.userPostRepository,
    required this.sendOtpRepository,
    required this.verifyOtpRepository,
  }) : super(UserInitial()) {

    /// ================= FETCH USERS =================
    on<FetchUsers>((event, emit) async {
      try {
        if (event.reset) {
          currentPage = 1;
          users.clear();
        }

        emit(UserLoading());

        final result = await userRepository.getUsers(
          page: currentPage,
          search: event.search,
        );

        users.addAll(result.data);
        currentPage = result.currentPage + 1;
        lastPage = result.lastPage;

        emit(UserLoaded(
          users: users,
          currentPage: currentPage,
          lastPage: lastPage,
        ));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    /// ================= ADD USER =================
    on<AddUser>((event, emit) async {
      try {
        emit(UserAdding());

        await userPostRepository.postUser(
          userId: event.userId,
          name: event.name,
          email: event.email,
          mobile: event.mobile,
          gender: event.gender,
          dob: event.dob,
          bloodGroupId: event.bloodGroupId,
          coverageCategoryId: event.coverageCategoryId,
          image: event.image,

          // ADDRESS
          hno: event.hno,
          buildingNo: event.buildingNo,
          landmark: event.landmark,
          address: event.address,
          pincode: event.pincode,
          state: event.state,
          city: event.city,
          addressType: event.addressType,
          isDefault: event.isDefault,
        );

        emit(UserAdded());

      } catch (e) {
        emit(UserAddError(e.toString()));
      }
    });

    /// ================= OTP EVENTS =================
    on<SendUserOtp>(_sendOtp);
    on<VerifyUserOtp>(_verifyOtp);
  }

  /// 🔥 SEND OTP
  Future<void> _sendOtp(
      SendUserOtp event, Emitter<UserState> emit) async {
    try {
      emit(UserOtpSending());

      await sendOtpRepository.sendOtp(
        email: event.email,
      );

      emit(UserOtpSent());
    } catch (e) {
      emit(UserOtpError(e.toString()));
    }
  }

  /// 🔥 VERIFY OTP
  Future<void> _verifyOtp(
      VerifyUserOtp event, Emitter<UserState> emit) async {
    try {
      emit(UserOtpVerifying());

      await verifyOtpRepository.verifyOtp(
        email: event.email,
        otp: event.otp,
      );

      emit(UserOtpVerified());
    } catch (e) {
      emit(UserOtpError(e.toString()));
    }
  }
}