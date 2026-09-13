import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/post_model.dart';

class ApiServices {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  Future<List<PostModel>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts/db_app_blog'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> postsData = body['data'] ?? [];

      return postsData.map((item) => PostModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed render data from server');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/categories/db_app_blog'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> categoriesData = body['data'] ?? [];
      return List<Map<String, dynamic>>.from(categoriesData);
    } else {
      throw Exception('Failed to fetch categories from server');
    }
  } catch (e) {
    print('GET Categories Exception Error: $e');
    return [];
  }
}

  Future<bool> createPost({
    required String categoryId,
    required String postTitle,
    required String postContent,
  }) async {
    try {
      final String generatedId = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
          .toString();

      final response = await http.post(
        Uri.parse('$baseUrl/posts/db_app_blog'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'post_id': generatedId,
          'category_id': categoryId,
          'post_title': postTitle,
          'post_content': postContent,
        }),
      );

      print('POST Status Code: ${response.statusCode}');
      print('POST Response Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('POST Exception Error: $e');
      return false;
    }
  }

  Future<bool> createCategory({
    required String categoryId,
    required String categoryName,
    String categoryDescription = "",
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categories/db_app_blog'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'category_id': categoryId,
          'category_name': categoryName,
          'category_description': categoryDescription,
        })
      );

      print('POST Category Status Code: ${response.statusCode}');
      print('POST Category Response Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('POST Category Exception Error: $e');
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/db_app_blog/$postId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('DELETE Post Status Code: ${response.statusCode}');
      print('DELETE Post Response Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('DELETE Post Exception Error: $e');
      return false;
    }
  }

  Future<bool> updatePost({
    required String postId,
    required String postTitle,
    required String postContent,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/posts/db_app_blog/$postId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'post_title': postTitle,
          'post_content': postContent,
        }),
      );

      print('PATCH Post Status Code: ${response.statusCode}');
      print('PATCH Post Response Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('PATCH Post Exception Error: $e');
      return false;
    }
  }
  
}
