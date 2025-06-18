import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/data/models/service.dart';
import 'package:serviexpress_app/data/service/location_service.dart';

class CardDesing extends StatelessWidget {
  final ServiceComplete service;
  final VoidCallback onViewDetails;

  const CardDesing({
    super.key,
    required this.service,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: Future.wait([
        LocationService.getAddressFromLatLng(
          service.cliente.latitud!,
          service.cliente.longitud!,
        ),
        LocationService.getDistanceFromCurrentLocation(
          service.cliente.latitud!,
          service.cliente.longitud!,
        ),
      ]),
      builder: (context, snapshot) {
        final direccion =
            snapshot.hasData ? snapshot.data![0] : "Obteniendo dirección...";
        final distancia =
            snapshot.hasData ? snapshot.data![1] : "Calculando distancia...";

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.bgCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: SizedBox(
                              width: 52,
                              height: 52,
                              child:
                                  service.cliente.imagenUrl != null
                                      ? FadeInImage.assetNetwork(
                                        placeholder: "assets/images/avatar.png",
                                        image: service.cliente.imagenUrl!,
                                        fit: BoxFit.cover,
                                        imageErrorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Image.asset(
                                            "assets/images/avatar.png",
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                      : Image.asset(
                                        "assets/images/avatar.png",
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        //const SizedBox(height: 10),
                        // Row(
                        //   children: [
                        //     const Icon(Icons.star, color: AppColor.bgStr),
                        //     const SizedBox(width: 4),
                        //     Text(
                        //       service.cliente.calificacion.toString(),
                        //       style: const TextStyle(
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            service.cliente.nombreCompleto,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/ic_location.svg",
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  direccion,
                                  style: const TextStyle(
                                    color: AppColor.txtPrice,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/ic_distance.svg",
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                  AppColor.bgDistance,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                distancia,
                                style: const TextStyle(
                                  color: AppColor.bgDistance,
                                  fontSize: 12
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // const SizedBox(width: 16),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: AppColor.txtPrice,
                    //     borderRadius: BorderRadius.circular(50),
                    //   ),
                    //   child: IconButton(
                    //     onPressed: () {},
                    //     icon: SvgPicture.asset(
                    //       "assets/icons/ic_gochat.svg",
                    //       width: 25,
                    //       height: 25,
                    //     ),
                    //     color: Colors.white,
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Detalle del servicio",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  service.service.descripcion,
                  style: const TextStyle(color: AppColor.txtDetalle, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColor.bgMsgUser,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onViewDetails,
                        child: const Text("Ver más"),
                      ),
                      // child: ElevatedButton(
                      //
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: AppColor.bgMsgUser,
                      //   ),
                      //   child: const Text(
                      //     "Ver detalles",
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(56, 109, 243, 1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onViewDetails,
                        child: const Text("Aceptar"),
                      ),
                      // child: ElevatedButton(
                      //   onPressed: () {
                      //     // Acción para aceptar
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: AppColor.bgAll,
                      //   ),
                      //   child: const Text(
                      //     "Aceptar",
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
