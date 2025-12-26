import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/event_model.dart';
import '../book_ticket_screen.dart';
import '../../organizer/organizer_auth_screen.dart';

class EventPostCard extends StatefulWidget {
  final EventModel event;
  const EventPostCard({super.key, required this.event});

  @override
  State<EventPostCard> createState() => _EventPostCardState();
}

class _EventPostCardState extends State<EventPostCard> {
  bool isExpanded = false;

  // ✅ Like State
  bool isLiked = false;
  int likeCount = 0;

  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  VideoPlayerController? _postVideoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    // 1. Load initial likes from the event data (starts at 100 for new events)
    likeCount = widget.event.likesCount;

    // 2. Check if THIS specific user has already liked this event
    _checkIfUserLiked();

    // Video Setup
    if (widget.event.videoUrl != null && widget.event.videoUrl!.isNotEmpty) {
      _postVideoController = VideoPlayerController.networkUrl(Uri.parse(widget.event.videoUrl!))
        ..initialize().then((_) {
          if (mounted) {
            setState(() => _isVideoInitialized = true);
            _postVideoController!.setLooping(true);
            _postVideoController!.setVolume(0);
            _postVideoController!.play();
          }
        });
    }
  }

  @override
  void dispose() {
    _postVideoController?.dispose();
    super.dispose();
  }

  // ✅ Check Database: Did I like this before?
  Future<void> _checkIfUserLiked() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final data = await Supabase.instance.client
          .from('event_likes')
          .select()
          .eq('user_id', user.id)
          .eq('event_id', widget.event.id)
          .maybeSingle();

      if (mounted && data != null) {
        setState(() => isLiked = true);
      }
    }
  }

  bool _checkLogin() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Please login to perform this action!"),
            backgroundColor: Colors.redAccent,
            action: SnackBarAction(
                label: "Login",
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const OrganizerAuthScreen()));
                }
            ),
          )
      );
      return false;
    }
    return true;
  }

  // ✅ GLOBAL LIKE LOGIC
  Future<void> _toggleLike() async {
    if (!_checkLogin()) return;

    final user = Supabase.instance.client.auth.currentUser!;

    // 1. Optimistic Update (Update UI Instantly)
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        likeCount++; // e.g., 100 -> 101
      } else {
        likeCount--; // e.g., 101 -> 100
      }
    });

    try {
      if (isLiked) {
        // A. Add to 'event_likes' table (User X liked Event Y)
        await Supabase.instance.client.from('event_likes').insert({
          'user_id': user.id,
          'event_id': widget.event.id
        });
        // B. Call SQL Function to update global count safely
        await Supabase.instance.client.rpc('increment_likes', params: {'row_id': widget.event.id});
      } else {
        // A. Remove from 'event_likes' table
        await Supabase.instance.client.from('event_likes').delete()
            .eq('user_id', user.id)
            .eq('event_id', widget.event.id);
        // B. Decrement global count
        await Supabase.instance.client.rpc('decrement_likes', params: {'row_id': widget.event.id});
      }
    } catch (e) {
      // Revert if error
      setState(() {
        isLiked = !isLiked;
        likeCount += isLiked ? 1 : -1;
      });
      print("Error liking: $e");
    }
  }

  Future<void> _openMap() async {
    final query = Uri.encodeComponent(widget.event.locationAddress);
    final googleUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.event.eventName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.blue),
                title: const Text("Open in Maps", style: TextStyle(color: Colors.white)),
                onTap: () { Navigator.pop(context); _openMap(); },
              ),
              ListTile(
                leading: const Icon(Icons.flag, color: Colors.red),
                title: const Text("Report Event", style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d MMM yyyy').format(widget.event.eventDate);
    final priceTag = widget.event.ticketPrice == 0 ? "Free" : "₹ ${widget.event.ticketPrice.toInt()}";

    // Media List Logic
    List<Widget> mediaWidgets = widget.event.imageUrls
        .map<Widget>((url) => Image.network(url, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey[900], child: const Icon(Icons.broken_image, color: Colors.white))))
        .toList();

    if (_postVideoController != null) {
      mediaWidgets.add(
          _isVideoInitialized
              ? GestureDetector(
            onTap: () {
              setState(() {
                _postVideoController!.value.isPlaying
                    ? _postVideoController!.pause()
                    : _postVideoController!.play();
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(aspectRatio: _postVideoController!.value.aspectRatio, child: VideoPlayer(_postVideoController!)),
                if (!_postVideoController!.value.isPlaying)
                  const Icon(Icons.play_circle_fill, color: Colors.white54, size: 60),
              ],
            ),
          )
              : const Center(child: CircularProgressIndicator(color: Colors.white))
      );
    }

    if (mediaWidgets.isEmpty) {
      mediaWidgets.add(Container(color: Colors.grey[900], child: const Icon(Icons.event, color: Colors.white, size: 50)));
    }

    return Container(
      color: Colors.black,
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: (widget.event.imageUrls.isNotEmpty)
                      ? NetworkImage(widget.event.imageUrls[0])
                      : const AssetImage('assets/profile.png') as ImageProvider,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.event.eventName, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 12),
                          const SizedBox(width: 4),
                          Expanded(child: Text(widget.event.locationAddress, style: const TextStyle(color: Colors.white70, fontSize: 11), overflow: TextOverflow.ellipsis, maxLines: 1)),
                          const SizedBox(width: 10),
                          const Icon(Icons.calendar_month, color: Colors.white70, size: 12),
                          const SizedBox(width: 4),
                          Text(formattedDate, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: _showMoreOptions)
              ],
            ),
          ),

          // Content
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentImageIndex = index),
                  children: mediaWidgets,
                ),
                if (mediaWidgets.length > 1)
                  Positioned(
                    top: 10, right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)),
                      child: Text("${_currentImageIndex + 1}/${mediaWidgets.length}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                // LIKE BUTTON
                InkWell(
                  onTap: _toggleLike,
                  child: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () => Share.share("Join me at ${widget.event.eventName} on $formattedDate!"),
                  child: const Icon(Icons.share, color: Colors.white, size: 26),
                ),
                const Spacer(),
                InkWell(
                  onTap: _openMap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.directions, color: Colors.blueAccent, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    if (_checkLogin()) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => BookTicketScreen(event: widget.event)));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4834DF)]),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: const Text("Book Ticket", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          // Footer (Likes Count & Desc)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ DISPLAY DYNAMIC LIKE COUNT
                    Text("$likeCount likes", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(priceTag, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() => isExpanded = !isExpanded),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                      children: [
                        TextSpan(text: "${widget.event.eventName} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: isExpanded ? widget.event.description : (widget.event.description.length > 80 ? "${widget.event.description.substring(0, 80)}..." : widget.event.description), style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}