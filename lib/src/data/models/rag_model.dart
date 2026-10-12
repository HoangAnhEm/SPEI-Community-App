import '../../domain/entities/rag_chat.dart';

/// Request DTO gửi câu hỏi tới hệ thống RAG AI (/api/v1/rag/ask hoặc /api/v1/rag/ask/stream)
class ChatQueryRequestModel {
  final String question;
  final String? sessionId;
  final int topK;

  const ChatQueryRequestModel({
    required this.question,
    this.sessionId,
    this.topK = 3,
  }) : assert(topK >= 1 && topK <= 10, 'topK must be between 1 and 10');

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      if (sessionId != null && sessionId!.isNotEmpty) 'session_id': sessionId,
      'top_k': topK,
    };
  }
}

/// DTO nguồn trích dẫn từ tri thức tài liệu
class ChatSourceChunkModel {
  final String chunkId;
  final String documentId;
  final String snippet;
  final double score;

  const ChatSourceChunkModel({
    required this.chunkId,
    required this.documentId,
    required this.snippet,
    required this.score,
  });

  factory ChatSourceChunkModel.fromJson(Map<String, dynamic> json) {
    return ChatSourceChunkModel(
      chunkId: (json['chunk_id'] ?? '') as String,
      documentId: (json['document_id'] ?? '') as String,
      snippet: (json['snippet'] ?? '') as String,
      score: ((json['score'] ?? 0.0) as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chunk_id': chunkId,
      'document_id': documentId,
      'snippet': snippet,
      'score': score,
    };
  }

  RagSourceChunk toEntity() {
    return RagSourceChunk(
      chunkId: chunkId,
      documentId: documentId,
      snippet: snippet,
      score: score,
    );
  }
}

/// DTO kết quả câu trả lời đầy đủ từ Backend (/api/v1/rag/ask)
class ChatResponseModel {
  final String sessionId;
  final String answer;
  final List<ChatSourceChunkModel> sources;

  const ChatResponseModel({
    required this.sessionId,
    required this.answer,
    this.sources = const [],
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      sessionId: (json['session_id'] ?? '') as String,
      answer: (json['answer'] ?? '') as String,
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) =>
                  ChatSourceChunkModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  RagChatResponse toEntity() {
    return RagChatResponse(
      sessionId: sessionId,
      answer: answer,
      sources: sources.map((s) => s.toEntity()).toList(),
    );
  }
}
