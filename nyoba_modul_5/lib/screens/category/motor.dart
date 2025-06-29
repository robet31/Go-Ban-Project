import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MotorPage extends StatefulWidget {
  const MotorPage({super.key});

  @override
  _MotorPageState createState() => _MotorPageState();
}

class _MotorPageState extends State<MotorPage> {
  List orders = [];
  bool isLoading = false;

  // Controller untuk form input
  final _serviceTypeController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchOrdersData();
  }

  // Fungsi untuk mengambil data pesanan dari API
  // Fungsi untuk mengambil data pesanan dari API
  fetchOrdersData() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('http://192.168.1.7/goban_project/get.php'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data is List) {
        setState(() {
          orders = data;
          isLoading = false;
        });
      } else {
        setState(() {
          orders = [];
          isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // Fungsi untuk menambahkan pesanan
  addOrder() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.7/goban_project/post.php'),
      body: {
        'user_id': '1',
        'service_type': _serviceTypeController.text,
        'vehicle_type': _vehicleTypeController.text,
        'location': _locationController.text,
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data.containsKey('error')) {
        // Tampilkan pesan error dari server
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${data['error']}')));
      } else {
        fetchOrdersData();
        _serviceTypeController.clear();
        _vehicleTypeController.clear();
        _locationController.clear();
      }
    } else {
      throw Exception('Failed to add order');
    }
  }
  // void _clearControllers() {
  //   _serviceTypeController.clear();
  //   _vehicleTypeController.clear();
  //   _locationController.clear();
  // }

  // Fungsi untuk memperbarui status pesanan
  updateOrderStatus(int id, String status) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.7/goban_project/put.php'),
      body: {'id': id.toString(), 'status': status},
    );

    if (response.statusCode == 200) {
      fetchOrdersData(); // Refresh data pesanan setelah diperbarui
    } else {
      throw Exception('Failed to update order status');
    }
  }

  // Fungsi untuk menghapus pesanan
  deleteOrder(int id) async {
    final response = await http.delete(
      Uri.parse('http://192.168.1.7/goban_project/delete.php'),
      body: {'id': id.toString()},
    );

    if (response.statusCode == 200) {
      fetchOrdersData(); // Refresh data pesanan setelah dihapus
    } else {
      throw Exception('Failed to delete order');
    }
  }

  // Form input untuk menambah pesanan
  void showFormDialog() {
    Map<String, String> vehicleServiceMap = {
      'Motor': 'Tambal Ban',
      'Mobil': 'Tambal Ban',
      'Truck': 'Tambal Ban',
      'Sepeda': 'Tambal Ban',
    };

    String? selectedVehicleType;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Pesanan'),
          content: Column(
            children: [
              // Dropdown for vehicle type
              DropdownButtonFormField<String>(
                value: selectedVehicleType,
                hint: const Text('Jenis Kendaraan'),
                onChanged: (value) {
                  setState(() {
                    selectedVehicleType = value;
                    // Auto-fill service type based on vehicle type
                    _serviceTypeController.text =
                        vehicleServiceMap[value] ?? '';
                  });
                },
                items:
                    vehicleServiceMap.keys.map((String vehicleType) {
                      return DropdownMenuItem<String>(
                        value: vehicleType,
                        child: Text(vehicleType),
                      );
                    }).toList(),
              ),
              // TextField for service type (disabled)
              TextField(
                controller: _serviceTypeController,
                decoration: const InputDecoration(hintText: 'Jenis Layanan'),
                enabled: false,
              ),
              // TextField for location
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(hintText: 'Lokasi'),
              ),
            ],
          ),
          actions: [
          TextButton(
            onPressed: () {
              if (selectedVehicleType != null && _locationController.text.isNotEmpty) {
                addOrder();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Simpan'),
          ),
        ],
        );
      },
    );
  }
  // Function to show the update order status dialog
void showUpdateStatusDialog(int id, String currentStatus) {
  // Status options
  List<String> statusOptions = ['pending', 'accepted', 'completed', 'cancelled'];

  // Selected status
  String? selectedStatus;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          children: [
            // Dropdown for status
            DropdownButtonFormField<String>(
              value: selectedStatus,
              hint: const Text('Pilih Status'),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                });
              },
              items: statusOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (selectedStatus != null) {
                updateOrderStatus(id, selectedStatus!);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
}
// Modify the ListView.builder to use the new update dialog
// itemBuilder: (context, index) {
//   return Card(
//     child: ListTile(
//       title: Text(orders[index]['service_type']),
//       subtitle: Text('${orders[index]['status']}'),
//       trailing: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: () {
//               showUpdateStatusDialog(int.parse(orders[index]['id']), orders[index]['status']);
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete),
//             onPressed: () {
//               deleteOrder(int.parse(orders[index]['id']));
//             },
//           ),
//         ],
//       ),
//     ),
//   );
// }

  // Fungsi pencarian berdasarkan status
  searchOrdersByStatus(String status) async {
    final response = await http.get(
      Uri.parse('http://localhost:3307/get.php?status=$status'),
    );

    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load orders');
    }
  }

  final _statusController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Tambal Ban')),
      body: Column(
        children: [
          TextField(
            onChanged: (text) {
              searchOrdersByStatus(text); // Fungsi pencarian berdasarkan status
            },
            decoration: const InputDecoration(
              hintText: 'Cari berdasarkan status...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(orders[index]['service_type']),
                        subtitle: Text('${orders[index]['status']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                showUpdateStatusDialog(int.parse(orders[index]['id']), orders[index]['status']);
                                // showDialog(
                                //   context: context,
                                //   builder: (context) {
                                //     return AlertDialog(
                                //       title: const Text('Update Status'),
                                //       content: TextField(
                                //         controller: _statusController,
                                //         decoration: const InputDecoration(
                                //           hintText: 'New Status',
                                //         ),
                                //       ),
                                //       actions: [
                                //         TextButton(
                                //           onPressed: () {
                                //             updateOrderStatus(
                                //               int.parse(orders[index]['id']),
                                //               _statusController.text,
                                //             );
                                //             Navigator.of(context).pop();
                                //           },
                                //           child: const Text('Update'),
                                //         ),
                                //       ],
                                //     );
                                //   },
                                // );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteOrder(int.parse(orders[index]['id']));
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
