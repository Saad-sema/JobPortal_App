import 'dart:math';
import 'package:flutter/material.dart';

/// 🔐 Shown when an unverified employer tries to post a job.
class VerificationPendingScreen extends StatefulWidget {
  const VerificationPendingScreen({super.key});

  @override
  State<VerificationPendingScreen> createState() =>
      _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends State<VerificationPendingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E1A),
              Color(0xFF0F1729),
              Color(0xFF1A1F38),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ---------- ANIMATED ICON ----------
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) {
                    return Transform.scale(
                      scale: _pulseAnim.value,
                      child: _buildIconRings(),
                    );
                  },
                ),

                const SizedBox(height: 44),

                // ---------- HEADLINE ----------
                const Text(
                  'Verification Pending',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  'Your company account is awaiting admin verification.\nOnce approved, you can post jobs and start hiring.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.55),
                    height: 1.65,
                    letterSpacing: 0.1,
                  ),
                ),

                const SizedBox(height: 40),

                // ---------- STATUS STEPS ----------
                _buildStatusSteps(),

                const SizedBox(height: 40),

                // ---------- INFO CARD ----------
                _buildInfoCard(),

                const SizedBox(height: 32),

                // ---------- GO BACK BUTTON ----------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
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

  // ─────────────────── ICON RINGS ───────────────────
  Widget _buildIconRings() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF59E0B).withOpacity(0.06),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.15),
                width: 1.5,
              ),
            ),
          ),
          // Middle ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF59E0B).withOpacity(0.10),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.25),
                width: 1.5,
              ),
            ),
          ),
          // Inner circle
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withOpacity(0.45),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── STATUS STEPS ───────────────────
  Widget _buildStatusSteps() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          _step(
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF10B981),
            title: 'Account Created',
            subtitle: 'Your company account is registered.',
            done: true,
          ),
          _stepDivider(),
          _step(
            icon: Icons.hourglass_top_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'Admin Review',
            subtitle: 'Our team is reviewing your account.',
            done: false,
            active: true,
          ),
          _stepDivider(),
          _step(
            icon: Icons.rocket_launch_rounded,
            iconColor: const Color(0xFF64748B),
            title: 'Start Posting Jobs',
            subtitle: 'You\'re ready to hire once verified.',
            done: false,
          ),
        ],
      ),
    );
  }

  Widget _step({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool done,
    bool active = false,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withOpacity(active ? 0.18 : 0.10),
            border: Border.all(
              color: iconColor.withOpacity(active ? 0.5 : 0.2),
            ),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : Colors.white.withOpacity(0.6),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (done)
          const Icon(
            Icons.check_rounded,
            color: Color(0xFF10B981),
            size: 18,
          ),
        if (active)
          _PulsingDot(),
      ],
    );
  }

  Widget _stepDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 21, top: 6, bottom: 6),
      child: Container(
        width: 1.5,
        height: 20,
        color: Colors.white.withOpacity(0.1),
      ),
    );
  }

  // ─────────────────── INFO CARD ───────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF59E0B).withOpacity(0.06),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: const Color(0xFFF59E0B),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Verification typically takes 24–48 hours. Make sure your company profile is complete to speed up the process.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.65),
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small animated pulsing dot for the active step
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _a = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) => Opacity(
        opacity: _a.value,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF59E0B),
          ),
        ),
      ),
    );
  }
}
