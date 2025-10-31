import '../models/farmer.dart';
import 'api_service.dart';

import '../models/user.dart'; // Import User model

class FarmerService {
  final ApiService api;

  FarmerService(this.api);

  Future<User?> getFarmerProfile() async {
    try {
      final resp = await api.get('/api/farmer/profile');
      if (resp.data != null && resp.data['success'] == true && resp.data['data'] != null) {
        return User.fromJson(Map<String, dynamic>.from(resp.data['data']));
      }
      return null;
    } catch (e) {
      // Handle error, e.g., log it
      print('Error fetching farmer profile: $e');
      return null;
    }
  }

  Future<List<Farmer>> fetchAll() async {
    final resp = await api.get('/farmers');
    final data = resp.data as List<dynamic>;
    return data
        .map((e) => Farmer.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Farmer> getById(int userId) async {
    final resp = await api.get('/farmers/$userId');
    return Farmer.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<Farmer> create(Farmer f) async {
    final resp = await api.post('/farmers', data: f.toJson());
    return Farmer.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<Farmer> update(int userId, Map<String, dynamic> changes) async {
    final resp = await api.put('/farmers/$userId', data: changes);
    return Farmer.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<void> delete(int userId) async {
    await api.delete('/farmers/$userId');
  }
}
