import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MobilPage extends StatefulWidget {
  const MobilPage({super.key});

  @override
  _MobilPageState createState() => _MobilPageState();
}

class _MobilPageState extends State<MobilPage> {
  List bengkelList = [];
  bool isLoading = false;

  // Controller untuk form input
  final _namaBengkelController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _gambarController = TextEditingController();
  final _ratingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBengkelData();
  }

  // Fungsi untuk mengambil data bengkel dari API
  fetchBengkelData() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('http://192.168.1.20/goban_project/get.php'));

    if (response.statusCode == 200) {
      setState(() {
        bengkelList = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Fungsi untuk menambahkan data bengkel
  addBengkel() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.20/goban_project/post.php'),
      body: {
        'nama_bengkel': _namaBengkelController.text,
        'jenis_kendaraan': 'Mobil',  // Set untuk mobil
        'lokasi': _lokasiController.text,
        'gambar': _gambarController.text,
        'rating': _ratingController.text,
      },
    );

    if (response.statusCode == 200) {
      fetchBengkelData();
      _namaBengkelController.clear();
      _lokasiController.clear();
      _gambarController.clear();
      _ratingController.clear();
    } else {
      throw Exception('Failed to add data');
    }
  }

  // Fungsi untuk memperbarui rating bengkel
  updateRating(int id, String rating) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.20/goban_project/put.php'),
      body: {
        'id': id.toString(),
        'rating': rating,
      },
    );

    if (response.statusCode == 200) {
      fetchBengkelData();
    } else {
      throw Exception('Failed to update rating');
    }
  }

  // Fungsi untuk menghapus bengkel
  deleteBengkel(int id) async {
    final response = await http.delete(
      Uri.parse('http://192.168.1.20/goban_project/delete.php'),
      body: {'id': id.toString()},
    );

    if (response.statusCode == 200) {
      fetchBengkelData();
    } else {
      throw Exception('Failed to delete bengkel');
    }
  }

  // Form input untuk menambah bengkel
  void showFormDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Bengkel Mobil'),
          content: Column(
            children: [
              TextField(
                controller: _namaBengkelController,
                decoration: const InputDecoration(hintText: 'Nama Bengkel'),
              ),
              TextField(
                controller: _lokasiController,
                decoration: const InputDecoration(hintText: 'Lokasi'),
              ),
              TextField(
                controller: _gambarController,
                decoration: const InputDecoration(hintText: 'Gambar URL'),
              ),
              TextField(
                controller: _ratingController,
                decoration: const InputDecoration(hintText: 'Rating'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                addBengkel();
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Bengkel Mobil')),
      body: Column(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: bengkelList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(bengkelList[index]['nama_bengkel']),
                          subtitle: Text('${bengkelList[index]['lokasi']}'),
                          leading: Image.network(bengkelList[index]['gambar']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  updateRating(
                                    bengkelList[index]['id'],
                                    (double.parse(bengkelList[index]['rating']) + 0.1).toString(),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  deleteBengkel(bengkelList[index]['id']);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showFormDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
