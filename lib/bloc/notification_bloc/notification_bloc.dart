
import 'package:bloc/bloc.dart';

import '../../model/notification_response/notification_response.dart';
import '../../repository/notification_repository/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  List<AppNotification> notifications = [];
  int unreadCount = 0;

  NotificationBloc({required this.repository})
      : super(NotificationInitial()) {

    on<ClearAllNotifications>((event, emit) {

      ///  MARK ALL AS READ LOCALLY
      notifications = notifications.map((n) {
        return n.copyWith(readStatus: 1);
      }).toList();

      unreadCount = 0;

      emit(NotificationLoaded(
        list: notifications,
        unreadCount: unreadCount,
      ));
    });

    ///  FETCH NOTIFICATIONS
    on<FetchNotifications>((event, emit) async {
      try {
        emit(NotificationLoading());

        final response = await repository.getNotifications();

        notifications = response.notifications ?? [];
        unreadCount = response.unreadCount ?? 0;

        emit(NotificationLoaded(
          list: notifications,
          unreadCount: unreadCount,
        ));
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    });

    ///  MARK SINGLE NOTIFICATION AS READ
    on<MarkNotificationRead>((event, emit) async {
      try {

        ///  CALL READ API
        await repository.getNotifications(id: event.id);

        ///  UPDATE LOCAL LIST (NO LOADER)
        notifications = notifications.map((n) {
          if (n.id == event.id) {
            return n.copyWith(readStatus: 1);
          }
          return n;
        }).toList();

        ///  UPDATE COUNT LOCALLY
        unreadCount = notifications.where((e) => e.readStatus == 0).length;

        emit(NotificationLoaded(
          list: notifications,
          unreadCount: unreadCount,
        ));

      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    });
  }
}