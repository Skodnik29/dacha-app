import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../models/zone.dart';

/// Сервис для работы с зонами на участке.
///
/// Изолирует HTTP-вызовы от UI и провайдеров.
class ZonesService {
  final ApiClient _api;

  ZonesService(this._api);

  /// GET /plots/{plotId}/zones — список зон участка.
  Future<List<Zone>> fetchZones({required String plotId}) async {
    try {
      final response = await _api.dio.get('/plots/$plotId/zones');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => Zone.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }

  /// POST /plots/{plotId}/zones — создать зону.
  ///
  /// name обязателен, остальные поля можно не заполнять.
  Future<Zone> createZone({
    required String plotId,
    required String name,
    String zoneType = 'garden',
    String? color,
    String? icon,
    String? description,
  }) async {
    try {
      final response = await _api.dio.post(
        '/plots/$plotId/zones',
        data: {
          'name': name,
          'zone_type': zoneType,
          if (color != null && color.isNotEmpty) 'color': color,
          if (icon != null && icon.isNotEmpty) 'icon': icon,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );
      return Zone.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }
}