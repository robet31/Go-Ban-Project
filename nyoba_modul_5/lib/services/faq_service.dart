import 'package:supabase_flutter/supabase_flutter.dart'; // Tambahkan ini

class FAQ {
  final int id;
  final String question;
  final String answer;
  final String detail;
  final String? image; 

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.detail,
    this.image, 
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'] as int, // Cast ke int
      question: json['question'] as String,
      answer: json['answer'] as String,
      detail: json['detail'] as String,
      image: json['image'] as String?, // Cast ke String?
    );
  }
}
