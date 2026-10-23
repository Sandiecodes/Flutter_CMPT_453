// Data model for post

class Post {
  final int id;
  final String text;
  final String time;

  Post({required this.id, required this.text, required this.time});

  //Data from the server to Post object
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      text: json['text'] as String,
      time: json['time'] as String,
    );
  }

  //Convert Post object to a JSON map for sending to server
  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'time': time};
  }
}
