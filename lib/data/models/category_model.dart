class CategoryModel {
  final String name;
  final String iconPath;

  CategoryModel({
    required this.name,
    required this.iconPath,
  });
  static List<CategoryModel> getCategories() {
    return [
      CategoryModel(
        name: 'Limpieza',
        iconPath: 'assets/icons/ic_clean.svg',
      ),
      CategoryModel(
        name: 'Reparador',
        iconPath: 'assets/icons/ic_repair.svg',
      ),
      CategoryModel(
        name: 'Pintor',
        iconPath: 'assets/icons/ic_pest.svg',
      ),
      CategoryModel(
        name: 'Mecanico',
        iconPath: 'assets/icons/ic_food.svg',
      ),
      CategoryModel(
        name: 'Electronico',
        iconPath: 'assets/icons/ic_clean.svg',
      ),
      CategoryModel(
        name: 'Striper',
        iconPath: 'assets/icons/ic_repair.svg',
      ),
    ];
  }
  static List<String> getCategoryNames() {
    return getCategories().map((category) => category.name).toList();
  }
  static List<String> getCategoryIcons() {
    return getCategories().map((category) => category.iconPath).toList();
  }
  static List<String> getCategoryIconsByName(String name) {
    return getCategories()
        .where((category) => category.name == name)
        .map((category) => category.iconPath)
        .toList();
  }
}
