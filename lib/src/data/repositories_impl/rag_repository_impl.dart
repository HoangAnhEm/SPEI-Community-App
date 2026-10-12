import '../../domain/entities/rag_chat.dart';
import '../../domain/repositories/rag_repository.dart';
import '../datasources/remote/rag_remote_data_source.dart';
import '../models/rag_model.dart';

class RagRepositoryImpl implements RagRepository {
  final RagRemoteDataSource remoteDataSource;

  RagRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<RagStreamChunk> askQuestionStream({
    required String question,
    String? sessionId,
    int topK = 3,
  }) {
    final request = ChatQueryRequestModel(
      question: question,
      sessionId: sessionId,
      topK: topK,
    );
    return remoteDataSource.askQuestionStream(request);
  }

  @override
  Future<RagChatResponse> askQuestion({
    required String question,
    String? sessionId,
    int topK = 3,
  }) async {
    final request = ChatQueryRequestModel(
      question: question,
      sessionId: sessionId,
      topK: topK,
    );
    final rawData = await remoteDataSource.askQuestion(request);
    final model = ChatResponseModel.fromJson(rawData);
    return model.toEntity();
  }
}
