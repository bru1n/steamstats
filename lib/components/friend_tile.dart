import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:steam_api_app/helper/helper_functions.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendTile extends StatelessWidget {
  final String personaName;
  final String avatarUrl;
  final String personaState;
  final DateTime? lastLogOffDate;
  final Color color;
  final String steamId;

  const FriendTile({
    super.key,
    required this.personaName,
    required this.avatarUrl,
    required this.personaState,
    this.lastLogOffDate,
    required this.color,
    required this.steamId,
  });

  String dateCalc() {
    if (lastLogOffDate != null) {
      return timeago.format(lastLogOffDate!);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surfaceContainer,
              Theme.of(context).colorScheme.surfaceContainer,
              color,
            ],
            stops: [0, 0.95, 0.95],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: Image.network(
              avatarUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Icon(
                  Icons.person,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                );
              },
            ),
          ),
          title: Text(personaName),
          subtitle: personaState == 'Offline' ? Text(dateCalc()) : Text(personaState),
          trailing: IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: steamId));
              displayMessageToUser('Steam ID copied to clipboard', context);
            },
            icon: Icon(Icons.copy),
            iconSize: 20,
          ),
        ),
      ),
    );
  }
}
