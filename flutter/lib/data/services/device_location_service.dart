import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocket_tarot/domain/use_cases/daily_reading_controller.dart';

typedef LocationServiceEnabledChecker = Future<bool> Function();
typedef LocationPermissionChecker = Future<LocationPermission> Function();
typedef LocationPermissionRequester = Future<LocationPermission> Function();
typedef CurrentPositionLoader =
    Future<Position> Function({LocationSettings? locationSettings});
typedef LastKnownPositionLoader = Future<Position?> Function();

class DeviceLocationService {
  DeviceLocationService({
    LocationServiceEnabledChecker? isLocationServiceEnabled,
    LocationPermissionChecker? checkPermission,
    LocationPermissionRequester? requestPermission,
    CurrentPositionLoader? getCurrentPosition,
    LastKnownPositionLoader? getLastKnownPosition,
  }) : _isLocationServiceEnabled =
           isLocationServiceEnabled ?? Geolocator.isLocationServiceEnabled,
       _checkPermission = checkPermission ?? Geolocator.checkPermission,
       _requestPermission = requestPermission ?? Geolocator.requestPermission,
       _getCurrentPosition =
           getCurrentPosition ??
           (({LocationSettings? locationSettings}) {
             return Geolocator.getCurrentPosition(
               locationSettings: locationSettings,
             );
           }),
       _getLastKnownPosition =
           getLastKnownPosition ?? Geolocator.getLastKnownPosition;

  final LocationServiceEnabledChecker _isLocationServiceEnabled;
  final LocationPermissionChecker _checkPermission;
  final LocationPermissionRequester _requestPermission;
  final CurrentPositionLoader _getCurrentPosition;
  final LastKnownPositionLoader _getLastKnownPosition;

  Future<DailyReadingLocationResult> loadDailyReadingLocation() async {
    try {
      final serviceEnabled = await _isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('DeviceLocationService: 定位服務未啟用 (Location service is disabled in system settings).');
        return const DailyReadingLocationResult.permissionDenied();
      }

      var permission = await _checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _requestPermission();
      }

      if (!_canAccessLocation(permission)) {
        debugPrint('DeviceLocationService: 定位權限不足 (Location permission: $permission).');
        return const DailyReadingLocationResult.permissionDenied();
      }

      final position = await _getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return DailyReadingLocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (error, stack) {
      debugPrint('DeviceLocationService: 獲取最新定位失敗 (Error fetching location): $error');
      debugPrint(stack.toString());

      try {
        debugPrint('DeviceLocationService: 嘗試獲取最後已知定位 (Attempting to fetch last known position as fallback)...');
        final lastPosition = await _getLastKnownPosition();
        if (lastPosition != null) {
          debugPrint('DeviceLocationService: 成功獲取最後已知定位 (Successfully retrieved last known position): ${lastPosition.latitude}, ${lastPosition.longitude}');
          return DailyReadingLocationResult.success(
            latitude: lastPosition.latitude,
            longitude: lastPosition.longitude,
          );
        } else {
          debugPrint('DeviceLocationService: 無最後已知定位可用 (No last known position available).');
        }
      } catch (fallbackError) {
        debugPrint('DeviceLocationService: 獲取最後已知定位也失敗 (Error fetching last known position fallback): $fallbackError');
      }

      return const DailyReadingLocationResult.permissionDenied();
    }
  }

  bool _canAccessLocation(LocationPermission permission) {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}
