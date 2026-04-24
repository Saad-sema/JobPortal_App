import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  // ---------------- LOAD STATS ----------------
  Future<Map<String, int>> _loadStats() async {
    final usersSnap =
    await FirebaseFirestore.instance.collection('users').get();
    final jobsSnap =
    await FirebaseFirestore.instance.collection('jobs').get();
    final appsSnap =
    await FirebaseFirestore.instance.collection('applications').get();

    int seekers = 0;
    int employers = 0;

    for (var doc in usersSnap.docs) {
      if (doc['role'] == 'seeker') seekers++;
      if (doc['role'] == 'employer') employers++;
    }

    return {
      'users': usersSnap.docs.length,
      'seekers': seekers,     // backend same
      'employers': employers, // backend same
      'jobs': jobsSnap.docs.length,
      'applications': appsSnap.docs.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _loadStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- KPI CARDS ----------------
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _kpiCard('Total Users', data['users']!, Colors.blueAccent),
                  _kpiCard(
                      'Candidates', data['seekers']!, Colors.greenAccent),
                  _kpiCard(
                      'Companies', data['employers']!, Colors.orangeAccent),
                  _kpiCard('Jobs', data['jobs']!, Colors.purpleAccent),
                  _kpiCard(
                      'Applications', data['applications']!, Colors.redAccent),
                ],
              ),

              const SizedBox(height: 28),

              // ---------------- TITLE ----------------
              const Text(
                'Platform Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 16),

              // ---------------- CHART ----------------
              _glassChart(
                seekers: data['seekers']!,
                employers: data['employers']!,
                jobs: data['jobs']!,
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= KPI CARD =================
  Widget _kpiCard(String title, int value, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= GLASS CHART =================
  Widget _glassChart({
    required int seekers,
    required int employers,
    required int jobs,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          child: BarChart(
            BarChartData(
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text(
                            'Candidates',
                            style: TextStyle(color: Colors.white54),
                          );
                        case 1:
                          return const Text(
                            'Companies',
                            style: TextStyle(color: Colors.white54),
                          );
                        case 2:
                          return const Text(
                            'Jobs',
                            style: TextStyle(color: Colors.white54),
                          );
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
              ),
              barGroups: [
                _bar(0, seekers.toDouble(), Colors.greenAccent),
                _bar(1, employers.toDouble(), Colors.orangeAccent),
                _bar(2, jobs.toDouble(), Colors.blueAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= BAR =================
  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 22,
          borderRadius: BorderRadius.circular(8),
          color: color,
        ),
      ],
    );
  }
}
