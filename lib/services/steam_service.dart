import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:steam_api_app/models/game_item.dart';
import 'package:steam_api_app/models/global_achievement.dart';
import 'package:http/http.dart' as http;
import 'package:steam_api_app/models/news_item.dart';
import 'package:steam_api_app/models/player_achievement.dart';
import 'package:steam_api_app/models/player_summary.dart';
import 'package:steam_api_app/models/recent_game.dart';

class SteamService {
  final baseUrl = 'https://api.steampowered.com';
  final apiKey = dotenv.env['API_KEY'];

  Future<List<GlobalAchievement>> getGlobalAchievementPercentages(int appId) async {
    List<GlobalAchievement> achievements = [];
    String url =
        '$baseUrl/ISteamUserStats/GetGlobalAchievementPercentagesForApp/v0002/?gameid=$appId&format=json';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      for (var eachAchievement in jsonData['achievementpercentages']['achievements']) {
        final achievement = GlobalAchievement.fromJson(eachAchievement);
        achievements.add(achievement);
      }
      return achievements;
    } else {
      throw 'Error fetching global achievement percentages.\nStatus code: ${response.statusCode}';
    }
  }

  Future<int> getSteamLevel(String steamId) async {
    int steamLevel = 0;
    String url = '$baseUrl/IPlayerService/GetSteamLevel/v1/?key=$apiKey&steamid=$steamId';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      steamLevel = jsonData['response']['player_level'];
      return steamLevel;
    } else {
      throw 'Error fetching steam level.\nStatus code: ${response.statusCode}';
    }
  }

  Future<List<PlayerSummary>> getPlayerSummary(List<String> steamIds) async {
    List<PlayerSummary> playerSummary = [];
    final int hundredCount = steamIds.length ~/ 100;

    List<Future<void>> requests = List.generate(
      hundredCount + 1,
      (i) async {
        List<String> hundredSteamIds = steamIds.skip(i * 100).take(100).toList();
        String steamIdsFormatted = hundredSteamIds.join(',');
        var url =
            '$baseUrl/ISteamUser/GetPlayerSummaries/v0002/?key=$apiKey&steamids=$steamIdsFormatted';
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          for (var player in jsonData['response']['players']) {
            playerSummary.add(PlayerSummary.fromJson(player));
          }
        } else if (response.statusCode == 429) {
          throw 'Too many requests';
        } else {
          throw 'Error fetching player summary.\nStatus code: ${response.statusCode}';
        }
      },
    );
    await Future.wait(requests);
    return playerSummary;
  }

  Future<List<PlayerAchievement>> getPlayerAchievements(String steamId, int appId) async {
    List<PlayerAchievement> achievements = [];
    String url =
        '$baseUrl/ISteamUserStats/GetPlayerAchievements/v0001/?appid=$appId&key=$apiKey&steamid=$steamId&l=english';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['playerstats']['achievements'] != null) {
        for (var eachAchievement in jsonData['playerstats']['achievements']) {
          final achievement = PlayerAchievement.fromJson(eachAchievement);
          achievements.add(achievement);
        }
      }
      return achievements;
    } else if (response.statusCode == 400) {
      return achievements;
    } else if (response.statusCode == 403) {
      throw 'Your achievements are private!';
    } else {
      throw 'Error fetching player achievements.\nStatus code: ${response.statusCode}';
    }
  }

  Future<List<NewsItem>> getNewsForApp(int appId) async {
    List<NewsItem> news = [];
    String url =
        '$baseUrl/ISteamNews/GetNewsForApp/v0002/?appid=$appId&count=100&maxlength=200&format=json';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      for (var eachNewsItem in jsonData['appnews']['newsitems']) {
        final newsItem = NewsItem.fromJson(eachNewsItem);
        news.add(newsItem);
      }
      return news;
    } else {
      throw 'Error fetching news.\nStatus code: ${response.statusCode}';
    }
  }

  Future<List<String>> getFriendList(String steamId) async {
    List<String> friends = [];
    String url =
        '$baseUrl/ISteamUser/GetFriendList/v0001/?key=$apiKey&steamid=$steamId&relationship=friend';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      for (var eachFriend in jsonData['friendslist']['friends']) {
        friends.add(eachFriend['steamid']);
      }
      return friends;
    } else if (response.statusCode == 401) {
      throw 'Your friends list is private!';
    } else {
      throw 'Error fetching friends list.\nStatus code: ${response.statusCode}';
    }
  }

  Future<List<RecentGame>> getRecentlyPlayedGames(String steamId) async {
    List<RecentGame> games = [];
    String url =
        '$baseUrl/IPlayerService/GetRecentlyPlayedGames/v0001/?key=$apiKey&steamid=$steamId&format=json';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['response']['games'] != null) {
        for (var eachGame in jsonData['response']['games']) {
          final gameItem = RecentGame.fromJson(eachGame);
          games.add(gameItem);
        }
      }
      return games;
    } else {
      throw 'Error fetching recently played games.\nStatus code: ${response.statusCode}';
    }
  }

  Future<List<GameItem>> getOwnedGames(String steamId) async {
    List<GameItem> games = [];
    String url =
        '$baseUrl/IPlayerService/GetOwnedGames/v0001/?key=$apiKey&steamid=$steamId&format=json&include_appinfo=true&include_played_free_games=true';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['response']['games'] != null) {
        for (var eachGame in jsonData['response']['games']) {
          final gameItem = GameItem.fromJson(eachGame);
          games.add(gameItem);
        }
      }
      return games;
    } else {
      throw 'Error fetching owned games.\nStatus code: ${response.statusCode}';
    }
  }
}
