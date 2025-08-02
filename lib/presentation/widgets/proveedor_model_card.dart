import 'package:flutter/material.dart';
import 'package:serviexpress_app/data/models/user_model.dart';

class ProveedorModelCard extends StatelessWidget {
  final UserModel proveedor;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const ProveedorModelCard({
    super.key,
    required this.proveedor,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0c0d23),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3645f5).withAlpha((0.3 * 255).toInt()),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1B1B2E),
                          ),
                          child:
                              proveedor.imagenUrl != ''
                                  ? ClipOval(
                                    child: Image.asset(
                                      proveedor.imagenUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              proveedor.nombres,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${proveedor.calificacion}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 5,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
