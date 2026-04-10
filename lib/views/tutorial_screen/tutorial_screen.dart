import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/tutorial_bloc/tutorial_bloc.dart';
import '../../bloc/tutorial_bloc/tutorial_state.dart';
import '../../config/colors/app_colors.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// 🔷 APP BAR (BACK BUTTON)
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Tutorials",
          style: TextStyle(
            fontSize: 19,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      /// 🔷 BODY
      body: BlocBuilder<TutorialBloc, TutorialState>(
        builder: (context, state) {

          if (state is TutorialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TutorialError) {
            return Center(child: Text(state.message));
          }

          if (state is TutorialLoaded) {
            if (state.list.isEmpty) {
              return const Center(child: Text("No Tutorials Found"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.list.length,
              itemBuilder: (context, index) {
                final item = state.list[index];

                final colors = [
                  Colors.blue,
                  Colors.orange,
                  Colors.green,
                  Colors.purple,
                ];

                return InkWell(
                  onTap: () {
                    if (item.videoUrl.isNotEmpty) {
                      openVideo(item.videoUrl, context);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  
                        /// 🔷 TITLE
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                  
                        const SizedBox(height: 6),
                  
                        /// 🔷 DESCRIPTION
                        Text(
                          item.description,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                  
                        const SizedBox(height: 10),
                  
                        /// 🔷 FOOTER ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                  
                            Text(
                              item.duration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  
                            const Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
  Future<void> openVideo(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);

      // 🔥 Directly launch (no canLaunchUrl)
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!success) {
        throw "Launch failed";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open video")),
      );
    }
  }
}
