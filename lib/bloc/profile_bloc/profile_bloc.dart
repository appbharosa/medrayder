import 'package:bloc/bloc.dart';
import 'package:executive/bloc/profile_bloc/profile_event.dart';
import 'package:executive/bloc/profile_bloc/profile_state.dart';
import '../../repository/profile_repo/profile_repository.dart';
import '../../repository/profile_repo/update_profile_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  final UpdateProfileRepository updateRepository;

  ProfileBloc(this.repository, this.updateRepository)
      : super(ProfileInitial()) {

    on<GetProfileEvent>(_getProfile);
    on<ToggleEditEvent>(_toggleEdit);
    on<UpdateProfileEvent>(_updateProfile);
  }

  Future<void> _getProfile(
      GetProfileEvent event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());

    try {
      final data = await repository.getProfile();
      emit(ProfileLoaded(data));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// ================= TOGGLE EDIT =================
  void _toggleEdit(
      ToggleEditEvent event,
      Emitter<ProfileState> emit,
      ) {
    if (state is ProfileLoaded) {
      final current = state as ProfileLoaded;

      emit(ProfileLoaded(
        current.profile,
        isEditable: !current.isEditable,
      ));
    }
  }

  /// ================= UPDATE PROFILE =================
  Future<void> _updateProfile(
      UpdateProfileEvent event,
      Emitter<ProfileState> emit,
      ) async {
    try {
      emit(ProfileUpdating());

      final response = await updateRepository.updateProfile(
        name: event.name,
        gender: event.gender,
        occupation: event.occupation,
        dob: event.dob,
        image: event.image,
      );
      final updatedData = await repository.getProfile();

      emit(ProfileLoaded(
        updatedData,
        isEditable: false,
        message: response.message,
      ));

    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}