import '../models/user.dart';
import 'api_service.dart';

class UserService {
  final ApiService api;

  UserService(this.api);

  Future<List<User>> fetchAll() async {
    final resp = await api.get('/users');
    final data = resp.data as List<dynamic>;
    return data
        .map((e) => User.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<User> getById(int id) async {
    final resp = await api.get('/users/$id');
    return User.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<User> create(User user) async {
    final resp = await api.post('/users', data: user.toJson());
    return User.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<User> update(int id, Map<String, dynamic> changes) async {
    final resp = await api.put('/users/$id', data: changes);
    return User.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<void> delete(int id) async {
    await api.delete('/users/$id');
  }

  Future<User> updateCurrentUserProfile(Map<String, dynamic> changes) async {
    final resp = await api.put('/user/profile', data: changes);
    return User.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<User> linkHederaAccount(String hederaAccountId) async {
    final resp = await api.post('/user/link-hedera-account', data: {'hederaAccountId': hederaAccountId});
    return User.fromJson(Map<String, dynamic>.from(resp.data));
  }
}
