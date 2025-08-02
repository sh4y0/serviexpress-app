import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/presentation/resources/constants/widgets/calification_strings.dart';
import 'package:serviexpress_app/presentation/widgets/show_calificar.dart';

class CalificacionScreen extends StatefulWidget {
  const CalificacionScreen({super.key});

  @override
  State<CalificacionScreen> createState() => _CalificacionScreenState();
}

class _CalificacionScreenState extends State<CalificacionScreen> {
  void mostrarAlert() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: ShowCalificar(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgChat,
      appBar: AppBar(
        backgroundColor: AppColor.bgChat,
        leading: IconButton(
          onPressed: () {},
          icon: Transform.translate(
            offset: const Offset(4, 0),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          style: IconButton.styleFrom(backgroundColor: AppColor.bgBack),
        ),
        title: const Text(
          CalificationStrings.title,
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Image(
                    image: AssetImage("assets/images/profile_default.png"),
                    width: 220,
                    height: 220,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    CalificationStrings.fullName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    CalificationStrings.roleCleaner,
                    style: TextStyle(color: AppColor.textInput, fontSize: 17),
                  ),
                  const SizedBox(height: 10),
                  RatingBar(
                    initialRating: 4,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemSize: 45,
                    itemPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 5,
                    ),
                    glow: false,
                    ratingWidget: RatingWidget(
                      full: Container(
                        decoration: BoxDecoration(
                          color: AppColor.bgMsgClient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.star, color: AppColor.bgStar),
                      ),
                      half: Container(
                        decoration: BoxDecoration(
                          color: AppColor.bgMsgClient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.star_half,
                          color: AppColor.bgStar,
                        ),
                      ),
                      empty: Container(
                        decoration: BoxDecoration(
                          color: AppColor.bgMsgClient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.star,
                          color: AppColor.loginSelect,
                        ),
                      ),
                    ),
                    onRatingUpdate: (rating) {},
                  ),
                  const SizedBox(height: 20),
                  _buildTextFieldComent(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: AppColor.btnColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: mostrarAlert,
                      child: const Text(
                        CalificationStrings.send,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildTextFieldComent() {
  return TextField(
    maxLines: 8,
    cursorColor: AppColor.colorInput,
    style: const TextStyle(color: AppColor.txtMsg),
    decoration: InputDecoration(
      hintText: CalificationStrings.commentHint,
      hintStyle: const TextStyle(color: AppColor.txtMsg),
      filled: true,
      fillColor: AppColor.bgLabel,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
    ),
  );
}
