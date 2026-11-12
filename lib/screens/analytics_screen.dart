import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/list_provider.dart';
import '../widgets/calley_bottom_nav.dart';
import '../widgets/calley_button.dart';
import '../widgets/donut_chart.dart';
import 'drawer_navigation.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _currentNavIndex = 3;

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/profile-settings');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/dialer');
    } else if (index == 3) {
      setState(() => _currentNavIndex = 3);
    } else if (index == 4) {
      Navigator.pushNamed(context, '/profile-settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final listProvider = context.watch<ListProvider>();
    final selectedList = listProvider.selectedList;

    final total = selectedList?.totalContacts ?? 50;
    final pending = selectedList?.pendingContacts ?? 28;
    final done = selectedList?.calledContacts ?? 22;
    final scheduled = selectedList?.scheduledContacts ?? 9;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
      drawer: const CalleyNavigationDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.textDark),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined,
                color: AppColors.textLight, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.sync_rounded,
                color: AppColors.textLight, size: 20),
            onPressed: () {
              listProvider.fetchLists();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  // 1. Test Limit Header Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TEST LIMIT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$total ',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'CALLS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'S',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Interactive Donut Chart
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Call Outcomes Breakdown',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CalleyDonutChart(
                          pending: pending,
                          done: done,
                          schedule: scheduled,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Metric Outcome Badges
                  Row(
                    children: [
                      // Pending
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Pending',
                          count: pending,
                          color: const Color(0xFFF59E0B),
                          bg: const Color(0xFFFFFBEB),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Done
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Done',
                          count: done,
                          color: const Color(0xFF10B981),
                          bg: const Color(0xFFECFDF5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Schedule
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Schedule',
                          count: scheduled,
                          color: const Color(0xFF8B5CF6),
                          bg: const Color(0xFFF5F3FF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Bottom CTA
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: CalleyButton(
                  text: 'Start Calling Now',
                  onPressed: () {
                    Navigator.pushNamed(context, '/dialer');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CalleyBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    ),
  );
}

  Widget _buildMetricCard({
    required String title,
    required int count,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: count.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const TextSpan(
                  text: ' Calls',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.textLight,
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
