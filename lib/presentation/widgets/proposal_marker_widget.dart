import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProposalMarkerWidget extends StatelessWidget {
  final String price;
  final String rating;

  const ProposalMarkerWidget({
    super.key,
    required this.price,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'S/$price',
            style: const TextStyle(
              color: Color.fromRGBO(42, 52, 216, 1),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              Text(
                rating,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MarkerWithProposal {
  final String markerId;
  final LatLng position;
  final String price;
  final String rating;
  final Offset? screenPosition;

  MarkerWithProposal({
    required this.markerId,
    required this.position,
    required this.price,
    required this.rating,
    this.screenPosition,
  });

  MarkerWithProposal copyWith({
    String? markerId,
    LatLng? position,
    String? price,
    String? rating,
    Offset? screenPosition,
  }) {
    return MarkerWithProposal(
      markerId: markerId ?? this.markerId,
      position: position ?? this.position,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      screenPosition: screenPosition ?? this.screenPosition,
    );
  }
}
