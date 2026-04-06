import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/match_model.dart';
import '../models/profile_model.dart';
import '../models/skill_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _base = AppConstants.baseUrl;

  Future<Map<String, int>> getGithubLanguages(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/github/languages/$username'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data.map((k, v) => MapEntry(k, (v as num).toInt()));
      }
    } catch (e) {
      print('GitHub languages error: $e');
    }
    return {};
  }

  Future<Map<String, dynamic>> getGithubProfile(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/github/profile/$username'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('GitHub profile error: $e');
    }
    return {};
  }

  Future<List<MatchModel>> getFeed(String userId,
      {bool onlineMode = true}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_base/match/feed/$userId?mode=${onlineMode ? 'online' : 'offline'}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          // Real API format: {skills, profile, synergyScore}
          final profileData = item['profile'] as Map<String, dynamic>? ?? {};
          final skillsList = item['skills'] as List<dynamic>? ?? [];
          final synergyScore = (item['synergyScore'] as num?)?.toInt() ?? 0;

          final skills = skillsList.map((s) {
            final sm = s as Map<String, dynamic>;
            return SkillModel(
              skillName: sm['skillName'] ?? sm['skill_name'] ?? '',
              isGithubVerified:
              sm['isGithubVerified'] ?? sm['is_github_verified'] ?? false,
              proficiency: (sm['proficiency'] as num?)?.toInt() ?? 0,
            );
          }).toList();

          final profile = ProfileModel(
            id: profileData['id'] ?? '',
            fullName: profileData['fullName'] ??
                profileData['full_name'] ?? 'Unknown',
            githubUsername: profileData['githubUsername'] ??
                profileData['github_username'] ?? '',
            bio: profileData['bio'] ?? '',
            location: profileData['location'] ?? '',
            primaryRole: profileData['primaryRole'] ??
                profileData['primary_role'] ?? 'Hacker',
            isVerified:
            profileData['isVerified'] ?? profileData['is_verified'] ?? false,
            avatarUrl: profileData['avatarUrl'] ??
                profileData['avatar_url'] ?? '',
            skills: skills,
            synergyScore: synergyScore,
          );

          return MatchModel(
            profile: profile,
            synergyScore: synergyScore,
          );
        }).toList();
      }
    } catch (e) {
      print('Feed error: $e');
    }
    return [];
  }

  Future<bool> sendConnection(
      String senderId, String receiverId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/connections/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderId': senderId,
          'receiverId': receiverId,
          'message': message,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }
}