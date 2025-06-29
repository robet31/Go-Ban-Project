import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:nyoba_modul_5/main.dart';
import 'package:nyoba_modul_5/models/destination.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:nyoba_modul_5/services/destination_service.dart';
import 'package:nyoba_modul_5/widgets/location_picker.dart';

class EditDestinationScreen extends StatefulWidget {
  final Destination? destination;

  const EditDestinationScreen({super.key, this.destination});

  @override
  State<EditDestinationScreen> createState() => _EditDestinationScreenState();
}

class _EditDestinationScreenState extends State<EditDestinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _ratingController = TextEditingController();
  final List<File> _images = [];
  List<String> _imageUrls = [];
  latlong2.LatLng? _location;
  bool _isLoading = false;

  final DestinationService _service = DestinationService();

  @override
  void initState() {
    super.initState();
    if (widget.destination != null) {
      _nameController.text = widget.destination!.name;
      _descriptionController.text = widget.destination!.description;
      _priceController.text = widget.destination!.price ?? '';
      _ratingController.text = widget.destination!.rating?.toString() ?? '';
      if (widget.destination!.location != null) {
        _location = latlong2.LatLng(
          widget.destination!.location.latitude,
          widget.destination!.location.longitude,
        );
      }
      _imageUrls = widget.destination!.imageUrls;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.destination == null ? 'Tambah Destinasi' : 'Edit Destinasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          if (widget.destination != null)
            IconButton(
              icon: const Icon(Icons.delete, size: 28),
              onPressed: _deleteDestination,
              tooltip: 'Hapus Destinasi',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    _buildSectionTitle('Gambar Destinasi'),
                    const SizedBox(height: 12),
                    
                    // Image Picker
                    _buildImagePicker(),
                    const SizedBox(height: 24),

                    // Form Fields
                    _buildSectionTitle('Informasi Destinasi'),
                    const SizedBox(height: 16),
                    
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Nama Destinasi',
                                prefixIcon: Icon(Icons.place,
                                    color: Theme.of(context).primaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800]),
                              validator: (value) =>
                                  value!.isEmpty ? 'Nama harus diisi' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Deskripsi',
                                alignLabelWithHint: true,
                                prefixIcon: Icon(Icons.description,
                                    color: Theme.of(context).primaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              maxLines: 4,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800]),
                              validator: (value) => value!.isEmpty
                                  ? 'Deskripsi harus diisi'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _priceController,
                                    decoration: InputDecoration(
                                      labelText: 'Harga (Rp)',
                                      prefixIcon: Icon(Icons.attach_money,
                                          color: Theme.of(context).primaryColor),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 14),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[800]),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Rating',
                                          style: TextStyle(
                                              color: Colors.grey[600])),
                                      const SizedBox(height: 4),
                                      // Ganti dengan input rating sederhana
                                      TextFormField(
                                        controller: _ratingController,
                                        decoration: InputDecoration(
                                          hintText: '0.0 - 5.0',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10)),
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 14),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Location Picker
                    _buildSectionTitle('Lokasi Destinasi'),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: LocationPicker(
                          initialLocation: _location,
                          onLocationSelected: (location) {
                            if (location != null) {
                              setState(() {
                                _location = location;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveDestination,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          'SIMPAN DESTINASI',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._imageUrls.map((url) => _buildNetworkImagePreview(url)),
            ..._images.map((image) => _buildFileImagePreview(image)),
            _buildAddImageButton(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Maksimal 5 gambar',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFileImagePreview(File image) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.close, size: 18, color: Colors.red),
              onPressed: () {
                setState(() {
                  _images.remove(image);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImagePreview(String url) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.close, size: 18, color: Colors.red),
              onPressed: () {
                setState(() {
                  _imageUrls.remove(url);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _images.length + _imageUrls.length < 5
          ? _pickImages
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Maksimal 5 gambar'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo,
                size: 30, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text('Tambah',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      final newImages = pickedFiles.map((e) => File(e.path)).toList();
      if (newImages.length + _images.length + _imageUrls.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maksimal 5 gambar'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      setState(() {
        _images.addAll(newImages);
      });
    }
  }

  Future<void> _saveDestination() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty && _imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap tambahkan minimal satu gambar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap pilih lokasi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload gambar baru
      final newImageUrls = await _service.uploadImages(_images);
      // Gabungkan URL baru dengan URL yang sudah ada
      final allImageUrls = [..._imageUrls, ...newImageUrls];

      final destination = Destination(
        id: widget.destination?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrls: allImageUrls,
        location: gmaps.LatLng(
          _location!.latitude,
          _location!.longitude,
        ),
        price: _priceController.text.isEmpty ? null : _priceController.text,
        rating: _ratingController.text.isEmpty
            ? null
            : double.tryParse(_ratingController.text),
      );

      if (widget.destination == null) {
        await _service.addDestination(destination);
      } else {
        await _service.updateDestination(destination);
      }
      // TAMPILKAN INTERSTITIAL AD SETELAH SIMPAN BERHASIL
      interstitialAdManager.showAd();

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDestination() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Apakah Anda yakin ingin menghapus destinasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal',
                style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _service.deleteDestination(widget.destination!.id!);
        // TAMPILKAN INTERSTITIAL AD SETELAH HAPUS BERHASIL
        interstitialAdManager.showAd();
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}