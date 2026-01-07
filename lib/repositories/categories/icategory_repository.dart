import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';

abstract class ICategoryRepository {
  FutureEither<List<CategoryModel>> getAllCategories();
  FutureEither<CategoryModel> addCategory(CategoryModel c);
  FutureEither<CategoryModel> updateCategory(CategoryModel c);
  FutureEitherVoid deleteCategory(int categoryId);

  // Future<List<NotesModel>> getNotesByCategoryId(int categroyId);
  // //Future<List<NotesModel>> getAllNotes();
  // FutureEitherVoid addNotesToCategory(List<NotesModel> notes, int cateogoryId);

  FutureEither<List<CategoryModel>> fetchCategoriesByQuery(String query);
  FutureEitherVoid reOrderCategories({required List<CategoryModel> categories});
}
