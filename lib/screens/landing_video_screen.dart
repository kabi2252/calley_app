import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../constants/api_constants.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/calley_button.dart';

class LandingVideoScreen extends StatefulWidget {
  const LandingVideoScreen({super.key});

  @override
  State<LandingVideoScreen> createState() => _LandingVideoScreenState();
}

class _LandingVideoScreenState extends State<LandingVideoScreen> {
  DateTime? _lastBackPressTime;
  late final YoutubePlayerController _ytController;
  bool _isPlayerActive = false;

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController.fromVideoId(
      videoId: ApiConstants.youtubeVideoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _ytController.close();
    super.dispose();
  }

  Future<void> _launchYouTubeVideo() async {
    final uri = Uri.parse(ApiConstants.youtubeVideoUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open video URL: $e'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _launchWebPanel() async {
    final uri = Uri.parse(ApiConstants.calleyWebPanelUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.user?.name.isNotEmpty == true
        ? authProvider.user!.name
        : 'Swati';
    final subscription = authProvider.user?.subscription ?? 'Calley Personal';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit Calley'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFF1E293B),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
            child: Column(
              children: [
                // 1. User Header Blue Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello $userName',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subscription,
                            style: const TextStyle(
                              fontSize: 15,
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

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // 2. First Time Web Panel Notice Box (Dark Blue)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFCBD5E1),
                                height: 1.45,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'If you are here for the first time then ensure that you have uploaded the list to call from Calley Web Panel hosted at: ',
                                ),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: _launchWebPanel,
                                    child: const Text(
                                      'https://app.getcalley.com',
                                      style: TextStyle(
                                        color: Color(0xFF60A5FA),
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Color(0xFF60A5FA),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 3. YouTube 2 MINUTE CHALLENGE Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderLight),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Top Gradient Bar
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF0284C7),
                                      Color(0xFF2563EB)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(17)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.play_circle_fill_rounded,
                                            color: Colors.white, size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          '2 MINUTE CHALLENGE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'YouTube',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Video Player / Thumbnail Area
                              _isPlayerActive
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          bottom: Radius.zero),
                                      child: YoutubePlayer(
                                        controller: _ytController,
                                        aspectRatio: 16 / 9,
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isPlayerActive = true;
                                        });
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 16 / 9,
                                            child: Image.asset(
                                              'assets/images/yt_thumbnail.jpg',
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                color: const Color(0xFF0F172A),
                                                child: const Center(
                                                  child: Icon(
                                                      Icons.videocam_rounded,
                                                      size: 48,
                                                      color: Colors.white54),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Gradient Overlay
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black
                                                        .withOpacity(0.65),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Red YouTube Play Button
                                          Container(
                                            width: 58,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF0000),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black45,
                                                  blurRadius: 10,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                          // Bottom labels
                                          const Positioned(
                                            bottom: 10,
                                            left: 12,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Flutter Machine Test',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Text(
                                                  'Retaxis • Tap to play video',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // HD Badge
                                          Positioned(
                                            top: 10,
                                            right: 12,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'HD',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                              // Video Card Footer
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _isPlayerActive
                                          ? 'Playing Calley guide video'
                                          : 'Watch guide before calling',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textLight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _launchYouTubeVideo,
                                      child: const Row(
                                        children: [
                                          Text(
                                            'Open in YouTube',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.primaryBlue,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(Icons.open_in_new_rounded,
                                              size: 13,
                                              color: AppColors.primaryBlue),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Bottom Action Bar
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
                  child: Row(
                    children: [
                      // WhatsApp Floating Action Button
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
                                content: Text(
                                    'Calley WhatsApp Support: +91 977119044'),
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Start Calling Now Button
                      Expanded(
                        child: CalleyButton(
                          text: 'Start Calling Now',
                          onPressed: () {
                            // Normal push so back button returns to landing
                            Navigator.pushNamed(context, '/dashboard');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
