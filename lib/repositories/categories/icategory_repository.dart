import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';

abstract class ICategoryRepository {
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel> addCategory(CategoryModel c);
  FutureEither<CategoryModel> updateCategory(CategoryModel c);
  Future deleteCategory(int categoryId);

  // Future<List<NotesModel>> getNotesByCategoryId(int categroyId);
  // //Future<List<NotesModel>> getAllNotes();
  // FutureEitherVoid addNotesToCategory(List<NotesModel> notes, int cateogoryId);

  FutureEither<List<CategoryModel>> fetchCategoriesByQuery(String query);
  FutureEither reOrderCategories({required List<CategoryModel> categories});
}
