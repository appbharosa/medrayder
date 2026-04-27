import 'package:executive/bloc/update_bloc/update_event.dart';
import 'package:executive/bloc/update_bloc/update_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../model/update_response/update_response.dart';
import '../../repository/update_repository/update_repository.dart';

import 'package:executive/bloc/update_bloc/update_event.dart';
import 'package:executive/bloc/update_bloc/update_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/update_repository/update_repository.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  final UpdateRepository repository;

  UpdateBloc(this.repository) : super(UpdateInitial()) {
    on<CheckUpdateEvent>(_checkUpdate);
    on<UserDismissedUpdateEvent>(_onUserDismissed);
    on<UserClickedUpdateEvent>(_onUserClickedUpdate);
  }

  Future<void> _checkUpdate(
      CheckUpdateEvent event,
      Emitter<UpdateState> emit,
      ) async {
    emit(UpdateLoading());

    try {
      final response = await repository.getUpdateApi();

      /// FORCE UPDATE (older version - must update)
      if (response.status == 426) {
        emit(ForceUpdateRequired(response.result!));
      }

      /// NEW VERSION AVAILABLE (optional update)
      else if (response.status == 200 &&
          response.result != null &&
          response.result!.compatible == true &&
          response.result!.isLatest == false) {
        emit(NewVersionAvailable(response.result!));
      }

      /// APP IS UP TO DATE
      else if (response.status == 200 &&
          response.result != null &&
          response.result!.isLatest == true) {
        emit(UpdateNotRequired());
      }

      /// ERROR CASE
      else {
        emit(UpdateError(response.message));
      }

    } catch (e) {
      emit(UpdateError(e.toString()));
    }
  }

  void _onUserDismissed(UserDismissedUpdateEvent event, Emitter<UpdateState> emit) {
    // User dismissed the update dialog, proceed to login
    emit(UpdateNotRequired());
  }

  void _onUserClickedUpdate(UserClickedUpdateEvent event, Emitter<UpdateState> emit) {
    // User wants to update, navigate to Play Store
    emit(NavigateToPlayStore(event.updateUrl));
  }
}