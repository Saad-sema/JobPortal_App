import 'dart:ui';
import 'package:flutter/material.dart';

import 'seeker_jobs_screen.dart';
import 'seeker_applications_screen.dart';
import '../chat/chat_list_screen.dart';
import '../search/user_search_screen.dart';
import '../profile/profile_screen.dart';

class SeekerDashboard extends StatefulWidget {
  const SeekerDashboard({super.key});

  @override
  State<SeekerDashboard> createState() => _SeekerDashboardState();
}

class _SeekerDashboardState extends State<SeekerDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    SeekerJobsScreen(),          // Jobs
    SeekerApplicationsScreen(),  // Applications
    ChatListScreen(),            // Chats
    UserSearchScreen(),          // Search Users
    ProfileScreen(),             // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),

      /// 🎨 ENHANCED APP BAR


      /// 📄 BODY - FIXED OVERFLOW
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E1A),
              Color(0xFF1A1F38),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false, // Don't cut off bottom
          child: _pages[_currentIndex],
        ),
      ),

      /// 🎯 ENHANCED BOTTOM NAVIGATION BAR
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 25,
                spreadRadius: 0,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.only(
                  bottom: 8, // Extra padding for bottom
                ),
                height: 80,
                color: Colors.white.withOpacity(0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.work_outline_rounded,
                      activeIcon: Icons.work_rounded,
                      label: 'Jobs',
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.assignment_outlined,
                      activeIcon: Icons.assignment_rounded,
                      label: 'Applications',
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.chat_bubble_outline_rounded,
                      activeIcon: Icons.chat_bubble_rounded,
                      label: 'Chats',
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: Icons.search_rounded,
                      activeIcon: Icons.search_rounded,
                      label: 'Search',
                    ),
                    _buildNavItem(
                      index: 4,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 CUSTOM NAVIGATION ITEM
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Reduced padding
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isActive
                ? const LinearGradient(
              colors: [
                Color(0xFF2563EB),
                Color(0xFF3B82F6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            boxShadow: isActive
                ? [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(4), // Reduced padding
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? Colors.white : const Color(0xFF94A3B8),
                  size: 20, // Reduced size
                ),
              ),
              const SizedBox(height: 2), // Reduced spacing
              Text(
                label,
                style: TextStyle(
                  fontSize: 10, // Reduced font size
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.white : const Color(0xFF94A3B8),
                  letterSpacing: isActive ? 0.3 : 0.2,
                ),
              ),
              if (isActive)
                Container(
                  margin: const EdgeInsets.only(top: 2), // Reduced margin
                  width: 3, // Reduced size
                  height: 3, // Reduced size
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}