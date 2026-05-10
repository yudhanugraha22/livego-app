// lib/routes/app_pages.dart

import 'package:flutter/material.dart';
import '../core/utils/device_utils.dart';
import '../ui/mobile/mobile_home.dart';
import '../ui/mobile/mobile_detail.dart';
import '../ui/mobile/mobile_player.dart';
import '../ui/tv/tv_home.dart';
import '../ui/tv/tv_detail.dart';
import '../ui/tv/tv_player.dart';
import 'app_routes.dart';

class AppPages {
  static Map<String, WidgetBuilder> get routes {
    return {
      AppRoutes.initial: (context) {
        // Deteksi Perangkat Otomatis
        return DeviceUtils.isTV ? const TvHome() : const MobileHome();
      },
      AppRoutes.detail: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final String dramaId = args['drama_id'] ?? '';
        final String platform = args['platform'] ?? '';
        
        return DeviceUtils.isTV 
            ? TvDetail(dramaId: dramaId, platform: platform)
            : MobileDetail(dramaId: dramaId, platform: platform);
      },
      AppRoutes.player: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final String dramaId = args['drama_id'] ?? '';
        final String episodeId = args['episode_id'] ?? '';
        final String platform = args['platform'] ?? '';
        
        return DeviceUtils.isTV
            ? TvPlayer(dramaId: dramaId, episodeId: episodeId, platform: platform)
            : MobilePlayer(dramaId: dramaId, episodeId: episodeId, platform: platform);
      },
    };
  }
}
