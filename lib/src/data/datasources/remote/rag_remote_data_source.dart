import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/rag_chat.dart';
import '../../models/rag_model.dart';

class RagRemoteDataSource {
  final ApiClient _apiClient;

  RagRemoteDataSource(this._apiClient);

  Dio get _dio => _apiClient.dio;

  /// Hỏi đáp AI với luồng dữ liệu Server-Sent Events (SSE)
  /// Backend Endpoint: POST /api/v1/rag/ask/stream
  Stream<RagStreamChunk> askQuestionStream(
    ChatQueryRequestModel request,
  ) async* {
    ResponseBody? responseBody;
    try {
      final response = await _dio.post<ResponseBody>(
        '/rag/ask/stream',
        data: request.toJson(),
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(minutes: 5), // Giữ stream mở khi AI đang sinh chữ
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
        ),
      );

      responseBody = response.data;
      if (responseBody == null) {
        yield const RagStreamChunk(
          error: 'Không nhận được dữ liệu phản hồi từ máy chủ AI.',
          isDone: true,
        );
        return;
      }
    } on DioException catch (e) {
      String errorMessage = 'Không thể kết nối đến máy chủ AI.';
      if (e.response?.data is ResponseBody) {
        try {
          final rb = e.response!.data as ResponseBody;
          final bytes = await rb.stream.toList();
          final totalBytes = bytes.expand((x) => x).toList();
          final jsonString = utf8.decode(totalBytes);
          final decoded = jsonDecode(jsonString);
          if (decoded is Map) {
            errorMessage = decoded['message'] ?? decoded['detail'] ?? errorMessage;
          }
        } catch (_) {}
      } else if (e.response?.data is Map) {
        final map = e.response!.data as Map;
        errorMessage = map['message'] ?? map['detail'] ?? errorMessage;
      } else if (e.message != null && e.message!.isNotEmpty) {
        errorMessage = e.message!;
      }
      yield RagStreamChunk(error: errorMessage, isDone: true);
      return;
    } catch (e) {
      yield RagStreamChunk(error: e.toString(), isDone: true);
      return;
    }

    // Đọc và phân giải luồng SSE (Server-Sent Events)
    bool isCompleted = false;
    try {
      final lineStream = responseBody.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lineStream) {
        if (line.isEmpty) {
          continue;
        }

        // Bỏ qua dòng comment / keep-alive của SSE
        if (line.startsWith(':')) {
          continue;
        }

        if (line.startsWith('data:')) {
          String data;
          if (line.startsWith('data: ')) {
            data = line.substring(6);
          } else {
            data = line.substring(5);
          }

          // Kiểm tra tín hiệu kết thúc luồng
          if (data.trim() == '[DONE]') {
            isCompleted = true;
            yield const RagStreamChunk(isDone: true);
            break;
          }

          // Kiểm tra tín hiệu thông báo session_id
          if (data.startsWith('[SESSION_ID]:')) {
            final sessionId = data.substring(13).trim();
            yield RagStreamChunk(sessionId: sessionId);
          } else {
            // Token sinh ra từ AI (nếu là 'data: ' rỗng thì tương ứng với ký tự xuống dòng)
            final token = data.isEmpty ? '\n' : data;
            yield RagStreamChunk(token: token);
          }
        } else {
          // Các dòng tiếp theo trong trường hợp token chứa xuống dòng trực tiếp
          yield RagStreamChunk(token: '\n$line');
        }
      }
    } catch (e) {
      yield RagStreamChunk(error: e.toString(), isDone: true);
      return;
    } finally {
      if (!isCompleted) {
        yield const RagStreamChunk(isDone: true);
      }
    }
  }

  /// Hỏi đáp AI theo dạng thông thường Request - Response (Non-streaming)
  /// Backend Endpoint: POST /api/v1/rag/ask
  Future<Map<String, dynamic>> askQuestion(
    ChatQueryRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/rag/ask',
        data: request.toJson(),
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể gửi câu hỏi đến AI.',
      );
    }
  }
}
