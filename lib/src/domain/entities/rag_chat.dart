// Thực thể dữ liệu phục vụ hội thoại hỏi đáp RAG (Retrieval-Augmented Generation) và AI Assistant.

/// Khối dữ liệu nhận được trong quá trình stream SSE từ Backend (/api/v1/rag/ask/stream).
class RagStreamChunk {
  /// Session ID của phiên hội thoại (được gửi ở sự kiện đầu tiên `[SESSION_ID]: <id>`)
  final String? sessionId;

  /// Nội dung token/chữ vừa nhận từ LLM
  final String? token;

  /// Đánh dấu đã nhận tín hiệu kết thúc stream (`[DONE]`)
  final bool isDone;

  /// Thông báo lỗi nếu có trong luồng stream
  final String? error;

  const RagStreamChunk({
    this.sessionId,
    this.token,
    this.isDone = false,
    this.error,
  });

  bool get hasSessionId => sessionId != null && sessionId!.isNotEmpty;
  bool get hasToken => token != null && token!.isNotEmpty;
  bool get hasError => error != null && error!.isNotEmpty;

  @override
  String toString() {
    return 'RagStreamChunk(sessionId: $sessionId, token: $token, isDone: $isDone, error: $error)';
  }
}

/// Nguồn tài liệu tham khảo được trích dẫn trong câu trả lời RAG
class RagSourceChunk {
  final String chunkId;
  final String documentId;
  final String snippet;
  final double score;

  const RagSourceChunk({
    required this.chunkId,
    required this.documentId,
    required this.snippet,
    required this.score,
  });

  factory RagSourceChunk.fromJson(Map<String, dynamic> json) {
    return RagSourceChunk(
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
}

/// Tin nhắn trong phiên hội thoại AI
class RagMessage {
  final String id;
  final String role; // 'user' hoặc 'assistant'
  final String content;
  final DateTime createdAt;
  final bool isStreaming;
  final List<RagSourceChunk> sources;

  const RagMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.isStreaming = false,
    this.sources = const [],
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  RagMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? createdAt,
    bool? isStreaming,
    List<RagSourceChunk>? sources,
  }) {
    return RagMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
      sources: sources ?? this.sources,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'sources': sources.map((s) => s.toJson()).toList(),
    };
  }

  factory RagMessage.fromJson(Map<String, dynamic> json) {
    return RagMessage(
      id: (json['id'] ?? '') as String,
      role: (json['role'] ?? 'user') as String,
      content: (json['content'] ?? '') as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => RagSourceChunk.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

/// Kết quả phản hồi đầy đủ từ API hỏi đáp non-streaming (/api/v1/rag/ask)
class RagChatResponse {
  final String sessionId;
  final String answer;
  final List<RagSourceChunk> sources;

  const RagChatResponse({
    required this.sessionId,
    required this.answer,
    this.sources = const [],
  });
}
