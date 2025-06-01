import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class ProviderDetails extends StatefulWidget {
  final Map<String, dynamic> cliente;
  final String? mapStyle;

  const ProviderDetails({
    super.key,
    required this.cliente,
    required this.mapStyle,
  });

  @override
  State<ProviderDetails> createState() => _ProviderDetailsState();
}

class _ProviderDetailsState extends State<ProviderDetails> {
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(widget.mapStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cliente["name"])),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-8.1052, -79.0264),
              zoom: 15,
            ),
            onMapCreated: _onMapCreated,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.30,
            minChildSize: 0.30,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return ScreenClientData(
                cliente: widget.cliente,
                scrollController: scrollController,
              );
            },
          ),
        ],
      ),
    );
  }
}

class ScreenClientData extends StatelessWidget {
  const ScreenClientData({
    super.key,
    required this.cliente,
    required this.scrollController,
  });

  final Map<String, dynamic> cliente;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          controller: scrollController,
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/images/profile_default.png",
                      width: 45,
                      height: 45,
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Icon(Icons.star, color: AppColor.bgStr),
                        SizedBox(width: 4),
                        Text(
                          "4.0",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${cliente["name"]}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SvgPicture.asset("assets/icons/ic_location.svg"),
                          const SizedBox(width: 4),
                          const Text(
                            "Moche 135",
                            style: TextStyle(color: AppColor.txtPrice),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${cliente["distance"]}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.txtPrice,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      "assets/icons/ic_gochat.svg",
                      width: 25,
                      height: 25,
                    ),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColor.bgMsgUser,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Detalles de servicios",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${cliente["description"]}",
                    style: const TextStyle(color: AppColor.txtBooking),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: (cliente["images"] as List).length,
                      separatorBuilder:
                          (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return Image.asset(
                          cliente["images"][index],
                          width: 90,
                          height: 90,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
