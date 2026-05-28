import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../models/plot.dart';

/// Сервис для работы с участками.
///
/// Изолирует HTTP-вызовы от UI и провайдера. Возвращает типизированные
/// [Plot] и пробрасывает наши [ApiException] через [ApiClient.mapDioError].
class PlotsService {
  final ApiClient _api;

  PlotsService(this._api);

  /// GET /plots — список моих участков (где у меня есть роль).
  /// Возвращаются только не-архивные.
  Future<List<Plot>> fetchPlots() async {
    try {
      final response = await _api.dio.get('/plots');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => Plot.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }

  /// POST /plots — создать участок. Я автоматически становлюсь admin.
  ///
  /// `name` обязателен; остальные поля можно пропустить.
  Future<Plot> createPlot({
    required String name,
    String? address,
    double? areaSqm,
    String? description,
  }) async {
    try {
      final response = await _api.dio.post(
        '/plots',
        data: {
          'name': name,
          if (address != null && address.isNotEmpty) 'address': address,
          if (areaSqm != null) 'area_sqm': areaSqm,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );
      return Plot.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }

  /// GET /plots/{id} — один участок. Пригодится позже на экране деталей.
  Future<Plot> fetchPlot(String plotId) async {
    try {
      final response = await _api.dio.get('/plots/$plotId');
      return Plot.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }
}
