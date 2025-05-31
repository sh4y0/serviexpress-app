import 'package:serviexpress_app/data/models/category_model.dart';

class CategoryMock{
  final String name;
  final String iconPath;

  CategoryMock({
    required this.name,
    required this.iconPath,
  });
  
  static List<CategoryModel> getCategories() {
    return [
      CategoryModel(
        id: '1',
        name: 'Limpieza',
        iconPath: 'assets/icons/ic_clean.svg',
      ),
      CategoryModel(
        id: '2',
        name: 'Reparador',
        iconPath: 'assets/icons/ic_repair.svg',
      ),
      CategoryModel(
        id: '3',
        name: 'Pintor',
        iconPath: 'assets/icons/ic_pest.svg',
      ),
      CategoryModel(
        id: '4',
        name: 'Mecanico',
        iconPath: 'assets/icons/ic_food.svg',
      ),
      CategoryModel(
        id: '5',
        name: 'Electronico',
        iconPath: 'assets/icons/ic_clean.svg',
      ),
      CategoryModel(
        id: '6',
        name: 'Striper',
        iconPath: 'assets/icons/ic_repair.svg',
      ),
    ];
  }
}
