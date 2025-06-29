import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:nyoba_modul_5/services/faq_service.dart';
import 'package:nyoba_modul_5/screens/home/detail_faq.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  late Future<List<FAQ>> futureFaq;

  // Ubah method fetchFAQ
  Future<List<FAQ>> fetchFAQ() async {
    final response = await Supabase.instance.client
        .from('faq')
        .select('*')
        .order('id', ascending: true); // Urutkan berdasarkan ID

    if (response is List) { // Supabase client.select() mengembalikan List<Map<String, dynamic>>
      return response.map((data) => FAQ.fromJson(data)).toList();
    } else {
      // Ini akan terjadi jika ada error dari Supabase.
      // Anda bisa menangani error lebih spesifik jika diperlukan.
      throw Exception('Gagal mengambil data dari Supabase: $response');
    }
  }

  @override
  void initState() {
    super.initState();
    futureFaq = fetchFAQ();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text('Frequently Asked Questions'),
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      // ),
      body: FutureBuilder<List<FAQ>>(
        future: futureFaq,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data.'));
          } else {
            final faqList = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: faqList.length,
              itemBuilder: (context, index) {
                final faq = faqList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      childrenPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Row(
                        children: [
                          const Icon(Icons.help_outline, color: Colors.black),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              faq.question,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        if (faq.image != null && faq.image!.isNotEmpty) // Periksa null safety
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              faq.image!, // Gunakan ! karena sudah diperiksa
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 80),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Text(faq.answer, style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FAQDetailPage(faq: faq),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                            label: const Text('Lihat Detail'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
