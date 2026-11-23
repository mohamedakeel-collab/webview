/// `part / part of` hub for the Store (Salla WebView) feature.
///
/// The app is a native shell around the merchant's Salla storefront:
/// a native bottom bar, one WebView per tab, native offline handling.
library;

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:injectable/injectable.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/language/locale_keys.g.dart';
import '../../../../config/res/assets.gen.dart';
import '../../../../config/res/config_imports.dart';
import '../../../../core/notifications/push_notification_service.dart';
import '../../../../core/shared/extensions/text_style_extensions.dart';
import '../../../../core/widgets/buttons/default_button.dart';

// ── Models ───────────────────────────────────────────────────────────
part '../models/store_tab.dart';
part '../models/store_menu_item.dart';

// ── Cubits ───────────────────────────────────────────────────────────
part '../cubits/store_tab_cubit.dart';

// ── ViewControllers ──────────────────────────────────────────────────
part '../controllers/store_web_controller.dart';
part '../controllers/store_view_controller.dart';
part '../controllers/cart_tracker.dart';

// ── Screens ──────────────────────────────────────────────────────────
part '../view/store_screen.dart';

// ── Widgets ──────────────────────────────────────────────────────────
part '../widgets/store_body.dart';
part '../widgets/store_bottom_bar.dart';
part '../widgets/store_tab_view.dart';
part '../widgets/store_offline_view.dart';
part '../widgets/store_splash_view.dart';
part '../widgets/store_refresh_overlay.dart';
part '../widgets/store_menu_view.dart';
part '../widgets/store_menu_tile.dart';
