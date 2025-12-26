import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/event_model.dart';
import '../../event_details_screen.dart'; // ✅ Import Event Details

class StoryViewScreen extends StatefulWidget {
  final EventModel event;
  const StoryViewScreen({super.key, required this.event});

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  VideoPlayerController? _videoController;

  int _currentIndex = 0;
  List<String> _mediaItems = [];
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(vsync: this);

    _mediaItems.addAll(widget.event.imageUrls);
    if (widget.event.videoUrl != null && widget.event.videoUrl!.isNotEmpty) {
      _mediaItems.add(widget.event.videoUrl!);
    }

    _loadStory(0);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });
  }

  void _loadStory(int index) {
    if (index >= _mediaItems.length) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _currentIndex = index;
      bool hasVideo = widget.event.videoUrl != null && widget.event.videoUrl!.isNotEmpty;
      _isVideo = hasVideo && (index == _mediaItems.length - 1) && widget.event.imageUrls.length < _mediaItems.length;
    });

    _videoController?.dispose();
    _videoController = null;
    _animController.stop();
    _animController.reset();

    if (_isVideo) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(_mediaItems[index]))
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
          _animController.duration = _videoController!.value.duration;
          _animController.forward();
        });
    } else {
      _animController.duration = const Duration(seconds: 5);
      _animController.forward();
    }

    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }
  }

  void _nextStory() {
    if (_currentIndex < _mediaItems.length - 1) {
      _loadStory(_currentIndex + 1);
    } else {
      Navigator.pop(context);
    }
  }

  // ✅ New Logic: Redirect to Post
  void _goToPost() {
    // Close story first
    Navigator.pop(context);
    // Navigate to Event Details (Post Page)
    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailsScreen(event: widget.event))
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTapUp: (details) {
            final width = MediaQuery.of(context).size.width;
            if (details.globalPosition.dx < width / 3) {
              if (_currentIndex > 0) _loadStory(_currentIndex - 1);
            } else {
              _nextStory();
            }
          },
          child: Stack(
            children: [
              // 1. Content Player
              PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mediaItems.length,
                itemBuilder: (context, index) {
                  if (_isVideo && _videoController != null && _videoController!.value.isInitialized) {
                    return Center(
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    );
                  } else if (_isVideo) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  } else {
                    return Image.network(_mediaItems[index], fit: BoxFit.contain,
                      loadingBuilder: (ctx, child, prog) => prog == null ? child : const Center(child: CircularProgressIndicator(color: Colors.white)),
                    );
                  }
                },
              ),

              // 2. Top Progress Bars
              Positioned(
                top: 10, left: 10, right: 10,
                child: Row(
                  children: List.generate(_mediaItems.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            double value = 0.0;
                            if (index < _currentIndex) {
                              value = 1.0;
                            } else if (index == _currentIndex) {
                              value = _animController.value;
                            }
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 3,
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // 3. Header: Avatar + Close Button
              Positioned(
                top: 25, left: 15, right: 15,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.event.imageUrls.isNotEmpty ? widget.event.imageUrls[0] : ''),
                      radius: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(widget.event.eventName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const Spacer(),
                    // ✅ Close Button
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),

              // 4. "See Post" Link at Bottom
              Positioned(
                bottom: 30, left: 0, right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _goToPost,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("View Event Details", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 5),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12)
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}