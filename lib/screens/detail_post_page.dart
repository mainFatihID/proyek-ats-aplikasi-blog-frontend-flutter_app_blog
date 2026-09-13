import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/api_services.dart';
import 'edit_post_page.dart';

class DetailPostPage extends StatefulWidget {
  final PostModel post;

  const DetailPostPage({super.key, required this.post});

  @override
  State<DetailPostPage> createState() => _DetailPostPageState();
}

class _DetailPostPageState extends State<DetailPostPage> {
  bool _isDeleting = false;

  Future<void> _showDeleteConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Article'),
        content: const Text('Are you sure you want to delete this article?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _executeDelete();
    }
  }

  Future<void> _executeDelete() async {
    setState(() {
      _isDeleting = true;
    });

    final success = await ApiServices().deletePost(widget.post.postId);

    if (!mounted) return;

    setState(() {
      _isDeleting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Article deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete article.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Artikel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Article',
            onPressed: _isDeleting
                ? null
                : () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPostPage(post: widget.post),
                      ),
                    );

                    if (updated == true && mounted) {
                      // Pop kembali ke HomePage agar daftar artikel langsung terbarui
                      Navigator.pop(context, true);
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete Article',
            onPressed: _isDeleting ? null : _showDeleteConfirmation,
          ),
        ],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.postTitle.isEmpty
                        ? "Untitled"
                        : widget.post.postTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Chip(
                    avatar: const Icon(Icons.category, size: 16),
                    label: Text('Category ID: ${widget.post.categoryId}'),
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                  ),
                  const Divider(height: 32, thickness: 1),
                  Text(
                    widget.post.postContent.isEmpty
                        ? 'No article content yet.'
                        : widget.post.postContent,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}