import '../models/notification.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService api;

  NotificationService(this.api);

  Future<List<AppNotification>> fetchForUser(int userId) async {
    final resp =
        await api.get('/notifications', queryParameters: {'user_id': userId});
    final data = resp.data as List<dynamic>;
    return data
        .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<AppNotification> create(AppNotification n) async {
    final resp = await api.post('/notifications', data: n.toJson());
    return AppNotification.fromJson(Map<String, dynamic>.from(resp.data));
  }
}
