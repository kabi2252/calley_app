import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/list_provider.dart';

class CalleyNavigationDrawer extends StatelessWidget {
  const CalleyNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 1. Drawer Header Profile (Blue)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
            color: AppColors.primaryBlue,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Text('👩', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?.name ?? "Swati S"} - Personal',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? 'swati@getcalley.com',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Navigation Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDrawerItem(
                  icon: Icons.rocket_launch_outlined,
                  title: 'Getting Started',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/landing');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.sync_rounded,
                  title: 'Sync Data',
                  onTap: () {
                    context.read<ListProvider>().fetchLists();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Syncing data from Calley REST API...'),
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.emoji_events_outlined,
                  title: 'Gamification',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/analytics');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.mail_outline_rounded,
                  title: 'Send Logs',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logs successfully bundled and sent to server.'),
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile-settings');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help?',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Call Calley Support: support@getcalley.com'),
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.cancel_outlined,
                  title: 'Cancel Subscription',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Divider(height: 1, color: AppColors.borderLight),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    'App Info',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.textLight,
                    ),
                  ),
                ),

                _buildDrawerItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About Us',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.shield_outlined,
                  title: 'Privacy Policy',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.sell_outlined,
                  title: 'Version 1.01.52',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.share_outlined,
                  title: 'Share App',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('App link copied to clipboard!'),
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  color: AppColors.errorRed,
                  onTap: () async {
                    Navigator.pop(context);
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppColors.textDark,
  }) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      leading: Icon(icon, size: 20, color: color == AppColors.errorRed ? color : AppColors.textLight),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}
