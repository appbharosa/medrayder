import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/notification_bloc/notification_bloc.dart';
import '../../bloc/notification_bloc/notification_event.dart';
import '../../bloc/notification_bloc/notification_state.dart';
import '../../config/colors/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  @override
  void initState() {
    super.initState();

    ///  CLEAR COUNT WHEN OPEN
    context.read<NotificationBloc>().add(ClearAllNotifications());

    ///  OPTIONAL: REFRESH LIST FROM API
    context.read<NotificationBloc>().add(FetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {

          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return Center(child: Text(state.message));
          }

          if (state is NotificationLoaded) {

            if (state.list.isEmpty) {
              return const Center(child: Text("No Notifications"));
            }

            return ListView.builder(
              itemCount: state.list.length,
              itemBuilder: (context, index) {

                final item = state.list[index];

                return ListTile(
                  onTap: () {
                    context.read<NotificationBloc>().add(
                      MarkNotificationRead(item.id),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: item.readStatus == 0
                        ? Colors.red
                        : Colors.grey,
                    child: const Icon(Icons.notifications,
                        color: Colors.white),
                  ),
                  title: Text(item.title),
                  subtitle: Text(item.message),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
