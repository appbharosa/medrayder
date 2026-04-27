import 'package:bloc/bloc.dart';
import '../../model/agent_model/agent_model.dart';
import '../../repository/agent_repo/agent_repository.dart';
import '../../repository/agent_repo/post_agent_repository.dart';
import 'agent_event.dart';
import 'agent_state.dart';
import 'package:dio/dio.dart';


class AgentBloc extends Bloc<AgentEvent, AgentState> {
  final AgentRepository agentRepository;
  final PostAgentRepository postAgentRepository;

  List<Agent> agents = [];
  int currentPage = 1;
  int lastPage = 1;

  AgentBloc({required this.agentRepository, required this.postAgentRepository})
      : super(AgentInitial()) {

    // Fetch Agents
    on<FetchAgents>((event, emit) async {
      try {
        if (event.reset) {
          currentPage = 1;
          agents.clear();
        }

        emit(AgentLoading());
        final result = await agentRepository.getAgents(
          page: currentPage,
          search: event.search,
        );

        agents.addAll(result.data);
        currentPage = result.currentPage + 1;
        lastPage = result.lastPage;

        emit(AgentLoaded(
          agents: agents,
          currentPage: currentPage,
          lastPage: lastPage,
        ));
      } catch (e) {
        emit(AgentError(e.toString()));
      }
    });

    // Add Agent
    on<AddAgent>((event, emit) async {
      try {
        emit(AgentAdding());

        FormData formData = FormData.fromMap({
          "user_id": event.userId,
          "name": event.name,
          "email": event.email,
          "mobile": event.mobile,
          "gender": event.gender,
          "dob": event.dob,
          "occupation": event.occupation,
          if (event.image != null)
            "image": await MultipartFile.fromFile(
              event.image!.path,
              filename: event.image!.path.split('/').last,
            ),
        });

        await postAgentRepository.postAgent(formData);

        emit(AgentAdded());

        add(FetchAgents(reset: true));
      } catch (e) {
        emit(AgentAddError(e.toString()));
      }
    });
  }
}