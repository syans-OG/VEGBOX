import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';

class UserService extends ChangeNotifier {
  String _name = 'Syakib';
  String _phone = '0851 9103 9930';
  String _addressLabel = AppConstants.defaultAddressLabel;
  String _addressDetail = AppConstants.defaultAddressDetail;
  bool _orderUpdates = true;
  bool _promotions = true;

  String get name => _name;
  String get phone => _phone;
  String get addressLabel => _addressLabel;
  String get addressDetail => _addressDetail;
  bool get orderUpdates => _orderUpdates;
  bool get promotions => _promotions;

  void updateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == _name) return;
    _name = trimmed;
    notifyListeners();
  }

  void updateProfile({required String name, required String phone}) {
    _name = name.trim();
    _phone = phone.trim();
    notifyListeners();
  }

  void updateAddress({required String label, required String detail}) {
    _addressLabel = label;
    _addressDetail = detail;
    notifyListeners();
  }

  void updatePreferences({
    required bool orderUpdates,
    required bool promotions,
  }) {
    _orderUpdates = orderUpdates;
    _promotions = promotions;
    notifyListeners();
  }
}
