// File: features/client/models/location_models.dart
class State {
  final int id;
  final String name;

  State({required this.id, required this.name});

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['id'],
      name: json['name'],
    );
  }
}

class City {
  final int id;
  final String name;
  final int stateId;

  City({required this.id, required this.name, required this.stateId});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      stateId: json['state_id'],
    );
  }
}

class WorkType {
  final int id;
  final String name;

  WorkType({required this.id, required this.name});

  factory WorkType.fromJson(Map<String, dynamic> json) {
    return WorkType(
      id: json['id'],
      name: json['name'],
    );
  }
}

// Responsible person model
class Responsible {
  final int id;
  final String name;

  Responsible({required this.id, required this.name});

  factory Responsible.fromJson(Map<String, dynamic> json) {
    return Responsible(
      id: json['id'],
      name: json['name'],
    );
  }
}

// Sample data for Egypt states
final List<State> egyptStates = [
  State(id: 1, name: 'القاهرة'),
  State(id: 2, name: 'الإسكندرية'),
  State(id: 3, name: 'الجيزة'),
  State(id: 4, name: 'المنصورة'),
  State(id: 5, name: 'طنطا'),
  State(id: 6, name: 'أسيوط'),
  State(id: 7, name: 'الإسماعيلية'),
  State(id: 8, name: 'بورسعيد'),
  State(id: 9, name: 'السويس'),
  State(id: 10, name: 'الأقصر'),
];

// Sample data for cities
final List<City> egyptCities = [
  // القاهرة
  City(id: 1, name: 'مدينة نصر', stateId: 1),
  City(id: 2, name: 'المعادي', stateId: 1),
  City(id: 3, name: 'مصر الجديدة', stateId: 1),
  // الإسكندرية
  City(id: 4, name: 'المنتزه', stateId: 2),
  City(id: 5, name: 'سموحة', stateId: 2),
  // الجيزة
  City(id: 6, name: 'الدقي', stateId: 3),
  City(id: 7, name: 'المهندسين', stateId: 3),
  City(id: 8, name: '6 أكتوبر', stateId: 3),
  // المنصورة
  City(id: 9, name: 'المنصورة', stateId: 4),
  City(id: 10, name: 'طلخا', stateId: 4),
  // طنطا
  City(id: 11, name: 'طنطا', stateId: 5),
  City(id: 12, name: 'المحلة', stateId: 5),
  // أسيوط
  City(id: 13, name: 'أسيوط', stateId: 6),
  City(id: 14, name: 'منفلوط', stateId: 6),
  // الإسماعيلية
  City(id: 15, name: 'الإسماعيلية', stateId: 7),
  // بورسعيد
  City(id: 16, name: 'بورسعيد', stateId: 8),
  // السويس
  City(id: 17, name: 'السويس', stateId: 9),
  // الأقصر
  City(id: 18, name: 'الأقصر', stateId: 10),
  City(id: 19, name: 'الكرنك', stateId: 10),
];

// Sample data for work types
final List<WorkType> workTypes = [
  WorkType(id: 1, name: 'متجر مفرد'),
  WorkType(id: 2, name: 'سلسلة متاجر'),
];
