import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/constants/api_constants.dart';
import '../models/vegetable.dart';

class VegetableService {
  VegetableService(this._dio);

  final Dio _dio;
  List<Vegetable>? _localCache;

  Future<List<Vegetable>> loadLocal() async {
    final cached = _localCache;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString('asset/data/vegetables.json');
    final decoded = jsonDecode(raw);
    final data = decoded is Map<String, dynamic> ? decoded['data'] : decoded;
    if (data is! List) {
      throw const FormatException('Data sayuran lokal tidak valid.');
    }

    final vegetables = _parseVegetables(data, 'Lokal');
    _localCache = vegetables;
    return vegetables;
  }

  Future<List<Vegetable>> fetchFromApi() async {
    try {
      final response = await _dio.get(ApiConstants.vegetables);
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const FormatException('Respons API bukan objek JSON.');
      }
      if (body['success'] == false) {
        throw FormatException(
          body['message']?.toString() ?? 'Permintaan API gagal.',
        );
      }
      final data = body['data'];
      if (data is! List) {
        throw const FormatException(
          "Field 'data' pada respons API tidak valid.",
        );
      }
      return _parseVegetables(data, 'API');
    } on DioException catch (error) {
      debugPrint(
        'Vegetable API error ${error.type} '
        '${error.response?.statusCode ?? '-'} '
        '${error.requestOptions.uri}: ${error.message}',
      );
      rethrow;
    }
  }

  List<Vegetable> _parseVegetables(List<dynamic> data, String source) {
    final vegetables = <Vegetable>[];
    for (final item in data) {
      if (item is! Map<String, dynamic>) {
        debugPrint('$source: melewati item yang bukan objek: $item');
        continue;
      }
      try {
        vegetables.add(Vegetable.fromJson(item));
      } on FormatException catch (error) {
        debugPrint('$source: melewati data sayuran tidak valid: $error');
      }
    }
    if (data.isNotEmpty && vegetables.isEmpty) {
      throw FormatException('$source: tidak ada data sayuran yang valid.');
    }
    return vegetables;
  }
}
