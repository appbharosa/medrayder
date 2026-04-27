import 'package:bloc/bloc.dart';
import 'package:executive/bloc/subscription_bloc/subscription_event.dart';
import 'package:executive/bloc/subscription_bloc/subscription_state.dart';

import '../../model/subscription_model/subscription_model.dart';
import '../../repository/subscriptions_repository/subscriptions_repository.dart';

class SubscriptionBloc
    extends Bloc<SubscriptionEvent, SubscriptionState> {

  final SubscriptionsRepository subscriptionsRepository;

  List<Subscription> subscriptions = [];
  int currentPage = 1;
  int lastPage = 1;
  bool isFetching = false;

  SubscriptionBloc({
    required this.subscriptionsRepository,
  }) : super(SubscriptionInitial()) {

    /// ================= FETCH =================
    on<FetchSubscriptions>((event, emit) async {
      try {
        if (isFetching || currentPage > lastPage) return;
        isFetching = true;
        if (event.reset) {
          currentPage = 1;
          lastPage = 1;
          subscriptions.clear();
        }

        if (subscriptions.isEmpty) {
          emit(SubscriptionLoading());
        }

        final response = await subscriptionsRepository.getSubscriptions(
          page: currentPage,
        );

        if (response.data.isEmpty && subscriptions.isEmpty) {
          emit(SubscriptionError("No Data Found"));
          isFetching = false;
          return;
        }

        subscriptions.addAll(response.data);

        currentPage = response.currentPage + 1;
        lastPage = response.lastPage;

        emit(SubscriptionLoaded(
          list: List.from(subscriptions),
          currentPage: currentPage,
          lastPage: lastPage,
        ));

      } catch (e) {
        emit(SubscriptionError(e.toString()));
      } finally {
        isFetching = false;
      }
    });
  }
}