import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocket_tarot/domain/use_cases/daily_reading_controller.dart';

typedef LocationServiceEnabledChecker = Future<bool> Function();
typedef LocationPermissionChecker = Future<LocationPermission> Function();
typedef LocationPermissionRequester = Future<LocationPermission> Function();
typedef CurrentPositionLoader =
    Future<Position> Function({LocationSettings? locationSettings});

class DeviceLocationService {
  DeviceLocationService({
    LocationServiceEnabledChecker? isLocationServiceEnabled,
    LocationPermissionChecker? checkPermission,
    LocationPermissionRequester? requestPermission,
    CurrentPositionLoader? getCurrentPosition,
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
           });

  final LocationServiceEnabledChecker _isLocationServiceEnabled;
  final LocationPermissionChecker _checkPermission;
  final LocationPermissionRequester _requestPermission;
  final CurrentPositionLoader _getCurrentPosition;

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
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return DailyReadingLocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (error, stack) {
      debugPrint('DeviceLocationService: 獲取定位失敗 (Error fetching location): $error');
      debugPrint(stack.toString());
      return const DailyReadingLocationResult.permissionDenied();
    }
  }

  bool _canAccessLocation(LocationPermission permission) {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}
