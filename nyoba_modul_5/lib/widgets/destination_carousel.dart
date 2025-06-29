import 'package:flutter/material.dart';
import '../models/destination.dart';

// Helper function to format price to Rupiah
String formatRupiah(String price) {
  if (price.isEmpty) return price;
  
  // Remove non-digit characters
  final cleanPrice = price.replaceAll(RegExp(r'[^\d]'), '');
  final number = int.tryParse(cleanPrice);
  
  if (number == null) return price;
  
  // Format to Rupiah currency
  return 'Rp${number.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  )}';
}

class DestinationCarousel extends StatelessWidget {
  final List<Destination> destinations;
  final Function(int) onDestinationSelected;
  final ValueChanged<Destination> onDestinationTapped;
  final PageController pageController;

  const DestinationCarousel({
    super.key,
    required this.destinations,
    required this.onDestinationSelected,
    required this.onDestinationTapped,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 250,
      child: PageView.builder(
        controller: pageController,
        itemCount: destinations.length,
        onPageChanged: onDestinationSelected,
        itemBuilder: (context, index) {
          final destination = destinations[index];
          return GestureDetector(
            onTap: () => onDestinationTapped(destination),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      child: destination.imageUrls.isNotEmpty
                          ? Image.network(
                              destination.imageUrls[0],
                              width: 140,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  width: 140,
                                  height: double.infinity,
                                  child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                );
                              },
                            )
                          : Container(
                              width: 140,
                              height: double.infinity,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 40, color: Colors.grey),
                            ),
                    ),
                    
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              destination.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Rating
                            if (destination.rating != null)
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    destination.rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${destination.reviews?.length ?? 0} reviews)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            
                            const SizedBox(height: 8),
                            
                            // Description
                            Text(
                              destination.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const Spacer(),
                            
                            // Price
                            if (destination.price != null)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    formatRupiah(destination.price!),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}