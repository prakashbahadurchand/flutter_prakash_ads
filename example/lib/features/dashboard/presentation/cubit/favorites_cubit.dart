import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/article_item.dart';

@lazySingleton
class FavoritesCubit extends Cubit<List<ArticleItem>> {
  FavoritesCubit() : super([]) {
    _loadFavorites();
  }

  static const String _keyFavorites = 'saved_favorite_article_ids';

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_keyFavorites) ?? [];
    if (savedIds.isNotEmpty) {
      final favorites =
          sampleArticles.where((a) => savedIds.contains(a.id)).toList();
      emit(favorites);
    }
  }

  bool isFavorite(String articleId) {
    return state.any((a) => a.id == articleId);
  }

  Future<void> toggleFavorite(ArticleItem article) async {
    final exists = isFavorite(article.id);
    List<ArticleItem> updated;
    if (exists) {
      updated = state.where((a) => a.id != article.id).toList();
    } else {
      updated = [...state, article];
    }
    emit(updated);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyFavorites,
      updated.map((a) => a.id).toList(),
    );
  }
}
