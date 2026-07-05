class MenuCategoryModel {
  final String id;
  final String name;

  const MenuCategoryModel({required this.id, required this.name});
}

class MenuItemModel {
  final String id;
  final String categoryId;
  final String name;
  final String imagePath;
  final int price;

  const MenuItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.imagePath,
    required this.price,
  });
}
