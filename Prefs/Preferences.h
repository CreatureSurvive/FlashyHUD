#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>
#import "NSTask.h"

#define COLORS_PATH @"/var/mobile/Library/Preferences/me.nepeta.flashyhud-colors.plist"
#define BUNDLE_ID @"me.nepeta.flashyhud"

@interface FLHPrefsListController : HBRootListController
    - (void)resetPrefs:(id)sender;
    - (void)respring:(id)sender;
@end