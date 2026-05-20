import 'package:pocket_tarot/data/services/api_client.dart';
import 'package:pocket_tarot/domain/models/profile_models.dart';

class ProfileRepository {
  const ProfileRepository(this._apiClient);

  final PocketTarotApiClient _apiClient;

  Future<ProfileSnapshot> fetchMe() async {
    final json = await _apiClient.getJson('/users/me');
    return ProfileSnapshot.fromJson((json['data']! as Map).cast<String, Object?>());
  }

  Future<UserProfile> updateDisplayName(String displayName) async {
    final json = await _apiClient.patchJson('/users/me', {'displayName': displayName});
    final data = (json['data']! as Map).cast<String, Object?>();
    return UserProfile.fromJson((data['user']! as Map).cast<String, Object?>());
  }
}
