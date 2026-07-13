List<Map<String, dynamic>> extractListOfMaps(
  dynamic json, {
  List<String> preferredKeys = const <String>['data'],
  int maxDepth = 4,
}) {
  if (json == null || maxDepth < 0) {
    return const <Map<String, dynamic>>[];
  }

  if (json is List) {
    return json.whereType<Map<String, dynamic>>().toList();
  }

  if (json is! Map) {
    return const <Map<String, dynamic>>[];
  }

  final map = Map<String, dynamic>.from(json);

  for (final key in preferredKeys) {
    if (!map.containsKey(key)) continue;
    final extracted = extractListOfMaps(
      map[key],
      preferredKeys: preferredKeys,
      maxDepth: maxDepth - 1,
    );
    if (extracted.isNotEmpty) {
      return extracted;
    }
  }

  for (final entry in map.entries) {
    final value = entry.value;
    if (value is Map || value is List) {
      final extracted = extractListOfMaps(
        value,
        preferredKeys: preferredKeys,
        maxDepth: maxDepth - 1,
      );
      if (extracted.isNotEmpty) {
        return extracted;
      }
    }
  }

  return const <Map<String, dynamic>>[];
}

List<Map<String, dynamic>> extractLaravelPaginatedList(dynamic json) {
  if (json is List) {
    return json.whereType<Map<String, dynamic>>().toList();
  }

  if (json is! Map) {
    return const <Map<String, dynamic>>[];
  }

  final map = Map<String, dynamic>.from(json);
  final directData = map['data'];

  if (directData is List) {
    return directData.whereType<Map<String, dynamic>>().toList();
  }

  if (directData is Map) {
    final nestedData = directData['data'];
    if (nestedData is List) {
      return nestedData.whereType<Map<String, dynamic>>().toList();
    }
  }

  final services = map['services'];
  if (services is List) {
    return services.whereType<Map<String, dynamic>>().toList();
  }

  if (services is Map) {
    final nestedServices = services['data'];
    if (nestedServices is List) {
      return nestedServices.whereType<Map<String, dynamic>>().toList();
    }
  }

  return extractListOfMaps(json, preferredKeys: const <String>['data']);
}
