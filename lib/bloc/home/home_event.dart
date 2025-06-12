import 'package:flutter_invoice_app/bloc/base/bloc_event.dart';

abstract class HomeEvent extends BlocEvent {}

class LoadHomeDataEvent extends HomeEvent {}

class RefreshHomeDataEvent extends HomeEvent {}

class ToggleFavoriteEvent extends HomeEvent {
  final String itemId;
  final String itemName;
  final String itemType;
  final String route;
  final Map<String, dynamic>? parameters;

  ToggleFavoriteEvent({
    required this.itemId,
    required this.itemName,
    required this.itemType,
    required this.route,
    this.parameters,
  });
}

class NavigateToItemEvent extends HomeEvent {
  final String route;
  final Map<String, dynamic>? parameters;

  NavigateToItemEvent({
    required this.route,
    this.parameters,
  });
}
