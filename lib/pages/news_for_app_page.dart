import 'package:flutter/material.dart';
import 'package:steam_api_app/components/my_drawer.dart';
import 'package:steam_api_app/components/news_tile.dart';
import 'package:steam_api_app/components/no_data_scaffold.dart';
import 'package:steam_api_app/models/news_item.dart';
import 'package:steam_api_app/services/steam_service.dart';

class NewsForAppPage extends StatefulWidget {
  final int appId;
  final String name;

  const NewsForAppPage({
    super.key,
    required this.appId,
    required this.name,
  });

  @override
  State<NewsForAppPage> createState() => _NewsForAppPageState();
}

class _NewsForAppPageState extends State<NewsForAppPage> {
  final _steamService = SteamService();
  List<NewsItem> _news = [];
  bool _isLoading = true;

  _fetchNews() async {
    if (!mounted) return;

    setState(() {
      _news.clear();
      _isLoading = true;
    });
    try {
      List<NewsItem> news = await _steamService.getNewsForApp(widget.appId);

      if (!mounted) return;

      setState(() {
        _news = news;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching news: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        drawer: const MyDrawer(),
        drawerEdgeDragWidth: 16,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      if (_news.isEmpty) {
        return NoDataScaffold(
          title: 'News for App',
          refreshFunction: _fetchNews,
          description: 'Choose another game.',
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(
              '${widget.name} News',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _fetchNews();
                },
              ),
            ],
          ),
          drawer: const MyDrawer(),
          drawerEdgeDragWidth: 16,
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _news.length,
            itemBuilder: (context, index) {
              final newsItem = _news[index];
              return NewsTile(
                title: newsItem.title,
                contents: newsItem.contents,
                author: newsItem.author,
                date: newsItem.date,
                url: newsItem.url,
                tags: newsItem.tags,
              );
            },
          ),
        );
      }
    }
  }
}
