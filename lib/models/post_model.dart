class PostModel {
  final String categoryId;
  final String postId;
  final String postTitle;
  final String postContent;

  PostModel({
    required this.categoryId,
    required this.postId,
    required this.postTitle,
    required this.postContent,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      categoryId: json['category_id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? '',
      postTitle: json['post_title']?.toString() ?? '',
      postContent: json['post_content']?.toString() ?? '',
    );
  }
}
