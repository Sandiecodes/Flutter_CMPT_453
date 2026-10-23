import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/post.dart';

String getBaseHost() {
  if (kIsWeb) return 'localhost';

  if (Platform.isAndroid) return '10.0.2.2';

  if (Platform.isIOS ||
      Platform.isMacOS ||
      Platform.isWindows ||
      Platform.isLinux) {
    return '127.0.0.1';
  }

  // Use your computer's IP for physical devices.
  //return '';
}

final String baseUrl = 'http://${getBaseHost()}:3001';
final http.Client client = http.Client();

class ApiService {
  // Shared chat history.
  // Persists while the app process is running.
  static final List<Map<String, String>> chatHistory = [];

  // Fetch posts
  Future<List<Post>> fetchPosts() async {
    final response = await client.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Post.fromJson(json)).toList();
    }

    throw Exception('Failed to load posts (Status: ${response.statusCode})');
  }

  // Create a post
  Future<Post> createPost(String text, String time) async {
    final newPostData = {'text': text, 'time': time};

    final response = await client.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newPostData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      'Failed to create post (Status: ${response.statusCode}): '
      '${response.body}',
    );
  }

  // Edit a post
  Future<Post> editPost(int id, String newText, String newTime) async {
    final updatedPost = {'text': newText, 'time': newTime};

    final response = await client.patch(
      Uri.parse('$baseUrl/posts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedPost),
    );

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      'Failed to edit post (Status: ${response.statusCode}): '
      '${response.body}',
    );
  }

  // Delete a post
  Future<void> deletePost(int id) async {
    final response = await client.delete(Uri.parse('$baseUrl/posts/$id'));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete post (Status: ${response.statusCode}): '
        '${response.body}',
      );
    }
  }

  // Send chat history to Ollama through Node.js.
  Future<String> sendChatMessage(List<Map<String, String>> messages) async {
    final response = await client
        .post(
          Uri.parse('$baseUrl/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'messages': messages}),
        )
        .timeout(const Duration(seconds: 125));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final reply = data['reply'];

      if (reply is String) {
        return reply;
      }

      throw Exception('The chat server returned an invalid reply.');
    }

    throw Exception(
      'Failed to send chat message '
      '(Status: ${response.statusCode}): ${response.body}',
    );
  }

  // Save user message and assistant reply in shared history.
  Future<String> sendAndSaveChatMessage(String text) async {
    final userMessage = {'role': 'user', 'content': text};

    chatHistory.add(userMessage);

    try {
      final reply = await sendChatMessage(
        List<Map<String, String>>.from(chatHistory),
      );

      chatHistory.add({'role': 'assistant', 'content': reply});

      return reply;
    } catch (error) {
      chatHistory.remove(userMessage);
      rethrow;
    }
  }
}
