import '../entities/rag_chat.dart';

abstract class RagRepository {
  /// Gửi câu hỏi tới AI và nhận luồng dữ liệu phản hồi từng phần qua Server-Sent Events (SSE)
  /// Endpoint: POST /api/v1/rag/ask/stream
  Stream<RagStreamChunk> askQuestionStream({
    required String question,
    String? sessionId,
    int topK = 3,
  });

  /// Gửi câu hỏi tới AI và nhận toàn bộ câu trả lời một lần (Non-streaming)
  /// Endpoint: POST /api/v1/rag/ask
  Future<RagChatResponse> askQuestion({
    required String question,
    String? sessionId,
    int topK = 3,
  });
}
