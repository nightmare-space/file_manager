//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import open_file_mac
import package_info_plus
import path_provider_foundation
import screen_retriever
import url_launcher_macos
import video_player_avfoundation
import wakelock_plus
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  OpenFilePlugin.register(with: registry.registrar(forPlugin: "OpenFilePlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  ScreenRetrieverPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverPlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
  FVPVideoPlayerPlugin.register(with: registry.registrar(forPlugin: "FVPVideoPlayerPlugin"))
  WakelockPlusMacosPlugin.register(with: registry.registrar(forPlugin: "WakelockPlusMacosPlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
