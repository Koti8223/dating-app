import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/phone_login_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  
  String _selectedGender = 'Male';
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF4D6D),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _completeProfile() async {
    String name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your birthday')),
      );
      return;
    }

    if (_user == null) return;

    setState(() => _isLoading = true);

    try {
      // Write user details to Firestore
      await _firestore.collection('users').doc(_user.uid).set({
        'uid': _user.uid,
        'phoneNumber': _user.phoneNumber,
        'name': name,
        'gender': _selectedGender,
        'birthday': _selectedDate!.toIso8601String(),
        'coins': 100, // 100 free coins on signup!
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Navigate to Home screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PlaceholderHomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              Text(
                'Almost There!',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF4D6D),
                ),
              ),
              Text(
                'Set up your profile to start matchmaking',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey[500],
                ),
              ),

              const SizedBox(height: 50),

              // Full name input
              Text(
                'Full Name',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: GoogleFonts.poppins(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF4D6D), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(18),
                ),
              ),

              const SizedBox(height: 30),

              // Gender choice
              Text(
                'Gender',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: ['Male', 'Female', 'Other'].map((gender) {
                  bool isSelected = _selectedGender == gender;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            gender,
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFF4D6D),
                        backgroundColor: Colors.grey[100],
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedGender = gender);
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // Birthday choice
              Text(
                'Birthday',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Select your birthday'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: _selectedDate == null ? Colors.grey[400] : Colors.black,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Color(0xFFFF4D6D)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D6D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Complete Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Temporary Placeholder Home Screen
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('FRND 💕', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFFFF4D6D))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🎉 Matchmaking Home!',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFFFF4D6D)),
            ),
            const SizedBox(height: 10),
            Text(
              'Welcome to your customized dating feed.',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
