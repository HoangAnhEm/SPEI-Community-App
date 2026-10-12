import 'package:equatable/equatable.dart';
import '../../../domain/entities/rag_chat.dart';

enum ChatStatus { initial, loading, streaming, success, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<RagMessage> messages;
  final String? sessionId;
  final bool isLoading;
  final bool isStreaming;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.sessionId,
    this.isLoading = false,
    this.isStreaming = false,
    this.errorMessage,
  });

  bool get isEmpty => messages.isEmpty;
  bool get canSendMessage => !isLoading && !isStreaming;

  ChatState copyWith({
    ChatStatus? status,
    List<RagMessage>? messages,
    String? sessionId,
    bool? isLoading,
    bool? isStreaming,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      sessionId: sessionId ?? this.sessionId,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        sessionId,
        isLoading,
        isStreaming,
        errorMessage,
      ];
}
