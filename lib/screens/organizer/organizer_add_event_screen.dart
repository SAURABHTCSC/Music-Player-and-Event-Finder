import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // ✅ Import for Date Formatting

class OrganizerAddEventScreen extends StatefulWidget {
  final Map<String, dynamic>? existingEvent;
  const OrganizerAddEventScreen({super.key, this.existingEvent});

  @override
  State<OrganizerAddEventScreen> createState() => _OrganizerAddEventScreenState();
}

class _OrganizerAddEventScreenState extends State<OrganizerAddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(); // ✅ NEW Date Controller
  final _pincodeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _seatsCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // Media Controllers
  final _img1Ctrl = TextEditingController();
  final _img2Ctrl = TextEditingController();
  final _vidCtrl = TextEditingController();

  bool _isEdit = false;
  bool _isLoading = false;
  DateTime? _selectedDate; // ✅ Store the Date Object

  @override
  void initState() {
    super.initState();
    if (widget.existingEvent != null) {
      _isEdit = true;
      _populateData();
    }
  }

  void _populateData() {
    final e = widget.existingEvent!;
    _nameCtrl.text = e['event_name'];
    _typeCtrl.text = e['event_type'];
    _pincodeCtrl.text = e['pincode'];
    _priceCtrl.text = e['ticket_price'].toString();
    _addressCtrl.text = e['location_address'];
    _seatsCtrl.text = e['total_seats'].toString();
    _descCtrl.text = e['description'];

    // ✅ Populate Date
    if (e['event_date'] != null) {
      _selectedDate = DateTime.parse(e['event_date']);
      _dateCtrl.text = DateFormat('dd MMM yyyy').format(_selectedDate!);
    }

    List imgs = e['image_urls'] ?? [];
    if (imgs.isNotEmpty) _img1Ctrl.text = imgs[0];
    if (imgs.length > 1) _img2Ctrl.text = imgs[1];
    _vidCtrl.text = e['video_url'] ?? "";
  }

  // ✅ Date Picker Function
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Cannot pick past dates
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF), // Purple header
              onPrimary: Colors.white,
              surface: Color(0xFF2C2C3E), // Dark background
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select an Event Date")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw "Please login again.";

      // Collect Images
      List<String> images = [];
      if (_img1Ctrl.text.isNotEmpty) images.add(_img1Ctrl.text);
      if (_img2Ctrl.text.isNotEmpty) images.add(_img2Ctrl.text);

      final eventData = {
        'event_name': _nameCtrl.text,
        'event_type': _typeCtrl.text,
        'event_date': _selectedDate!.toIso8601String(), // ✅ Save Selected Date
        'pincode': _pincodeCtrl.text,
        'ticket_price': double.parse(_priceCtrl.text),
        'location_address': _addressCtrl.text,
        'total_seats': int.parse(_seatsCtrl.text),
        'description': _descCtrl.text,
        'image_urls': images,
        'video_url': _vidCtrl.text,
        'creator_id': user.id,
      };

      if (_isEdit) {
        // UPDATE
        await Supabase.instance.client
            .from('events')
            .update(eventData) // Updates all fields including date
            .eq('id', widget.existingEvent!['id']);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event Updated Successfully!")));
      } else {
        // INSERT
        eventData['available_seats'] = int.parse(_seatsCtrl.text);
        eventData['status'] = 'pending';
        eventData['revenue_generated'] = 0;

        // ✅ FIX: Start with 100 Likes automatically
        eventData['likes_count'] = 100;

        await Supabase.instance.client.from('events').insert(eventData);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Event Requested!")));
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text(_isEdit ? "Edit Event" : "Create New Event",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader("Basic Info"),
              _buildDarkInput("Event Name", _nameCtrl, Icons.event_note),

              // ✅ Date Picker Field
              _buildDarkInput(
                  "Event Date",
                  _dateCtrl,
                  Icons.calendar_month,
                  isReadOnly: true,
                  onTap: _pickDate,
                  hint: "Select Date"
              ),

              _buildDarkInput("Event Type", _typeCtrl, Icons.category, hint: "e.g. DJ Night"),

              Row(
                children: [
                  Expanded(child: _buildDarkInput("Pincode", _pincodeCtrl, Icons.location_on)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildDarkInput("Price (₹)", _priceCtrl, Icons.currency_rupee, isNumber: true)),
                ],
              ),

              _buildDarkInput("Exact Location Address", _addressCtrl, Icons.map),
              _buildDarkInput("Total Seats", _seatsCtrl, Icons.event_seat, isNumber: true),

              const SizedBox(height: 15),
              _sectionHeader("Description"),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Event Description",
                  alignLabelWithHint: true,
                  hintText: "Write details here...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  labelStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: const Color(0xFF2C2C3E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (val) => val!.isEmpty ? "Description required" : null,
              ),

              const SizedBox(height: 20),
              _sectionHeader("Media Links (Optional)"),
              _buildDarkInput("Image URL 1", _img1Ctrl, Icons.image, hint: "Banner Image"),
              _buildDarkInput("Image URL 2", _img2Ctrl, Icons.image),
              _buildDarkInput("Video URL (< 30s)", _vidCtrl, Icons.play_circle_fill),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  onPressed: _isLoading ? null : _saveEvent,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isEdit ? Icons.save : Icons.send, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                          _isEdit ? "Update Changes" : "Submit Request",
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 5),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF6C63FF))),
    );
  }

  Widget _buildDarkInput(String label, TextEditingController ctrl, IconData icon, {bool isNumber = false, String? hint, bool isReadOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        readOnly: isReadOnly, // ✅ Makes Date field uneditable by text
        onTap: onTap,         // ✅ Opens picker on tap
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF2C2C3E),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          labelStyle: const TextStyle(color: Colors.white60),
          hintStyle: const TextStyle(color: Colors.white24),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (val) => val!.isEmpty ? "$label is required" : null,
      ),
    );
  }
}