import 'dart:async';
import 'package:flutter_invoice_app/bloc/base/bloc_event.dart';
import 'package:flutter_invoice_app/bloc/base/bloc_state.dart';

abstract class Bloc<E extends BlocEvent, S extends BlocState> {
  final StreamController<E> _eventController = StreamController<E>();
  final StreamController<S> _stateController = StreamController<S>.broadcast();
  
  Stream<S> get state => _stateController.stream;
  S? _currentState;
  
  S? get currentState => _currentState;
  
  Bloc() {
    _eventController.stream.listen(_handleEvent);
  }
  
  void add(E event) {
    _eventController.add(event);
  }
  
  void _handleEvent(E event) async {
    try {
      S newState = await mapEventToState(event);
      _currentState = newState;
      _stateController.add(newState);
    } catch (e, stackTrace) {
      print('Error handling event: $e');
      print(stackTrace);
      _stateController.addError(e);
    }
  }
  
  Future<S> mapEventToState(E event);
  
  void dispose() {
    _eventController.close();
    _stateController.close();
  }
}
