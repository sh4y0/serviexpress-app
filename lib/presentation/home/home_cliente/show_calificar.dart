import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class ShowCalificar extends StatelessWidget {
  const ShowCalificar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth > 400 ? 400 : double.infinity,
          ),
          child: Stack(
            children: [
              const Material(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60, horizontal: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image(image: AssetImage("assets/gifs/calification.gif")),
                      SizedBox(height: 10),
                      Text(
                        "Gracias por tu comentario",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Tus reseñas hacen de esta\n aplicación mejor",
                        style: TextStyle(
                          color: AppColor.txtPropuesta,
                          fontSize: 17,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
