import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List posts = [];
  bool isLoading = true;

  Future<void> getCategories() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/posts/db_app_blog'),
    );

    if (response.statusCode == 200) {
      setState(() {
        posts = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement activate
    super.initState();
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Posts')
      ),
      body: isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(
                  color: Colors.blueAccent,
                  strokeWidth: 3,
                ),
                SizedBox(height: 12,),
                Text('Mengambil data artikel...')
              ]
          ),
        )
        : posts.isEmpty
          ? const Center(child: Text('Tidak ada post'))
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  leading: const Icon(Icons.article),
                  title: Text(post['post_title'] ?? 'Tanpa Judul'),
                  subtitle: Text('Kategori ID: ${post['category_id']}'),
                );
              },
            ),
    );
  }
}
 