import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class AddSearchQueryEvent extends SearchEvent {
  final String query;

  const AddSearchQueryEvent(this.query);

  @override
  List<Object> get props => [query];
}

class ClearSearchHistoryEvent extends SearchEvent {}
