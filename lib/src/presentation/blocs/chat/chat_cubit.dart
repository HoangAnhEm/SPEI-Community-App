import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/rag_chat.dart';
import '../../../domain/repositories/rag_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final RagRepository _ragRepository;
  StreamSubscription<RagStreamChunk>? _streamSubscription;

  ChatCubit(this._ragRepository) : super(const ChatState());

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }

  /// Gửi câu hỏi tới Bạn Mầm AI với luồng stream SSE
  Future<void> sendMessage(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || !state.canSendMessage) return;

    // 1. Thêm tin nhắn của User
    final userMessage = RagMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: trimmed,
      createdAt: DateTime.now(),
    );

    // 2. Tạo tin nhắn bot ban đầu với nội dung rỗng để chờ stream token
    final botMessageId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
    final botMessage = RagMessage(
      id: botMessageId,
      role: 'assistant',
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );

    emit(state.copyWith(
      status: ChatStatus.loading,
      messages: [...state.messages, userMessage, botMessage],
      isLoading: true,
      isStreaming: true,
      errorMessage: null,
    ));

    try {
      _streamSubscription?.cancel();

      // Tuân thủ logic: message đầu tiên session_id là null, các câu hỏi tiếp theo dùng session_id đã nhận
      final stream = _ragRepository.askQuestionStream(
        question: trimmed,
        sessionId: state.sessionId,
        topK: 3,
      );

      _streamSubscription = stream.listen(
        (chunk) {
          String? currentSessionId = state.sessionId;
          if (chunk.hasSessionId) {
            currentSessionId = chunk.sessionId;
          }

          if (chunk.hasError) {
            final updatedMessages = state.messages.map((m) {
              if (m.id == botMessageId) {
                return m.copyWith(
                  content: chunk.error!,
                  isStreaming: false,
                );
              }
              return m;
            }).toList();

            emit(state.copyWith(
              status: ChatStatus.error,
              sessionId: currentSessionId,
              messages: updatedMessages,
              isLoading: false,
              isStreaming: false,
              errorMessage: chunk.error,
            ));
            return;
          }

          if (chunk.hasToken) {
            final updatedMessages = state.messages.map((m) {
              if (m.id == botMessageId) {
                return m.copyWith(
                  content: m.content + chunk.token!,
                  isStreaming: true,
                );
              }
              return m;
            }).toList();

            emit(state.copyWith(
              status: ChatStatus.streaming,
              sessionId: currentSessionId,
              messages: updatedMessages,
              isLoading: false,
              isStreaming: true,
            ));
          }

          if (chunk.isDone) {
            final updatedMessages = state.messages.map((m) {
              if (m.id == botMessageId) {
                return m.copyWith(
                  isStreaming: false,
                );
              }
              return m;
            }).toList();

            emit(state.copyWith(
              status: ChatStatus.success,
              sessionId: currentSessionId,
              messages: updatedMessages,
              isLoading: false,
              isStreaming: false,
            ));
          }
        },
        onError: (error) {
          final updatedMessages = state.messages.map((m) {
            if (m.id == botMessageId) {
              return m.copyWith(
                content: m.content.isEmpty
                    ? 'Không thể kết nối đến máy chủ AI. Vui lòng thử lại.'
                    : m.content,
                isStreaming: false,
              );
            }
            return m;
          }).toList();

          emit(state.copyWith(
            status: ChatStatus.error,
            messages: updatedMessages,
            isLoading: false,
            isStreaming: false,
            errorMessage: error.toString().replaceFirst('Exception: ', ''),
          ));
        },
      );
    } catch (e) {
      final updatedMessages = state.messages.map((m) {
        if (m.id == botMessageId) {
          return m.copyWith(
            content: 'Đã xảy ra sự cố khi gửi tin nhắn.',
            isStreaming: false,
          );
        }
        return m;
      }).toList();

      emit(state.copyWith(
        status: ChatStatus.error,
        messages: updatedMessages,
        isLoading: false,
        isStreaming: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  /// Làm mới cuộc trò chuyện (xóa tin nhắn và reset session_id về null)
  void resetChat() {
    _streamSubscription?.cancel();
    emit(const ChatState());
  }
}
