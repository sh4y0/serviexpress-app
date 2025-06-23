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
        iconPath: 'assets/icons/ic_clean3.png',
      ),
      CategoryModel(
        id: '2',
        name: 'Tecno',
        iconPath: 'assets/icons/ic_laptop2.png',
      ),
      CategoryModel(
        id: '3',
        name: 'Soldadura',
        iconPath: 'assets/icons/ic_welding2.png',
      ),
      CategoryModel(
        id: '4',
        name: 'Electricidad',
        iconPath: 'assets/icons/ic_electricity2.png',
      ),
      CategoryModel(
        id: '5',
        name: 'Pintura',
        iconPath: 'assets/icons/ic_brush2.png',
      ),
      CategoryModel(
        id: '6',
        name: 'Plomeria',
        iconPath: 'assets/icons/ic_plumber2.png',
      ),
      CategoryModel(
        id: '7',
        name: 'Stripper',
        iconPath: 'assets/icons/ic_stripper.png',
      ),
    ];
  }
}
