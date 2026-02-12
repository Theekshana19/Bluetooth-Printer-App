//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<network_info_plus/FPPNetworkInfoPlusPlugin.h>)
#import <network_info_plus/FPPNetworkInfoPlusPlugin.h>
#else
@import network_info_plus;
#endif

#if __has_include(<permission_handler_apple/PermissionHandlerPlugin.h>)
#import <permission_handler_apple/PermissionHandlerPlugin.h>
#else
@import permission_handler_apple;
#endif

#if __has_include(<shared_preferences_foundation/SharedPreferencesPlugin.h>)
#import <shared_preferences_foundation/SharedPreferencesPlugin.h>
#else
@import shared_preferences_foundation;
#endif

#if __has_include(<thermal_printer/ThermalPrinterPlugin.h>)
#import <thermal_printer/ThermalPrinterPlugin.h>
#else
@import thermal_printer;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FPPNetworkInfoPlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"FPPNetworkInfoPlusPlugin"]];
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
  [SharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"SharedPreferencesPlugin"]];
  [ThermalPrinterPlugin registerWithRegistrar:[registry registrarForPlugin:@"ThermalPrinterPlugin"]];
}

@end
