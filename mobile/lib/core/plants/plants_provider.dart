import 'package:flutter/foundation.dart';

import '../../models/plant.dart';
import '../../services/plants_service.dart';
import '../api/api_exception.dart';

enum PlantsStatus { initial, loading, ready, error }

enum CatalogStatus { initial, loading, ready, error }

// ── Провайдер растений в зоне ─────────────────────────────────────────────

/// Живёт на экране зоны. Создаётся в initState, уничтожается в dispose.
class ZonePlantsProvider extends ChangeNotifier {
  final PlantsService _service;
  final String zoneId;

  ZonePlantsProvider(this._service, {required this.zoneId});

  PlantsStatus _status = PlantsStatus.initial;
  List<PlantInstance> _plants = const [];
  String? _errorMessage;

  PlantsStatus get status => _status;
  List<PlantInstance> get plants => _plants;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == PlantsStatus.loading;
  bool get isEmpty => _status == PlantsStatus.ready && _plants.isEmpty;

  Future<void> loadPlants() async {
    _status = PlantsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _plants = await _service.getZonePlants(zoneId);
      _status = PlantsStatus.ready;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = PlantsStatus.error;
    } catch (_) {
      _errorMessage = 'Не удалось загрузить растения. Попробуй позже.';
      _status = PlantsStatus.error;
    }
    notifyListeners();
  }

  Future<bool> addPlant({
    required String plantId,
    String? varietyId,
    String? customName,
    DateTime? plantedDate,
    int? quantity,
    double? areaSqm,
    String? notes,
    String status = 'active',
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _service.addPlantToZone(
        zoneId: zoneId,
        plantId: plantId,
        varietyId: varietyId,
        customName: customName,
        plantedDate: plantedDate,
        quantity: quantity,
        areaSqm: areaSqm,
        notes: notes,
        status: status,
      );
      _plants = [..._plants, created];
      _status = PlantsStatus.ready;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Не удалось добавить растение.';
      notifyListeners();
      return false;
    }
  }

  Future<void> updatePlantStatus({
    required String instanceId,
    required String newStatus,
  }) async {
    try {
      final updated = await _service.updatePlantInstance(
        zoneId: zoneId,
        instanceId: instanceId,
        status: newStatus,
      );
      _plants = _plants
          .map((p) => p.id == instanceId ? updated : p)
          .toList();
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Не удалось обновить статус.';
      notifyListeners();
    }
  }

  Future<void> removePlant(String instanceId) async {
    try {
      await _service.removePlantFromZone(
        zoneId: zoneId,
        instanceId: instanceId,
      );
      _plants = _plants.where((p) => p.id != instanceId).toList();
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Не удалось удалить растение.';
      notifyListeners();
    }
  }
}

// ── Провайдер каталога культур ────────────────────────────────────────────

/// Создаётся при открытии экрана каталога. Хранит список всех культур
/// и текущий фильтр по типу.
class PlantCatalogProvider extends ChangeNotifier {
  final PlantsService _service;

  PlantCatalogProvider(this._service);

  CatalogStatus _status = CatalogStatus.initial;
  List<PlantCatalog> _catalog = const [];
  String? _selectedType;
  String? _errorMessage;

  CatalogStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get selectedType => _selectedType;

  /// Список с учётом текущего фильтра.
  List<PlantCatalog> get filteredCatalog {
    if (_selectedType == null) return _catalog;
    return _catalog
        .where((p) => p.plantType == _selectedType)
        .toList();
  }

  /// Установить фильтр по типу. null = показать все.
  void setFilter(String? type) {
    _selectedType = type;
    notifyListeners();
  }

  Future<void> loadCatalog() async {
    if (_status == CatalogStatus.loading) return;
    _status = CatalogStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _catalog = await _service.getCatalog();
      _status = CatalogStatus.ready;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = CatalogStatus.error;
    } catch (_) {
      _errorMessage = 'Не удалось загрузить каталог. Попробуй позже.';
      _status = CatalogStatus.error;
    }
    notifyListeners();
  }
}