import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../config/res/config_imports.dart';

/// Push is sent by the merchant from the OneSignal dashboard; the app only
/// registers the device and opens the link a tapped notification carries.
final class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  /// The link of the last tapped notification, until the store opens it.
  /// Held here because a tap that launches the app arrives before the
  /// store screen exists.
  final ValueNotifier<Uri?> pendingLink = ValueNotifier(null);

  Future<void> initialize() async {
    if (kDebugMode) OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(ConstantManager.oneSignalAppId);
    OneSignal.Notifications.addClickListener(_onClick);
    await OneSignal.Notifications.requestPermission(true);
  }

  /// The merchant puts the link in Additional Data as `url`; Launch URL is
  /// accepted too, since the manifest stops OneSignal opening it itself.
  void _onClick(OSNotificationClickEvent event) {
    final notification = event.notification;
    final raw =
        notification.additionalData?['url']?.toString() ??
        notification.launchUrl;
    final uri = raw == null ? null : Uri.tryParse(raw.trim());
    if (uri != null && uri.hasScheme) pendingLink.value = uri;
  }
}
