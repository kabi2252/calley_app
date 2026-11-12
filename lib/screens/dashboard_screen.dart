import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/api_constants.dart';
import '../constants/app_colors.dart';
import '../providers/list_provider.dart';
import '../widgets/calley_bottom_nav.dart';
import '../widgets/calley_button.dart';
import 'drawer_navigation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;

    if (index == 0) {
      // Home
      setState(() => _currentNavIndex = 0);
    } else if (index == 1) {
      // Calling Lists Modal / Profile Settings Screen
      Navigator.pushNamed(context, '/profile-settings');
    } else if (index == 2) {
      // Start Calling / Dialer
      Navigator.pushNamed(context, '/dialer');
    } else if (index == 3) {
      // Analytics Donut Chart Screen
      Navigator.pushNamed(context, '/analytics');
    } else if (index == 4) {
      // Settings
      Navigator.pushNamed(context, '/profile-settings');
    }
  }

  Future<void> _launchWebPanel() async {
    final uri = Uri.parse(ApiConstants.calleyWebPanelUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/landing');
        }
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Support line connected: support@getcalley.com'),
                  backgroundColor: AppColors.primaryBlue,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync_rounded,
                color: AppColors.textLight, size: 20),
            onPressed: () {
              context.read<ListProvider>().fetchLists();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Syncing call lists from server...'),
                  backgroundColor: AppColors.primaryBlue,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              // 1. Welcome Header Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.amber[400],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Text('👩', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello Swati!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Welcome to Calley!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. LOAD NUMBER TO CALL Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Dark Blue Header Bar
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E293B),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(17)),
                        ),
                        child: const Text(
                          'LOAD NUMBER TO CALL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Card Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                    height: 1.45,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Visit '),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: _launchWebPanel,
                                        child: const Text(
                                          'https://app.getcalley.com',
                                          style: TextStyle(
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.w700,
                                            decoration: TextDecoration.underline,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          ' to upload numbers that you wish to call using Calley Mobile Apps.',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Vector Illustration
                              Container(
                                width: double.infinity,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F9FF),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Desk & Devices vector illustration
                                    Icon(
                                      Icons.phone_in_talk_rounded,
                                      size: 72,
                                      color: AppColors.primaryBlue.withOpacity(0.7),
                                    ),
                                    Positioned(
                                      bottom: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                            )
                                          ],
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.cloud_upload_outlined,
                                                size: 15,
                                                color: AppColors.primaryBlue),
                                            SizedBox(width: 6),
                                            Text(
                                              'Web Panel Sync Active',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 3. Start Calling Action
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chat_bubble_rounded,
                          color: Colors.white, size: 22),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('WhatsApp dialing channel initialized.'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CalleyButton(
                      text: 'Start Calling Now',
                      onPressed: () {
                        Navigator.pushNamed(context, '/dialer');
                      },
                    ),
                  ),
                ],
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
}
