class NewsItem {
  final String title;
  final String url;
  final String author;
  final String contents;
  final DateTime date;
  final List<String>? tags;

  NewsItem({
    required this.title,
    required this.url,
    required this.author,
    required this.contents,
    required this.date,
    this.tags,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'],
      url: json['url'],
      author: json['author'],
      contents: json['contents'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] * 1000),
      tags: (json['tags'] as List<dynamic>?)?.map((tag) => tag as String).toList(),
    );
  }
}
