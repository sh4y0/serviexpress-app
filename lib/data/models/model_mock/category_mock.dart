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
        iconPath: 'assets/icons/ic_clean2.svg',
      ),
      CategoryModel(
        id: '2',
        name: 'Tecno',
        iconPath: 'assets/icons/ic_laptop.svg',
      ),
      CategoryModel(
        id: '3',
        name: 'Soldadura',
        iconPath: 'assets/icons/ic_welding.svg',
      ),
      CategoryModel(
        id: '4',
        name: 'Electricidad',
        iconPath: 'assets/icons/ic_electricity.svg',
      ),
      CategoryModel(
        id: '5',
        name: 'Pintura',
        iconPath: 'assets/icons/ic_brush.svg',
      ),
      CategoryModel(
        id: '6',
        name: 'Plomeria',
        iconPath: 'assets/icons/ic_plumber.svg',
      ),
      CategoryModel(
        id: '7',
        name: 'Stripper',
        iconPath: 'assets/icons/ic_repair.svg',
      ),
    ];
  }
}
