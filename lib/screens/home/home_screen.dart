import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../widgets/profile_card.dart';
import '../../constants/app_colors.dart';
import '../chat/chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<UserModel> _users = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _firestoreService.getUsersForFeed();
    setState(() {
      _users = users;
      _currentIndex = 0;
      _isLoading = false;
    });
  }

  void _onLike() async {
    if (_currentIndex >= _users.length) return;
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    await _firestoreService.likeUser(
      currentUid: currentUid,
      likedUid: _users[_currentIndex].uid,
    );
    _nextUser();
  }

  void _onSkip() async {
    if (_currentIndex >= _users.length) return;
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    await _firestoreService.skipUser(
      currentUid: currentUid,
      skippedUid: _users[_currentIndex].uid,
    );
    _nextUser();
  }

  void _nextUser() {
    setState(() {
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FRND 💕',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Row(
                    children: [
                      // Coins display
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '20',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Notification icon
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        color: AppColors.darkGrey,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: _bottomNavIndex == 2
                  ? const ChatListScreen()
                  : _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : _users.isEmpty
                          ? _buildEmptyState()
                          : _currentIndex >= _users.length
                              ? _buildNoMoreUsers()
                              : ProfileCard(
                                  user: _users[_currentIndex],
                                  onLike: _onLike,
                                  onSkip: _onSkip,
                                ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic_outlined),
            activeIcon: Icon(Icons.mic),
            label: 'Voice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😔', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'No users found yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first one here!\nInvite your friends',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                await _firestoreService.seedTestUsers();
                await _loadUsers();
              } catch (e) {
                if (!mounted) return;
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Seeding failed: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Seed Test Profiles',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoreUsers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'You\'ve seen everyone!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new people',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadUsers,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 14),
            ),
            child: Text(
              'Refresh',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
