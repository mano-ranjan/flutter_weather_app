import 'package:equatable/equatable.dart';

class SearchState extends Equatable {
  final List<String> searchHistory;

  const SearchState({this.searchHistory = const []});

  SearchState copyWith({List<String>? searchHistory}) {
    return SearchState(searchHistory: searchHistory ?? this.searchHistory);
  }

  @override
  List<Object> get props => [searchHistory];
}
