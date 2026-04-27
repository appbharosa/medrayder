import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/terms_bloc/terms_bloc.dart';
import '../../bloc/terms_bloc/terms_event.dart';
import '../../bloc/terms_bloc/terms_state.dart';
import '../../config/colors/app_colors.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TermsBloc>().add(FetchTerms());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(
            fontSize: 19,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.blue,
      ),
      body: BlocBuilder<TermsBloc, TermsState>(
        builder: (context, state) {
          if (state is TermsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TermsLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                state.data.name,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            );
          } else if (state is TermsError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}