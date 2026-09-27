import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_services.dart';
import 'add_post_page.dart';
import 'add_category_page.dart';
import 'detail_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<PostModel>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  // Function to refresh posts data from API
  void _fetchPosts() {
    setState(() {
      _postsFuture = ApiServices().getPosts();
    });
  }

  // Navigate to AddPostPage and refresh if successfully created
  Future<void> _navigateToAddPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPostPage(),
      ),
    );

    if (result == true) {
      _fetchPosts();
    }
  }

  // Navigate to AddCategoryPage and refresh if needed
  Future<void> _navigateToAddCategory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCategoryPage(),
      ),
    );

    if (result == true) {
      _fetchPosts();
    }
  }

  // Helper widget untuk item postingan agar tidak duplikasi kode
  Widget _buildPostItem(PostModel post) {
    return ListTile(
      leading: const Icon(Icons.article),
      title: Text(post.postTitle),
      subtitle: Text('Category ID: ${post.categoryId}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        // Navigate to detail page and wait for result
        final shouldRefresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPostPage(post: post),
          ),
        );

        // Refresh list if an item was updated/deleted
        if (shouldRefresh == true) {
          _fetchPosts();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Add Category',
            onPressed: _navigateToAddCategory,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchPosts,
          ),
        ],
      ),
      body: FutureBuilder<List<PostModel>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Failed to fetch posts from server!',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _fetchPosts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No blog posts available.'),
            );
          }

          final posts = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _fetchPosts(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Tampilan Mobile (Lebar < 600dp)
                if (constraints.maxWidth < 600) {
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return _buildPostItem(posts[index]);
                    },
                  );
                }

                // Tampilan Web / Tablet / Desktop (Lebar >= 600dp)
                int crossAxisCount = constraints.maxWidth >= 900 ? 3 : 2;

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 3.5,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Center(
                        child: _buildPostItem(posts[index]),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPost,
        tooltip: 'Add New Article',
        child: const Icon(Icons.add),
      ),
    );
  }
}