import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/data/models/service.dart';

class ProviderDetails extends StatefulWidget {
  final ServiceComplete service;
  final String? mapStyle;

  const ProviderDetails({
    super.key,
    required this.service,
    required this.mapStyle,
  });

  @override
  State<ProviderDetails> createState() => _ProviderDetailsState();
}

class _ProviderDetailsState extends State<ProviderDetails> {
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.service.cliente.nombreCompleto)),
      body: Stack(
        children: [
          GoogleMap(
            style: widget.mapStyle,
            initialCameraPosition: const CameraPosition(
              target: LatLng(-8.1052, -79.0264),
              zoom: 15,
            ),
            onMapCreated: _onMapCreated,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.30,
            minChildSize: 0.30,
            maxChildSize: 0.65, //mod 8
            builder: (context, scrollController) {
              return ScreenClientData(
                service: widget.service,
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
    required this.service,
    required this.scrollController,
  });

  final ServiceComplete service;
  final ScrollController scrollController;

  @override
  State<ScreenClientData> createState() => _ScreenClientDataState();
}

class _ScreenClientDataState extends State<ScreenClientData> {
  String? presupuestoPersonalizado;
  String? propuestaTexto;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              margin: const EdgeInsets.only(bottom: 20, left: 80, right: 80),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColor.dotColor,
              ),
            ),
            Expanded(
              child: ListView(
                controller: widget.scrollController,
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
                              widget.service.cliente.nombreCompleto,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/ic_location.svg",
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "U. Privada del Norte",
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
                                const Text(
                                  "A 1 min de ti",
                                  style: TextStyle(color: AppColor.bgDistance),
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
                          widget.service.service.descripcion,
                          style: const TextStyle(color: AppColor.txtBooking),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (widget.service.service.fotos != null &&
                      widget.service.service.fotos!.isNotEmpty)
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.service.service.fotos!.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return Image.asset(
                            widget.service.service.fotos![index],
                            width: 90,
                            height: 90,
                          );
                        },
                      ),
                    ),

                  widget.service.service.videos != null &&
                          widget.service.service.videos!.isNotEmpty
                      ? SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.service.service.videos!.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            return Image.asset(
                              widget.service.service.videos![index],
                              width: 90,
                              height: 90,
                            );
                          },
                        ),
                      )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 15),
                  const Text(
                    "Ingresa el precio:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  const SizedBox(height: 10),
                  InputPresupuestoLauncher(
                    presupuesto: presupuestoPersonalizado,
                    onTap: () async {
                      final result = await mostrarPropuesta(
                        context,
                        initialValue: presupuestoPersonalizado,
                        initialpropuesta: propuestaTexto,
                      );
                      if (result != null) {
                        setState(() {
                          presupuestoPersonalizado = result["presupuesto"];
                          propuestaTexto = result["propuesta"];
                        });
                      }
                    },
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
                        "Enviar",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
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

class InputPresupuesto extends StatefulWidget {
  final String? initialValue;
  final String? initialpropuesta;
  const InputPresupuesto({super.key, this.initialValue, this.initialpropuesta});

  @override
  State<InputPresupuesto> createState() => _InputPresupuestoState();
}

class _InputPresupuestoState extends State<InputPresupuesto> {
  late final TextEditingController _controller;
  late final TextEditingController _descripcionController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? "");
    _descripcionController = TextEditingController(
      text: widget.initialpropuesta ?? "",
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 17.5,
              ),
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
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: AppColor.bgMsgUser, fontSize: 18),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    borderSide: BorderSide(
                      color: AppColor.colorInput,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    borderSide: BorderSide(
                      color: AppColor.bgMsgUser,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
          controller: _descripcionController,
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
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isEmpty) {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: AppColor.bgMsgClient,
                      icon: const Icon(
                        Icons.error_outline_outlined,
                        color: Colors.red,
                        size: 50,
                      ),
                      title: const Text("Campo Obligatorio"),
                      content: const Text(
                        "Por favor ingresa un valor para el presupuesto.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
              );
              return;
            }
            Navigator.of(context).pop({
              "presupuesto": _controller.text,
              "propuesta": _descripcionController.text,
            });
          },
          child: const Text(
            "Crear Propuesta",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class InputPresupuestoLauncher extends StatelessWidget {
  final VoidCallback onTap;
  final String? presupuesto;

  const InputPresupuestoLauncher({
    super.key,
    required this.onTap,
    this.presupuesto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 17.5,
                ),
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
              Expanded(
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(text: presupuesto),
                    style: const TextStyle(
                      color: AppColor.txtBooking,
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        borderSide: BorderSide(
                          color: AppColor.bgMsgUser,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        borderSide: BorderSide(
                          color: AppColor.colorInput,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<Map<String, String>?> mostrarPropuesta(
  BuildContext context, {
  String? initialValue,
  String? initialpropuesta,
}) {
  return showDialog<Map<String, String>>(
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
              child: InputPresupuesto(
                initialValue: initialValue,
                initialpropuesta: initialpropuesta,
              ),
            ),
          ),
        ),
      );
    },
  );
}
