import 'package:flutter/foundation.dart';

import '../../models/zone.dart';
import '../../services/zones_service.dart';
import '../api/api_exception.dart';

/// Состояние списка зон одного участка.
enum ZonesStatus {
  /// Ещё ни разу не загружали.
  initial,

  /// Идёт сетевой запрос (loadZones / createZone).
  loading,

  /// Список успешно загружен (может быть пустым).
  ready,

  /// Последний запрос упал с ошибкой — сообщение в [errorMessage].
  error,
}

/// Провайдер зон для конкретного участка.
///
/// Экземпляр создаётся на экране деталей участка и живёт столько же,
/// сколько живёт этот экран.
class ZonesProvider extends ChangeNotifier {
  final ZonesService _service;
  final String plotId;

  ZonesProvider(this._service, {required this.plotId});

  ZonesStatus _status = ZonesStatus.initial;
  List<Zone> _zones = const [];
  String? _errorMessage;

  ZonesStatus get status => _status;
  List<Zone> get zones => _zones;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ZonesStatus.loading;
  bool get isEmpty => _status == ZonesStatus.ready && _zones.isEmpty;

  /// Загрузить список зон для участка.
  Future<void> loadZones() async {
    _status = ZonesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _zones = await _service.fetchZones(plotId: plotId);
      _status = ZonesStatus.ready;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ZonesStatus.error;
    } catch (_) {
      _errorMessage =
          'Не удалось загрузить зоны. Попробуй позже.';
      _status = ZonesStatus.error;
    }
    notifyListeners();
  }

  /// Создать новую зону. При успехе добавляем её в начало списка.
  Future<bool> createZone({
    required String name,
    String zoneType = 'garden',
    String? color,
    String? icon,
    String? description,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _service.createZone(
        plotId: plotId,
        name: name,
        zoneType: zoneType,
        color: color,
        icon: icon,
        description: description,
      );
      _zones = [created, ..._zones];
      _status = ZonesStatus.ready;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ZonesStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Не удалось создать зону.';
      _status = ZonesStatus.error;
      notifyListeners();
      return false;
    }
  }
}