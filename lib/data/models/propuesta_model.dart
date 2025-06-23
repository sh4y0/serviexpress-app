class PropuestaModel {
  String id;
  String serviceId;
  String workerId;
  String clientId;
  double precio;
  String descripcion;

  PropuestaModel({
    required this.id,
    required this.serviceId,
    required this.workerId,
    required this.clientId,
    required this.precio,
    required this.descripcion,
  });

  factory PropuestaModel.fromJson(Map<String, dynamic> json) {
    return PropuestaModel(
      id: json['id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      workerId: json['workerId'] ?? '',
      clientId: json['clientId'] ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      descripcion: json['descripcion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'workerId': workerId,
      'clientId': clientId,
      'precio': precio,
      'descripcion': descripcion,
    };
  }
}
