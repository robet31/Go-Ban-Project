import 'package:flutter/material.dart';
import 'package:nyoba_modul_5/services/faq_service.dart';

class FAQDetailPage extends StatelessWidget {
  final FAQ faq;

  const FAQDetailPage({Key? key, required this.faq}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(faq.question), backgroundColor: Color(0xFF8DECB4)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilkan gambar jika ada
            if (faq.image != null && faq.image!.isNotEmpty) // Periksa null safety
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  faq.image!, // Gunakan ! karena sudah diperiksa
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 80),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Jawaban:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 4),
            Text(faq.answer, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(
              'Detail Penjelasan:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              faq.detail,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
