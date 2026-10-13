import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:spei_community/src/core/constants/app_colors.dart';

/// Màn hình xem video toàn màn hình (Fullscreen) phong cách Facebook / Reels
/// Hỗ trợ: Play/Pause, Tua ±10s, Thanh tiến trình, Phóng to 2 ngón tay (Pinch to zoom), Vuốt xuống để đóng
class FullscreenVideoViewer extends StatefulWidget {
  final String? localPath;
  final String? networkUrl;
  final Duration initialPosition;

  const FullscreenVideoViewer({
    super.key,
    this.localPath,
    this.networkUrl,
    this.initialPosition = Duration.zero,
  });

  @override
  State<FullscreenVideoViewer> createState() => _FullscreenVideoViewerState();
}

class _FullscreenVideoViewerState extends State<FullscreenVideoViewer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  bool _isMuted = false;
  Timer? _hideTimer;

  // Hỗ trợ cử chỉ kéo xuống để đóng (Swipe down to dismiss)
  double _dragOffsetY = 0.0;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
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

      await _controller.initialize();
      if (!mounted) return;

      if (widget.initialPosition > Duration.zero) {
        await _controller.seekTo(widget.initialPosition);
      }

      _controller.addListener(_listener);
      setState(() {
        _isInitialized = true;
      });

      _controller.play();
      _startHideTimer();
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!_isInitialized) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
      _hideTimer?.cancel();
      setState(() => _showControls = true);
    } else {
      _controller.play();
      setState(() => _showControls = true);
      _startHideTimer();
    }
  }

  void _seekRelative(int seconds) {
    if (!_isInitialized) return;
    final current = _controller.value.position;
    final target = current + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > _controller.value.duration
            ? _controller.value.duration
            : target);
    _controller.seekTo(clamped);
    _startHideTimer();
  }

  void _toggleMute() {
    if (!_isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _onScreenTap() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls && _controller.value.isPlaying) {
      _startHideTimer();
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _closeViewer() {
    final pos = _isInitialized ? _controller.value.position : Duration.zero;
    Navigator.pop(context, pos);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text(
            'Không thể phát video',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.greenPrimary),
          ),
        ),
      );
    }

    final value = _controller.value;
    final duration = value.duration;
    final position = value.position;
    final isPlaying = value.isPlaying;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _closeViewer();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _onScreenTap,
          onVerticalDragUpdate: (details) {
            // Kéo xuống để đóng
            if (details.delta.dy > 0 || _dragOffsetY > 0) {
              setState(() {
                _dragOffsetY += details.delta.dy;
              });
            }
          },
          onVerticalDragEnd: (details) {
            if (_dragOffsetY > 120 || details.primaryVelocity! > 600) {
              _closeViewer();
            } else {
              setState(() => _dragOffsetY = 0.0);
            }
          },
          child: Transform.translate(
            offset: Offset(0, _dragOffsetY),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Khung phát video với InteractiveViewer (cho phép dùng 2 ngón tay phóng to thu nhỏ video)
                InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: value.aspectRatio > 0
                          ? value.aspectRatio
                          : 16 / 9,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),

                // 2. Lớp phủ Controls
                AnimatedOpacity(
                  opacity: _showControls || !isPlaying ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Thanh điều khiển trên cùng
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: _closeViewer,
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.white, size: 26),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Video minh chứng',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                // Nút Bật / Tắt âm thanh
                                IconButton(
                                  onPressed: _toggleMute,
                                  icon: Icon(
                                    _isMuted
                                        ? Icons.volume_off_rounded
                                        : Icons.volume_up_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Cụm nút giữa màn hình: Tua lại 10s, Play/Pause, Tua tới 10s
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                iconSize: 42,
                                onPressed: () => _seekRelative(-10),
                                icon: const Icon(Icons.replay_10_rounded,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 28),
                              InkWell(
                                onTap: _togglePlayPause,
                                borderRadius: BorderRadius.circular(40),
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.greenPrimary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.greenPrimary
                                            .withValues(alpha: 0.5),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 46,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 28),
                              IconButton(
                                iconSize: 42,
                                onPressed: () => _seekRelative(10),
                                icon: const Icon(Icons.forward_10_rounded,
                                    color: Colors.white),
                              ),
                            ],
                          ),

                          // Thanh điều khiển dưới cùng: Thanh tua tiến trình + Thời gian
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    thumbShape:
                                        const RoundSliderThumbShape(
                                            enabledThumbRadius: 7),
                                    overlayShape:
                                        const RoundSliderOverlayShape(
                                            overlayRadius: 14),
                                    activeTrackColor:
                                        AppColors.greenPrimary,
                                    inactiveTrackColor: Colors.white38,
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
                                      _controller.seekTo(Duration(
                                          milliseconds: val.toInt()));
                                    },
                                    onChangeEnd: (_) {
                                      if (isPlaying) _startHideTimer();
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(position),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(duration),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
