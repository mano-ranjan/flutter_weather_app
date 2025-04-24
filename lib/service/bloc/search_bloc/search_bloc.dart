import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/service/bloc/search_bloc/search_event.dart';
import 'package:weather_app/service/bloc/search_bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  static const String _prefsKey = 'search_history';

  SearchBloc() : super(const SearchState()) {
    on<AddSearchQueryEvent>(_addSearchQuery);
    on<ClearSearchHistoryEvent>(_clearSearchHistory);

    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_prefsKey) ?? [];
    add(AddSearchQueryEvent(''));
  }

  Future<void> _addSearchQuery(
    AddSearchQueryEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) return;

    // Add query to history, removing duplicates and limit to 5 entries
    final currentHistory = List<String>.from(state.searchHistory);
    currentHistory.remove(event.query); // Remove if exists
    currentHistory.insert(0, event.query); // Add to beginning

    final updatedHistory = currentHistory.take(5).toList();

    emit(state.copyWith(searchHistory: updatedHistory));

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_prefsKey, updatedHistory);
  }

  Future<void> _clearSearchHistory(
    ClearSearchHistoryEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchState());

    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_prefsKey);
  }
}
