import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:steam_api_app/helper/helper_functions.dart';
import 'package:steam_api_app/pages/player_summary_page.dart';
import 'package:steam_api_app/pages/settings_page.dart';
import 'package:steam_api_app/services/steam_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isConnected = connectivityResult.any((result) => result != ConnectivityResult.none);

    if (!isConnected) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    if (!mounted) return;

    final steamProvider = Provider.of<SteamProvider>(context, listen: false);

    await Future.wait([
      steamProvider.loadSharedPreferencesData(),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    if (!mounted) return;

    if (steamProvider.steamId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PlayerSummaryPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    SvgPicture.asset(
                      'assets/steam_logo.svg',
                      height: 36,
                      width: 36,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const Text(
                      'SteamStats',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                (_isLoading)
                    ? CircularProgressIndicator(
                        strokeCap: StrokeCap.round,
                        strokeWidth: 3,
                      )
                    : Column(
                        spacing: 10,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              Icon(
                                Icons.wifi_off,
                              ),
                              Text(
                                'No internet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {
                              displayMessageToUser('refreshing...', context);
                              _initializeApp();
                            },
                            icon: Icon(Icons.refresh, color: Colors.black),
                            label: Text('Refresh', style: TextStyle(color: Colors.black)),
                          )
                        ],
                      ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
