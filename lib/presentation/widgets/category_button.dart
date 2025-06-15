import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/data/models/model_mock/category_mock.dart';

class CategoryButton extends StatelessWidget {
  final ValueNotifier<int> selectedCategoryIndexNotifier;
  final bool categoriaError;
  final GlobalKey? firstCategoryKey;
  final Function(int category) onCategorySelected;

  const CategoryButton({
    super.key,
    required this.selectedCategoryIndexNotifier,
    required this.categoriaError,
    this.firstCategoryKey,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedCategoryIndexNotifier,
      builder: (context, selectedIndex, _) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 10, right: 10, bottom: 10),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var category = CategoryMock.getCategories()[index];
            final bool isSelected = index == selectedIndex;
            final bool showErrorBorder = categoriaError && selectedIndex == -1;

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                decoration:
                    showErrorBorder
                        ? BoxDecoration(
                          border: Border.all(
                            color: Colors.redAccent,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        )
                        : null,
                child: MaterialButton(
                  key: index == 0 ? firstCategoryKey : null,
                  padding: const EdgeInsets.all(10),
                  height: 39,
                  minWidth: 98,
                  color:
                      isSelected
                          ? const Color(0xFF3645f5)
                          : const Color(0xFF263089),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  onPressed: () {
                    onCategorySelected(index);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        category.iconPath,
                        width: 15,
                        height: 15,
                        colorFilter: ColorFilter.mode(
                          isSelected ? Colors.white : AppColor.textInput,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColor.textInput,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: CategoryMock.getCategories().length,
        );
      },
    );
  }
}
