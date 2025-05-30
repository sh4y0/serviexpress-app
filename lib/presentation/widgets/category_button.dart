import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/data/models/model_mock/category_mock.dart';

class CategoryButton extends StatelessWidget {
  final CategoryMock category;
  final int index;
  final ValueNotifier<int> selectedCategoryIndexNotifier;

  const CategoryButton({
    super.key,
    required this.category,
    required this.index,
    required this.selectedCategoryIndexNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedCategoryIndexNotifier,
      builder: (context, selectedIndexValue, _) {
        final bool isSelected = index == selectedIndexValue;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: MaterialButton(
            padding: const EdgeInsets.all(10),
            height: 39,
            minWidth: 98,
            color:
                isSelected ? const Color(0xFF3645f5) : const Color(0xFF263089),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              // side: BorderSide(
              //   color:
              //       isSelected ? const Color(0xFF3645f5) : AppColor.textInput,
              //   width: 2,
              // ),
            ),
            onPressed: () {
              selectedCategoryIndexNotifier.value = index;
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  category.iconPath,
                  width: 20,
                  height: 15,
                  colorFilter: ColorFilter.mode(
                    isSelected ? Colors.white : AppColor.textInput,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColor.textInput,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
