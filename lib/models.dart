class SubLista {
  String nombre;
  SubLista({required this.nombre});

  Map<String, dynamic> toJson() => {'nombre': nombre};

  factory SubLista.fromJson(Map<String, dynamic> json) => SubLista(
    nombre: json['nombre'],
  );
}

class Lista {
  String nombre;
  List<SubLista> subListas;

  Lista({required this.nombre, required this.subListas});

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'subListas': subListas.map((subLista) => subLista.toJson()).toList(),
  };

  factory Lista.fromJson(Map<String, dynamic> json) => Lista(
    nombre: json['nombre'],
    subListas: (json['subListas'] as List)
        .map((item) => SubLista.fromJson(item))
        .toList(),
  );
}
