import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:steam_api_app/helper/helper_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsTile extends StatelessWidget {
  final String title;
  final String url;
  final String author;
  final String contents;
  final DateTime date;
  final List<String>? tags;

  const NewsTile({
    super.key,
    required this.title,
    required this.url,
    required this.author,
    required this.contents,
    required this.date,
    this.tags,
  });

  static const String baseUrl = 'https://clan.fastly.steamstatic.com/images';

  String parseHtmlString(String htmlString) {
    return htmlString.replaceAllMapped(RegExp(r'<[^>]*>'), (match) => '');
  }

  Map<String, String> extractImageAndText(String input, String baseUrl) {
    var pattern = RegExp(r'\{STEAM_CLAN_IMAGE\}/[^\s]+');
    var match = pattern.firstMatch(input);

    if (match != null) {
      final imagePath = match.group(0)?.replaceAll("{STEAM_CLAN_IMAGE}", baseUrl) ?? '';
      final textWithoutImage = input.replaceFirst(match.group(0)!, '').trim();
      return {'image': imagePath, 'text': textWithoutImage};
    }

    pattern = RegExp(r'\{STEAM_CLAN_LOC_IMAGE\}/[^\s]+');
    match = pattern.firstMatch(input);

    if (match != null) {
      final imagePath = match.group(0)?.replaceAll("{STEAM_CLAN_LOC_IMAGE}", baseUrl) ?? '';
      final textWithoutImage = input.replaceFirst(match.group(0)!, '').trim();
      return {'image': imagePath, 'text': textWithoutImage};
    }

    return {'image': '', 'text': input};
  }

  String proxyAvatarUrl(String originalUrl) {
    final Uri originalUri = Uri.parse(originalUrl);
    return 'https://images.weserv.nl/?url=${originalUri.host}${originalUri.path}';
  }

  void displayMessage(String message, context) {
    displayMessageToUser('Failed to open link', context);
  }

  @override
  Widget build(BuildContext context) {
    final result = extractImageAndText(contents, baseUrl);
    final Uri parsedUrl = Uri.parse(url);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              const SizedBox(),
              if (result['image'] != '')
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Image.network(
                    proxyAvatarUrl(result['image']!),
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image);
                    },
                  ),
                ),
              Text(
                parseHtmlString(result['text']!),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              Text(
                'Date: ${DateFormat('dd MMMM yyyy, HH:mm').format(date)}',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              Text(
                'Author: $author',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              if (tags != null)
                Wrap(
                    children: tags!
                        .map((tag) => Text(
                              '#$tag ',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            ))
                        .toList()),
              GestureDetector(
                onTap: () async {
                  if (await launchUrl(parsedUrl)) {
                    await launchUrl(parsedUrl, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.only(top: 4, right: 16, bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      Icon(
                        Icons.link,
                        size: 24,
                        color: Colors.blue,
                      ),
                      Text(
                        'Open link',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
