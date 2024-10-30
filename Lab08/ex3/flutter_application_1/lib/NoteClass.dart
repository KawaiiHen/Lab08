class Note {
  String title;
  String content;
  String? password;
  String color; // Color in hex format as string

  Note({
    required this.title,
    required this.content,
    this.password,
    this.color = '0xFFFFFF00', // Default to yellow color
  });

  // Convert a Note object to a map for easier data management
  Map<String, String?> toMap() {
    return {
      'title': title,
      'content': content,
      'password': password,
      'color': color, // Keep color as a string
    };
  }

  // Factory constructor to create a Note from a map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      password: map['password'],
      color: map['color'] ?? '0xFFFFFF00',
    );
  }
}
