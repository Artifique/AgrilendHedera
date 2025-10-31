import '../models/delivery.dart';
import 'api_service.dart';

class DeliveryService {
  final ApiService api;

  DeliveryService(this.api);

  Future<List<Delivery>> fetchAll() async {
    final resp = await api.get('/deliveries');
    final data = resp.data as List<dynamic>;
    return data
        .map((e) => Delivery.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Delivery> getById(int id) async {
    final resp = await api.get('/deliveries/$id');
    return Delivery.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<Delivery> create(Delivery d) async {
    final resp = await api.post('/deliveries', data: d.toJson());
    return Delivery.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<Delivery> update(int id, Map<String, dynamic> changes) async {
    final resp = await api.put('/deliveries/$id', data: changes);
    return Delivery.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<void> delete(int id) async {
    await api.delete('/deliveries/$id');
  }
}
