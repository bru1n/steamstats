import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:steam_api_app/components/drawer_tile.dart';
import 'package:steam_api_app/pages/friend_list_page.dart';
import 'package:steam_api_app/pages/owned_games_page.dart';
import 'package:steam_api_app/pages/player_achievements_page.dart';
import 'package:steam_api_app/pages/player_summary_page.dart';
import 'package:steam_api_app/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SafeArea(
                child: SizedBox(
                  height: 100,
                  child: Row(
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
                      Text(
                        'SteamStats',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(thickness: 1),
              SizedBox(height: 10),
              DrawerTile(
                title: 'Profile',
                route: PlayerSummaryPage(),
                icon: Icon(Icons.person),
              ),
              DrawerTile(
                title: 'Friends',
                route: FriendListPage(),
                icon: Icon(Icons.people),
              ),
              DrawerTile(
                title: 'Games',
                route: OwnedGamesPage(),
                icon: Icon(Icons.gamepad),
              ),
              DrawerTile(
                title: 'Achievements',
                route: PlayerAchievementsPage(),
                icon: Icon(Icons.emoji_events),
              ),
            ],
          ),
          Column(
            children: [
              Divider(thickness: 1),
              DrawerTile(
                title: 'Settings',
                route: SettingsPage(),
                icon: Icon(Icons.settings),
              ),
              const SizedBox(height: 10),
            ],
          )
        ],
      ),
    );
  }
}
