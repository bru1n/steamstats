import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steam_api_app/components/info_tile.dart';
import 'package:steam_api_app/components/my_drawer.dart';
import 'package:steam_api_app/components/my_textfield.dart';
import 'package:steam_api_app/pages/player_summary_page.dart';
import 'package:steam_api_app/services/steam_provider.dart';
import 'package:steam_api_app/theme/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final steamProvider = Provider.of<SteamProvider>(context, listen: false);
  final TextEditingController steamIdController = TextEditingController();
  String errorMessage = '';
  Color? textFieldColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLogin();
    });
  }

  void _checkFirstLogin() {
    if (steamProvider.steamId == null) {
      _showSteamIDDialog();
    }
  }

  void _showMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Please note',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'The account must be publicly visible in order for all data to be displayed correctly.'),
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(top: 10),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => PlayerSummaryPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Text(
                    'Ok',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSteamIDDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void validateAndSubmit() {
              String value = steamIdController.text.trim();
              if (value.isEmpty) {
                setState(() {
                  errorMessage = 'Please enter a Steam ID';
                  textFieldColor = Colors.red.withValues(alpha: 0.9);
                });
              } else if (value.length != 17) {
                setState(() {
                  errorMessage = 'Steam ID must be 17 characters long';
                  textFieldColor = Colors.red.withValues(alpha: 0.9);
                });
              } else {
                setState(() {
                  textFieldColor = Colors.green.withValues(alpha: 0.9);
                });
                steamProvider.setSteamId(value);
                steamIdController.clear();
                Navigator.pop(context);
                _showMessage();
                setState(() {
                  textFieldColor = null;
                });
              }
            }

            return AlertDialog(
              title: Text('Enter a user\'s SteamID:'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  SizedBox(),
                  MyTextfield(
                    controller: steamIdController,
                    onSubmitted: (_) => validateAndSubmit(),
                    hintText: 'E.g. 76561197960435530',
                    color: textFieldColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        if (errorMessage.isNotEmpty)
                          Text(
                            errorMessage,
                            style: TextStyle(color: Colors.red.withValues(alpha: 0.9)),
                          ),
                        if (steamProvider.steamId != null)
                          Text('Selected SteamID: ${steamProvider.steamId}'),
                      ],
                    ),
                  ),
                  SizedBox(),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            steamIdController.clear();
                            errorMessage = '';
                            textFieldColor = null;
                          },
                          child: Text(
                            'Close',
                          ),
                        ),
                        TextButton(
                          onPressed: validateAndSubmit,
                          child: Text('Ok'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      drawer: const MyDrawer(),
      drawerEdgeDragWidth: 16,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: [
                GestureDetector(
                  onTap: _showSteamIDDialog,
                  child: InfoTile(
                    title: Text('Steam ID'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: _showSteamIDDialog,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text('Dark mode'),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'SteamStats • 2025',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
