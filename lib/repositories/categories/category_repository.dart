import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/repositories/categories/icategory_repository.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../shared/constances/table_constant.dart';

final categoryProviderRepository = Provider((ref) {
  return CategoryRepository(ref);
});

class CategoryRepository extends ICategoryRepository {
  final Ref ref;
  CategoryRepository(this.ref);
  @override
  Future<List<CategoryModel>> getAllCategories() async {
    List<CategoryModel> list = [];

    await ref
        .read(posDbProvider)
        .database
        .query(TableConstant.categoryTable, orderBy: "sort , id")
        .then((response) {
      list = List.from((response).map((e) => CategoryModel.fromJson(e)));
    });

    return list;
  }

  @override
  Future<CategoryModel> addCategory(CategoryModel c) async {
    CategoryModel category = CategoryModel.second();
    await ref
        .read(posDbProvider)
        .database
        .insert(TableConstant.categoryTable, c.toJsonWithoutId())
        .then((value) {
      category = c;
      c.id = value;
    }).catchError((error) {
      throw Exception(error);
    });
    return category;
  }

  @override
  FutureEither<CategoryModel> updateCategory(CategoryModel c) async {
    CategoryModel category = CategoryModel.second();
    try {
      // First get the original category from database to preserve sort
      final originalResult = await ref.read(posDbProvider).database.rawQuery(
          "select * from ${TableConstant.categoryTable} where id=?", [c.id]);

      if (originalResult.isEmpty) {
        return left(FailureModel("Category not found"));
      }

      final originalCategory = CategoryModel.fromJson(originalResult.first);

      // Update only the specified fields, keeping the original sort
      final response = await ref.read(posDbProvider).database.rawUpdate(
          "update ${TableConstant.categoryTable} set name='${c.name}', color='${c.color}' ,section='${c.sectionType?.name}' , hideOnMenu='${c.hideOnMenu == true ? 1 : 0}' where id=${c.id}");

      // Return category with updated fields but original sort preserved
      CategoryModel updatedCategory = c.copyWith(
        sort: originalCategory.sort, // Preserve original sort from database
      );

      return right(updatedCategory);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  Future deleteCategory(int categoryId) async {
    await ref.read(posDbProvider).database.rawDelete(
        "delete from ${TableConstant.categoryTable} where id=?",
        ['$categoryId']).then((value) async {
      //! delete all products related
      await ref.read(posDbProvider).database.rawUpdate(
          "update  ${TableConstant.productTable} set isActive =0  where categoryId=?",
          ['$categoryId']);

//!Todo:delete all details receipt related
    }).catchError((error) {
      throw Exception(error);
    });
  }

  @override
  FutureEither<List<CategoryModel>> fetchCategoriesByQuery(String query) async {
    List<CategoryModel> categories = [];

    try {
      final response = await ref
          .read(posDbProvider)
          .database
          .query(TableConstant.categoryTable, where: "name  like '%$query%'");

      if (response.isNotEmpty) {
        categories = List.from(response as List)
            .map((e) => CategoryModel.fromJson(e))
            .toList();
      } else {
        return left(FailureModel("no data found"));
      }
      return right(categories);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither reOrderCategories(
      {required List<CategoryModel> categories}) async {
    try {
      for (var i = 0; i < categories.length; i++) {
        await ref.read(posDbProvider).database.rawUpdate(
              "update ${TableConstant.categoryTable} set sort=$i where id=${categories[i].id}",
            );
      }

      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  //! @override
  //! Future<List<NotesModel>> getAllNotes() async {
  //!   List<NotesModel> list = [];
  //!   await ref.read(posDbProvider).database.query(TableConstant.notesTable).then((response) {
  //!     list = List.from((response).map((e) => NotesModel.fromJson(e)));
  //!   });

  //!   return list;
  //! }
}
