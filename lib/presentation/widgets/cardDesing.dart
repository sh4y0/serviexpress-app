import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class CardDesing extends StatelessWidget {
  final Map<String, dynamic> cliente;
  const CardDesing({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xCC3646F5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/profile_default.png",
                  width: 50,
                  height: 50,
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    cliente["description"],
                    style: const TextStyle(color: Colors.white),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(10),
              child: const Text(
                "Ver",
                style: TextStyle(
                  color: AppColor.bgAll,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
