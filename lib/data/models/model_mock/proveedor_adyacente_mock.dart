import 'dart:math';
import 'package:serviexpress_app/data/models/user_model.dart';

class ProveedorAdyacenteMock {
  static List<UserModel> getProveedoresAdyacentesPorCategoria(
    List<UserModel> providers,
    String categoria,
  ) {

    final random = Random();
    final List<UserModel> proveedores = [];

    for (int j = 0; j < providers.length; j++) {
      for (int i = 0; i < 3; i++) {
      const double spread = 0.0090;
      final double latOffset = (random.nextDouble() - 0.5) * spread;
      final double lngOffset = (random.nextDouble() - 0.5) * spread;

      final proveedor = UserModel(
        uid: '${categoria}_mock_${j}_$i',
        latitud: providers[j].latitud! + latOffset,
        longitud: providers[j].longitud! + lngOffset ,
        username: "Username $i",
        email: 'email$i@gmail.com',
        dni: '7${random.nextInt(1000000) + 1000000}',
        telefono: '9${random.nextInt(10000000) + 10000000}',
        nombres: "Nombre $i",
        apellidoPaterno: "Apellido Materno $i",
        apellidoMaterno: "Apellido Paterno $i",
        nombreCompleto: 'Nombre $i Apellido Materno $i "Apellido Paterno $i"',
        descripcion: "Descripcion$i",
        calificacion: double.parse(
          (4.0 + random.nextDouble()).toStringAsFixed(1),
        ),
        imagenUrl: 'assets/images/cleaner_${(i % 5) + 1}.jpg',
        token: 'fcm_token_example_${100 + i}',
        especialidad: 'Limpieza',
        rol: 'Proveedor',
        resenias: [],
        createdAt: DateTime.now().subtract(Duration(days: random.nextInt(365))),
      );
      proveedores.add(proveedor);
    }
    }
    
    return proveedores;
  }
}
