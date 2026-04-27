import 'package:bloc/bloc.dart';
import 'package:executive/bloc/wallet_bloc/wallet_event.dart';
import 'package:executive/bloc/wallet_bloc/wallet_state.dart';
import '../../config/session_manager/session_manager.dart';
import '../../model/wallet_model/wallet_model.dart';
import '../../repository/wallet_repository/wallet_repository.dart';
import '../../repository/wallet_repository/wallet_withdraw_repository.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository repository;
  final WalletWithdrawRepository withdrawRepository;

  int page = 1;
  bool isFetching = false;
  List<TransactionModel> allTransactions = [];

  WalletResult? lastResult; //  STORE LAST DATA

  WalletBloc({
    required this.repository,
    required this.withdrawRepository,
  }) : super(WalletInitial()) {
    on<FetchWallet>(_fetchWallet);
    on<LoadMoreWallet>(_loadMore);
    on<WithdrawWallet>(_withdrawWallet);
  }

  /// ================= FETCH =================
  Future<void> _fetchWallet(FetchWallet event, Emitter emit) async {
    emit(WalletLoading());
    try {
      final userId = await SessionManager.getUserId();

      page = 1;

      final res = await repository.getWallet(
        userId: userId!,
        page: page,
      );

      allTransactions = res.result.transactions;
      lastResult = res.result; //  SAVE

      emit(WalletLoaded(
        result: res.result,
        transactions: allTransactions,
        currentPage: res.result.pagination.currentPage,
        lastPage: res.result.pagination.lastPage,
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// ================= PAGINATION =================
  Future<void> _loadMore(LoadMoreWallet event, Emitter emit) async {
    if (state is WalletLoaded && !isFetching) {
      final currentState = state as WalletLoaded;

      if (currentState.currentPage >= currentState.lastPage) return;

      isFetching = true;
      page++;

      try {
        final userId = await SessionManager.getUserId();

        final res = await repository.getWallet(
          userId: userId!,
          page: page,
        );

        allTransactions.addAll(res.result.transactions);

        emit(WalletLoaded(
          result: currentState.result, //  KEEP HEADER
          transactions: allTransactions,
          currentPage: res.result.pagination.currentPage,
          lastPage: res.result.pagination.lastPage,
        ));
      } catch (e) {
        emit(WalletError(e.toString()));
      }

      isFetching = false;
    }
  }

  /// ================= WITHDRAW =================
  Future<void> _withdrawWallet(
      WithdrawWallet event, Emitter emit) async {
    try {
      final userId = await SessionManager.getUserId();

      //  DO NOT REMOVE UI
      if (state is WalletLoaded) {
        final currentState = state as WalletLoaded;

        emit(WalletLoaded(
          result: currentState.result,
          transactions: currentState.transactions,
          currentPage: currentState.currentPage,
          lastPage: currentState.lastPage,
        ));
      }

      final res = await withdrawRepository.walletWithdraw(
        userId: userId!,
        amount: event.amount,
      );

      emit(WalletWithdrawSuccess(res.message));

      ///  REFRESH ONLY ON SUCCESS
      add(FetchWallet());

    } catch (e) {
      emit(WalletWithdrawError(e.toString()));

      //  RESTORE OLD UI
      if (lastResult != null) {
        emit(WalletLoaded(
          result: lastResult!,
          transactions: allTransactions,
          currentPage: page,
          lastPage: lastResult!.pagination.lastPage,
        ));
      }
    }
  }
}