import 'package:bloc/bloc.dart';
import 'package:executive/bloc/user_bloc/user_event.dart';
import 'package:executive/bloc/user_bloc/user_state.dart';

import '../../model/user_model/user_model.dart';
import '../../repository/user_repo/user_post_repository.dart';
import '../../repository/user_repo/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  final UserPostRepository userPostRepository;

  List<User> users = [];
  int currentPage = 1;
  int lastPage = 1;

  UserBloc({
    required this.userRepository,
    required this.userPostRepository,
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
        emit(UserAdding()); // 🔥 LOADER START

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

          // ✅ ADDRESS FROM EVENT
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

        emit(UserAdded()); // ✅ SUCCESS

      } catch (e) {
        emit(UserAddError(e.toString())); // ❌ ERROR
      }
    });
  }
}