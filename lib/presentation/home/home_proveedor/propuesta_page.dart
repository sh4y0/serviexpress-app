import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class PropuestaScreen extends StatefulWidget {
  const PropuestaScreen({super.key});

  @override
  State<PropuestaScreen> createState() => _PropuestaScreenState();
}

class _PropuestaScreenState extends State<PropuestaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgPropuesta,
      appBar: AppBar(
        backgroundColor: AppColor.bgPropuesta,
        leading: IconButton(
          onPressed: () {},
          icon: Transform.translate(
            offset: const Offset(4, 0),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          style: IconButton.styleFrom(backgroundColor: AppColor.bgBack),
        ),
        title: const Text(
          "Propuesta de Fedor",
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/ic_person.svg",
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Servicio de Limpieza",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.bgState,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Esperando",
                        style: TextStyle(color: AppColor.txtState),
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      "Booking ID: ",
                      style: TextStyle(
                        color: AppColor.txtBooking,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      "#5462",
                      style: TextStyle(color: AppColor.txtId, fontSize: 11),
                    ),
                  ],
                ),
                const Text(
                  "\$80.00",
                  style: TextStyle(
                    color: AppColor.txtPrice,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                buildInfoRow("Dia y Hora", "16 Julio 2023, 12:35 AM"),
                buildInfoRow("Proveedor", "Feder"),
                buildInfoRow("Subservicio", "Vitrinas"),

                const SizedBox(height: 15),

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
                  "Lorem ipsum dolor sit amet consectetur. Nulla ac mauris egestas placerat. Dictum integer tempor feugiat pellentesque. Duis lacus aliquet pharetra cursus libero. Donec libero arcu neque urna eget sed. Erat etiam arcu ultrices purus. Lorem ipsum dolor sit amet consectetur. Nulla ac mauris egestas placerat. Dictum integer tempor feugiat pellentesque. Duis lacus aliquet pharetra cursus libero. Donec libero arcu neque urna eget sed. Erat etiam arcu ultrices purus. Lorem ipsum dolor sit amet consectetur. Nulla ac mauris egestas placerat. Dictum integer tempor feugiat pellentesque. Duis lacus aliquet pharetra cursus libero. Donec libero arcu neque urna eget sed. \nErat etiam arcu ultrices purus. \nLorem ipsum dolor sit amet consectetur. Nulla ac mauris egestas placerat.",
                  style: TextStyle(color: AppColor.txtPropuesta),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.btnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text(
                      "Aceptar Propuesta",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildInfoRow(String label, String value) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColor.txtBooking)),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Divider(color: AppColor.bgDivider),
      const SizedBox(height: 8),
    ],
  );
}
