import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/about_bloc/about_bloc.dart';
import '../../bloc/about_bloc/about_state.dart';
import '../../config/colors/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "About",
          style: TextStyle(
            fontSize: 19,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AboutBloc, AboutState>(
        builder: (context, state) {
          if (state is AboutLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AboutError) {
            return Center(child: Text(state.message));
          } else if (state is AboutLoaded) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.about.name,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
