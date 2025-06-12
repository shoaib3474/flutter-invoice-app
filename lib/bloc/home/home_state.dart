import 'package:flutter_invoice_app/bloc/base/bloc_state.dart';
import 'package:flutter_invoice_app/models/dashboard/reconciliation_dashboard_model.dart';
import 'package:flutter_invoice_app/models/favorites/favorite_item_model.dart';
import 'package:flutter_invoice_app/models/gst_returns/gst_return_summary.dart';

class HomeState extends BlocState {
  final List<GstReturnSummary> recentReturns;
  final List<ReconciliationTypeMetric> reconciliationMetrics;
  final List<FavoriteItem> favorites;
  final int pendingAlerts;
  final bool isLoading;
  final String? error;

  HomeState({
    required this.recentReturns,
    required this.reconciliationMetrics,
    required this.favorites,
    required this.pendingAlerts,
    required this.isLoading,
    this.error,
  });

  factory HomeState.initial() {
    return HomeState(
      recentReturns: [],
      reconciliationMetrics: [],
      favorites: [],
      pendingAlerts: 0,
      isLoading: false,
      error: null,
    );
  }

  factory HomeState.loading() {
    return HomeState(
      recentReturns: [],
      reconciliationMetrics: [],
      favorites: [],
      pendingAlerts: 0,
      isLoading: true,
      error: null,
    );
  }

  factory HomeState.error(String message) {
    return HomeState(
      recentReturns: [],
      reconciliationMetrics: [],
      favorites: [],
      pendingAlerts: 0,
      isLoading: false,
      error: message,
    );
  }

  HomeState copyWith({
    List<GstReturnSummary>? recentReturns,
    List<ReconciliationTypeMetric>? reconciliationMetrics,
    List<FavoriteItem>? favorites,
    int? pendingAlerts,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      recentReturns: recentReturns ?? this.recentReturns,
      reconciliationMetrics: reconciliationMetrics ?? this.reconciliationMetrics,
      favorites: favorites ?? this.favorites,
      pendingAlerts: pendingAlerts ?? this.pendingAlerts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
