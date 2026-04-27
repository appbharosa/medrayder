import 'package:bloc/bloc.dart';
import '../../repository/about_repo/about_repository.dart';
import 'about_event.dart';
import 'about_state.dart';

class AboutBloc extends Bloc<AboutEvent, AboutState> {
  final AboutRepository aboutRepository;

  AboutBloc({required this.aboutRepository})
      : super(AboutInitial()) {
    on<FetchAbout>(_onFetchAbout);
  }

  Future<void> _onFetchAbout(
      FetchAbout event, Emitter<AboutState> emit) async {
    emit(AboutLoading());

    try {
      final data = await aboutRepository.getAbout();
      emit(AboutLoaded(data));
    } catch (e) {
      emit(AboutError(e.toString()));
    }
  }
}