import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/plant.dart';

class PlantsService {
  final ApiClient _api;

  PlantsService(this._api);

  Future<List<PlantCatalog>> getCatalog({String? plantType}) async {
    try {
      final response = await _api.dio.get(
        '/plants/catalog',
        queryParameters: plantType != null ? {'plant_type': plantType} : null,
      );
      return (response.data as List<dynamic>)
          .map((e) => PlantCatalog.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }

  Future<PlantCatalog> getPlant(String plantId) async {
    try {
      final response = await _api.dio.get('/plants/catalog/$plantId');
      return PlantCatalog.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }

  Future<List<PlantVariety>> getVarieties(String plantId) async {
    try {
      final response = await _api.dio.get('/plants/catalog/$plantId/varieties');
      return (response.data as List<dynamic>)
          .map((e) => PlantVariety.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }

  Future<List<PlantInstance>> getZonePlants(String zoneId,
      {String? status}) async {
    try {
      final response = await _api.dio.get(
        '/plants/zones/$zoneId/plants',
        queryParameters: status != null ? {'status': status} : null,
      );
      return (response.data as List<dynamic>)
          .map((e) => PlantInstance.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }

  Future<PlantInstance> addPlantToZone({
    required String zoneId,
    required String plantId,
    String? varietyId,
    String? customName,
    DateTime? plantedDate,
    int? quantity,
    double? areaSqm,
    String? notes,
    String status = 'active',
  }) async {
    try {
      final response = await _api.dio.post('/plants/zones/$zoneId/plants', data: {
        'plant_id': plantId,
        if (varietyId != null) 'variety_id': varietyId,
        if (customName != null) 'custom_name': customName,
        if (plantedDate != null)
          'planted_date': plantedDate.toIso8601String().substring(0, 10),
        if (quantity != null) 'quantity': quantity,
        if (areaSqm != null) 'area_sqm': areaSqm,
        if (notes != null) 'notes': notes,
        'status': status,
      });
      return PlantInstance.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }

  Future<PlantInstance> updatePlantInstance({
    required String zoneId,
    required String instanceId,
    String? customName,
    DateTime? plantedDate,
    int? quantity,
    double? areaSqm,
    String? notes,
    String? status,
  }) async {
    try {
      final response = await _api.dio.patch(
        '/plants/zones/$zoneId/plants/$instanceId',
        data: {
          if (customName != null) 'custom_name': customName,
          if (plantedDate != null)
            'planted_date': plantedDate.toIso8601String().substring(0, 10),
          if (quantity != null) 'quantity': quantity,
          if (areaSqm != null) 'area_sqm': areaSqm,
          if (notes != null) 'notes': notes,
          if (status != null) 'status': status,
        },
      );
      return PlantInstance.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }

  Future<void> removePlantFromZone(
      {required String zoneId, required String instanceId}) async {
    try {
      await _api.dio.delete('/plants/zones/$zoneId/plants/$instanceId');
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }
}