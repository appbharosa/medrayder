import 'package:bloc/bloc.dart';
import '../../config/session_manager/session_manager.dart';
import '../../repository/home_repository/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;

  HomeBloc(this.repository) : super(HomeInitial()) {
    on<FetchHomeData>((event, emit) async {
      emit(HomeLoading());
      try {
        final data = await repository.getHomeData();
        /// 🔥 SAVE IMAGE TO SESSION
        await SessionManager.saveProfileImage(data.image);
        emit(HomeLoaded(data));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });
  }
}