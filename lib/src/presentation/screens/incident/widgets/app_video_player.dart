import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'fullscreen_video_viewer.dart';
import 'package:spei_community/src/core/constants/app_colors.dart';

/// Widget phát video trong ứng dụng với đầy đủ điều khiển (Play, Pause, Tua, Toàn màn hình)
class AppVideoPlayer extends StatefulWidget {
  final String? localPath;
  final String? networkUrl;
  final bool autoPlay;
  final VoidCallback? onRemove;
  final String? badgeLabel;

  const AppVideoPlayer({
    super.key,
    this.localPath,
    this.networkUrl,
    this.autoPlay = false,
    this.onRemove,
    this.badgeLabel,
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.localPath != oldWidget.localPath ||
        widget.networkUrl != oldWidget.networkUrl) {
      _disposePlayer();
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.localPath != null && widget.localPath!.isNotEmpty) {
        _controller = VideoPlayerController.file(File(widget.localPath!));
      } else if (widget.networkUrl != null && widget.networkUrl!.isNotEmpty) {
        _controller =
            VideoPlayerController.networkUrl(Uri.parse(widget.networkUrl!));
      } else {
        setState(() => _hasError = true);
        return;
      }

      await _controller!.initialize();
      if (!mounted) return;

      _controller!.addListener(_onControllerUpdate);
      setState(() {
        _isInitialized = true;
      });

      if (widget.autoPlay) {
        _controller!.play();
        _startHideTimer();
      }
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _disposePlayer() {
    _hideTimer?.cancel();
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _hasError = false;
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      _hideTimer?.cancel();
      setState(() => _showControls = true);
    } else {
      _controller!.play();
      setState(() => _showControls = true);
      _startHideTimer();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller != null && _controller!.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _onTapVideo() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls &&
        _controller != null &&
        _controller!.value.isPlaying) {
      _startHideTimer();
    }
  }

  void _openFullscreen() {
    if (_controller == null || !_isInitialized) return;
    final wasPlaying = _controller!.value.isPlaying;
    _controller!.pause();

    Navigator.push<Duration>(
      context,
      MaterialPageRoute(
        builder: (ctx) => FullscreenVideoViewer(
          localPath: widget.localPath,
          networkUrl: widget.networkUrl,
          initialPosition: _controller!.value.position,
        ),
      ),
    ).then((returnedPos) {
      if (returnedPos != null && mounted && _controller != null) {
        _controller!.seekTo(returnedPos);
        if (wasPlaying) _controller!.play();
      }
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: AppColors.textNearBlack,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 36, color: Colors.white70),
              SizedBox(height: 8),
              Text(
                'Không thể tải video',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: AppColors.textPrimary,
        child: const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenPrimary),
            ),
          ),
        ),
      );
    }

    final value = _controller!.value;
    final duration = value.duration;
    final position = value.position;
    final isPlaying = value.isPlaying;

    return GestureDetector(
      onTap: _onTapVideo,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Video Surface
            Center(
              child: AspectRatio(
                aspectRatio: value.aspectRatio > 0 ? value.aspectRatio : 16 / 9,
                child: VideoPlayer(_controller!),
              ),
            ),

            // 2. Lớp phủ Controls (khi _showControls == true hoặc video đang pause)
            AnimatedOpacity(
              opacity: _showControls || !isPlaying ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: Stack(
                  children: [
                    // Nút Play / Pause lớn ở chính giữa
                    Center(
                      child: InkWell(
                        onTap: _togglePlayPause,
                        borderRadius: BorderRadius.circular(35),
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: AppColors.greenPrimary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.greenPrimary
                                    .withValues(alpha: 0.45),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Thanh điều khiển phía dưới: Thời gian + Thanh kéo tiến trình + Nút Phóng to
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 8,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Slider tiến trình
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3.5,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 12),
                              activeTrackColor: AppColors.greenPrimary,
                              inactiveTrackColor: Colors.white30,
                              thumbColor: Colors.white,
                            ),
                            child: Slider(
                              value: position.inMilliseconds
                                  .clamp(0, duration.inMilliseconds)
                                  .toDouble(),
                              max: duration.inMilliseconds > 0
                                  ? duration.inMilliseconds.toDouble()
                                  : 1.0,
                              onChanged: (val) {
                                _hideTimer?.cancel();
                                _controller?.seekTo(
                                    Duration(milliseconds: val.toInt()));
                              },
                              onChangeEnd: (_) {
                                if (isPlaying) _startHideTimer();
                              },
                            ),
                          ),
                          // Hàng dưới: Thời lượng và nút phóng to toàn màn hình
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: [
                                Text(
                                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                // Nút Phóng to toàn màn hình (Fullscreen)
                                InkWell(
                                  onTap: _openFullscreen,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.fullscreen_rounded,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'Phóng to',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 2),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Badge loại tệp góc trái trên
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam, size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      widget.badgeLabel ?? 'Video',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Nút [X] Xóa video góc phải trên (nếu có callback onRemove)
            if (widget.onRemove != null)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onRemove,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
