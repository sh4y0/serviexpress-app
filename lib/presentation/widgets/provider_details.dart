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
            maxChildSize: 0.8,
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

class ScreenClientData extends StatefulWidget {
  const ScreenClientData({
    super.key,
    required this.cliente,
    required this.scrollController,
  });

  final Map<String, dynamic> cliente;
  final ScrollController scrollController;

  @override
  State<ScreenClientData> createState() => _ScreenClientDataState();
}

class _ScreenClientDataState extends State<ScreenClientData> {
  List<String> precio = ["150", "200", "250"];
  int selectedPrecio = 0;
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
          controller: widget.scrollController,
          shrinkWrap: true,
          children: [
            Container(
              height: 5,
              margin: const EdgeInsets.only(bottom: 20, left: 80, right: 80),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColor.dotColor,
              ),
            ),
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
                        "${widget.cliente["name"]}",
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
                            style: TextStyle(
                              color: AppColor.txtPrice,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/ic_distance.svg",
                            width: 23,
                            height: 23,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${widget.cliente["distance"]}",
                            style: const TextStyle(
                              color: AppColor.dotColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
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
                    "${widget.cliente["description"]}",
                    style: const TextStyle(color: AppColor.txtBooking),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: (widget.cliente["images"] as List).length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Image.asset(
                    widget.cliente["images"][index],
                    width: 90,
                    height: 90,
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Escoge el precio:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Row(
            //   children: [
            //   Expanded(
            //     child: Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     children: List.generate(precio.length, (index) {
            //       final isSelected = selectedPrecio == index;
            //       return Padding(
            //       padding: EdgeInsets.only(right: index < precio.length - 1 ? 10 : 0),
            //       child: GestureDetector(
            //         onTap: () {
            //         setState(() {
            //           selectedPrecio = index;
            //         });
            //         },
            //         child: Container(
            //         padding: const EdgeInsets.symmetric(
            //           vertical: 8,
            //           horizontal: 12,
            //         ),
            //         decoration: BoxDecoration(
            //           color: isSelected ? AppColor.btnColor : Colors.transparent,
            //           borderRadius: BorderRadius.circular(6),
            //           border: Border.all(
            //           color: isSelected ? AppColor.btnColor : AppColor.btnColor,
            //           width: 1.5,
            //           ),
            //         ),
            //         child: Text(
            //           "\$${precio[index]}",
            //           style: TextStyle(
            //           color: isSelected ? Colors.white : AppColor.btnColor,
            //           fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //         ),
            //       ),
            //       );
            //     }),
            //     ),
            //   ),
            //   TextButton.icon(
            //     onPressed: () {
            //     mostrarPropuesta(context);
            //     },
            //     label: const Text("Otro"),
            //     icon: const Icon(Icons.add),
            //     style: ButtonStyle(
            //     overlayColor: WidgetStateProperty.all(Colors.transparent),
            //     splashFactory: NoSplash.splashFactory,
            //     ),
            //   ),
            //   ],
            // ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => mostrarPropuesta(context),
              child: const InputPresupuesto().inptDesing(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.bgMsgUser,
                ),
                child: const Text(
                  "No me interesa",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.btnColor,
                ),
                child: const Text(
                  "Aceptar",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InputPresupuesto extends StatelessWidget {
  const InputPresupuesto({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Presupuesto",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        inptDesing(),
        const SizedBox(height: 10),
        const Text(
          "Propuesta",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Describe detalladamente el servicio que ofrecerás",
          style: TextStyle(color: AppColor.txtBooking),
        ),
        const SizedBox(height: 10),
        TextField(
          maxLines: 6,
          style: const TextStyle(color: AppColor.bgMsgUser),
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColor.colorInput,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColor.bgMsgUser,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          child: ElevatedButton(
            onPressed: () {},
            child: const Text(
              "Crear Propuesta",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Row inptDesing() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 17.5),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColor.colorInput,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
          child: const Text(
            "S/",
            style: TextStyle(color: AppColor.txtBooking, fontSize: 17),
          ),
        ),
        const Expanded(
          child: TextField(
            style: TextStyle(color: AppColor.bgMsgUser, fontSize: 18),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                borderSide: BorderSide(color: AppColor.colorInput, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                borderSide: BorderSide(color: AppColor.bgMsgUser, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void mostrarPropuesta(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Center(
        child: SingleChildScrollView(
          child: AlertDialog(
            backgroundColor: AppColor.bgContendeor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: const InputPresupuesto(),
            ),
          ),
        ),
      );
    },
  );
}
