import 'package:flutter/material.dart';

import 'models/post.dart';
import 'services/api_service.dart';
import 'views/edit_posts.dart';
import 'views/add_posts.dart';
import 'views/chat_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PostsScreen(),
    );
  }
}

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late Future<List<Post>> postsFuture;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    postsFuture = apiService.fetchPosts();
  }

  void _refreshPosts() {
    setState(() {
      postsFuture = apiService.fetchPosts();
    });
  }

  void _navigateToAddPost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPostScreen(onPostCreated: _refreshPosts),
      ),
    );
  }

  void _navigateToChat() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const ChatView()));
  }

  // Delete post function
  Future<void> _deletePost(int id) async {
    try {
      await apiService.deletePost(id);
      _refreshPosts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to delete post: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('453 Posts'),
        actions: [
          // Open AI Chat
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: _navigateToChat,
            tooltip: 'AI Chat',
          ),

          // Refresh posts
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPosts,
            tooltip: 'Refresh Posts',
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final posts = snapshot.data!;

            if (posts.isEmpty) {
              return const Center(child: Text('No posts. Enter some data.'));
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final post = posts[index];

                return ListTile(
                  title: Text(post.text),
                  subtitle: Text('Posted at: ${post.time}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit post
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditPostScreen(
                                post: post,
                                onPostUpdated: _refreshPosts,
                              ),
                            ),
                          );
                        },
                        tooltip: 'Edit Post',
                      ),

                      // Delete post
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePost(post.id),
                        tooltip: 'Delete Post',
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No posts. Enter some data.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPost,
        tooltip: 'Add Post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
