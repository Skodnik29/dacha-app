import 'package:flutter/foundation.dart';

import '../../models/plot.dart';
import '../../services/plots_service.dart';
import '../api/api_exception.dart';

/// Состояние экрана со списком участков.
enum PlotsStatus {
  /// Ещё ни разу не загружали.
  initial,

  /// Идёт сетевой запрос (loadPlots / createPlot).
  loading,

  /// Список успешно загружен (может быть пустым).
  ready,

  /// Последний запрос упал с ошибкой — сообщение в [errorMessage].
  error,
}

/// Глобальное состояние списка участков.
///
/// Регистрируется в main.dart через MultiProvider рядом с AuthProvider.
/// UI подписывается через `context.watch<PlotsProvider>()`.
class PlotsProvider extends ChangeNotifier {
  final PlotsService _service;

  PlotsProvider(this._service);

  PlotsStatus _status = PlotsStatus.initial;
  List<Plot> _plots = const [];
  String? _errorMessage;

  PlotsStatus get status => _status;
  List<Plot> get plots => _plots;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == PlotsStatus.loading;
  bool get isEmpty => _status == PlotsStatus.ready && _plots.isEmpty;

  /// Загрузить или обновить список участков.
  /// Используется и при первом открытии экрана, и в pull-to-refresh.
  Future<void> loadPlots() async {
    _status = PlotsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _plots = await _service.fetchPlots();
      _status = PlotsStatus.ready;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = PlotsStatus.error;
    } catch (e) {
      _errorMessage = 'Не удалось загрузить участки. Попробуй позже.';
      _status = PlotsStatus.error;
    }
    notifyListeners();
  }

  /// Создать новый участок. При успехе добавляем его в начало списка
  /// (без перезагрузки всего списка с сервера — экономим запрос).
  ///
  /// Возвращает true при успехе, false если упало; ошибка лежит в [errorMessage].
  Future<bool> createPlot({
    required String name,
    String? address,
    double? areaSqm,
    String? description,
  }) async {
    _errorMessage = null;
    try {
      final created = await _service.createPlot(
        name: name,
        address: address,
        areaSqm: areaSqm,
        description: description,
      );
      _plots = [created, ..._plots];
      _status = PlotsStatus.ready;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Не удалось создать участок.';
      notifyListeners();
      return false;
    }
  }

  /// Сброс состояния при logout — чтобы у следующего юзера не остались
  /// участки предыдущего.
  void reset() {
    _plots = const [];
    _status = PlotsStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
