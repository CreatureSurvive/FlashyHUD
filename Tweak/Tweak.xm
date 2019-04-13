#import <Cephei/HBPreferences.h>
#import <libcolorpicker.h>
#import "Tweak.h"

HBPreferences *preferences;

BOOL dpkgInvalid = false;
BOOL enabled = true;
BOOL disableAnimations = false;
BOOL hasShadow = true;
BOOL backgroundShadow = true;
BOOL inverted = false;
BOOL gradient = false;
BOOL background = true;
NSInteger location = 0; // 0: top; 1: right; 2: bottom; 3: left
CGFloat thickness = 5;
CGFloat size = 1.0;
CGFloat offset = 0;
CGFloat horizontalOffset = 0;
CGFloat verticalOffset = 0;
CGFloat cornerRadius = 0;
CGFloat opacity = 1.0;
UIColor *mediaColor = nil;
UIColor *ringerColor = nil;
UIColor *gradientColor = nil;
UIColor *backgroundColor = nil;
UIView *lastHUD = nil;

@implementation FLHGradientLayer

- (id<CAAction>)actionForKey:(NSString *)event {
    if (disableAnimations) return nil;
    return [super actionForKey:event];
}

@end

CGRect getFrameForProgress(float progress, CGRect bounds) {
    CGFloat fullLength = 0;
    CGFloat x = bounds.size.width * horizontalOffset;
    CGFloat y = bounds.size.height * verticalOffset;

    switch (location) {
        case 1:
        case 3:
            fullLength = bounds.size.height;
            break;
        default:
            fullLength = bounds.size.width;
            break;
    }


    CGFloat length = fullLength * size;
    CGFloat sizeOffset = (fullLength - length) / 2.0;

    if (inverted) {
        switch (location) {
            case 0: //top
                return CGRectMake(x + length + sizeOffset - length * progress,
                                y + offset,
                                length * progress,
                                thickness);
            case 1: //right
                return CGRectMake(x + bounds.size.width - thickness - offset,
                                y + sizeOffset,
                                thickness,
                                length * progress);
            case 2: //bottom
                return CGRectMake(x + length + sizeOffset - length * progress,
                                y + bounds.size.height - thickness - offset,
                                length * progress,
                                thickness);
            default: //left
                return CGRectMake(x + offset,
                                y + sizeOffset,
                                thickness,
                                length * progress);
        }
    }

    switch (location) {
        case 0: //top
            return CGRectMake(x + sizeOffset,
                            y + offset,
                            length * progress,
                            thickness);
        case 1: //right
            return CGRectMake(x + bounds.size.width - thickness - offset,
                            y + length + sizeOffset - length * progress,
                            thickness,
                            length * progress);
        case 2: //bottom
            return CGRectMake(x + sizeOffset,
                            y + bounds.size.height - thickness - offset,
                            length * progress,
                            thickness);
        default: //left
            return CGRectMake(x + offset,
                            y + length + sizeOffset - length * progress,
                            thickness,
                            length * progress);
    }
}

CGSize getShadowOffset() {
    switch (location) {
        case 0: //top
            return CGSizeMake(0, thickness/2.0);
        case 1: //right
            return CGSizeMake(-thickness/2.0, 0);
        case 2: //bottom
            return CGSizeMake(0, -thickness/2.0);
        default: //left
            return CGSizeMake(thickness/2.0, 0);
    }
}

CGPoint getStartPoint() {
    switch (location) {
        case 0: //top
            return CGPointMake(0.0, 0.5);
        case 1: //right
            return CGPointMake(0.5, 1.0);
        case 2: //bottom
            return CGPointMake(0.0, 0.5);
        default: //left
            return CGPointMake(0.5, 1.0);
    }
}

CGPoint getEndPoint() {
    switch (location) {
        case 0: //top
            return CGPointMake(1.0, 0.5);
        case 1: //right
            return CGPointMake(0.5, 0.0);
        case 2: //bottom
            return CGPointMake(1.0, 0.5);
        default: //left
            return CGPointMake(0.5, 0.0);
    }
}

%group FlashyHUD

%hook SBHUDView

%property (nonatomic, retain) FLHGradientLayer *flhLayer;
%property (nonatomic, retain) FLHGradientLayer *flhBackgroundLayer;

%new
-(float)flhRealProgress {
    if ([self respondsToSelector:@selector(isSilent)] && [((SBRingerHUDView *)self) isSilent]) {
        return 0.0;
    }

    return self.progress;
}

-(void)layoutSubviews {
    %orig;

    lastHUD = self;

    UIColor *color = mediaColor;
    if ([self isKindOfClass:%c(SBRingerHUDView)] || ([self respondsToSelector:@selector(mode)] && [((SBVolumeHUDView *)self) mode] == 1)) {
        color = ringerColor;
    }

    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.frame = bounds;
    self.alpha = opacity;

    if (!self.flhBackgroundLayer) {
        self.layer.sublayers = nil;
        self.layer.masksToBounds = NO;
        self.flhBackgroundLayer = [[FLHGradientLayer alloc] init];
        self.flhBackgroundLayer.masksToBounds = NO;
 
        [self.layer addSublayer:self.flhBackgroundLayer];
    }

    if (!self.flhLayer) {
        self.flhLayer = [[FLHGradientLayer alloc] init];
        self.flhLayer.masksToBounds = NO;
 
        [self.layer addSublayer:self.flhLayer];
    }

    self.flhBackgroundLayer.frame = getFrameForProgress(1.0, bounds);
    if (background) {
        self.flhBackgroundLayer.backgroundColor = backgroundColor.CGColor;
    } else {
        self.flhBackgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
    }

    self.flhLayer.backgroundColor = color.CGColor;

    self.flhLayer.frame = getFrameForProgress([self flhRealProgress], bounds);
    self.flhLayer.startPoint = getStartPoint();
    self.flhLayer.endPoint = getEndPoint();

    self.flhLayer.cornerRadius = cornerRadius;
    self.flhBackgroundLayer.cornerRadius = cornerRadius;

    if (hasShadow) {
        self.flhLayer.shadowOpacity = 0.5;
        self.flhLayer.shadowRadius = thickness;
        self.flhLayer.shadowColor = color.CGColor;
        self.flhLayer.shadowOffset = getShadowOffset();
    } else {
        self.flhLayer.shadowOpacity = 0;
    }

    if (backgroundShadow) {
        self.flhBackgroundLayer.shadowOpacity = 0.5;
        self.flhBackgroundLayer.shadowRadius = thickness;
        self.flhBackgroundLayer.shadowColor = backgroundColor.CGColor;
        self.flhBackgroundLayer.shadowOffset = getShadowOffset();
    } else {
        self.flhBackgroundLayer.shadowOpacity = 0;
    }

    if (gradient) {
        self.flhLayer.colors = @[(id)color.CGColor, (id)gradientColor.CGColor];
    } else {
        self.flhLayer.colors = nil;
    }
}

-(void)addSubview:(id)xxx {
    //noop
}

-(void)insertSubview:(id)xxx atIndex:(int)x {
    //noop
}

-(void)setProgress:(float)arg1 {
    %orig;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.flhLayer.frame = getFrameForProgress([self flhRealProgress], bounds);
}

%end

%hook SBHUDWindow

-(void)setHidden:(BOOL)hidden {
    if (hidden == self.hidden) return;
    %orig;
    
    if (hidden) return;

    if (disableAnimations) {
        self.alpha = 1.0;
        return;
    }
    
    self.alpha = 0.0;
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 1.0;
    } completion:nil];
}

%end

%end

%group FlashyHUDIntegrityFail

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)arg1 {
    %orig;
    if (!dpkgInvalid) return;
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:@"😡😡😡"
        message:@"The build of FlashyHUD you're using comes from an untrusted source. Pirate repositories can distribute malware and you will get subpar user experience using any tweaks from them.\nRemember: FlashyHUD is free. Uninstall this build and install the proper version of FlashyHUD from:\nhttps://repo.nepeta.me/\n(it's free, damnit, why would you pirate that!?)"
        preferredStyle:UIAlertControllerStyleAlert
    ];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Damn!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [((UIApplication*)self).keyWindow.rootViewController dismissViewControllerAnimated:YES completion:NULL];
    }]];

    [((UIApplication*)self).keyWindow.rootViewController presentViewController:alertController animated:YES completion:NULL];
}

%end

%end

void refreshHUD() {
    [CATransaction begin];
    [CATransaction setDisableActions: YES];
    [lastHUD layoutSubviews];
    [CATransaction commit];
}

void reloadColors() {
    NSDictionary *colors = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/me.nepeta.flashyhud-colors.plist"];
    if (!colors) return;

    mediaColor = [LCPParseColorString([colors objectForKey:@"MediaColor"], @"#ffffff:1.0") copy];
    ringerColor = [LCPParseColorString([colors objectForKey:@"RingerColor"], @"#ffffff:1.0") copy];
    gradientColor = [LCPParseColorString([colors objectForKey:@"GradientColor"], @"#000000:1.0") copy];
    backgroundColor = [LCPParseColorString([colors objectForKey:@"BackgroundColor"], @"#000000:1.0") copy];
    refreshHUD();
}

%ctor {
    dpkgInvalid = ![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/me.nepeta.flashyhud.list"];

    if (dpkgInvalid) {
        %init(FlashyHUDIntegrityFail);
        return;
    }

    preferences = [[HBPreferences alloc] initWithIdentifier:@"me.nepeta.flashyhud"];

    [preferences registerBool:&enabled default:YES forKey:@"Enabled"];
    [preferences registerBool:&hasShadow default:YES forKey:@"HasShadow"];
    [preferences registerBool:&backgroundShadow default:YES forKey:@"BackgroundShadow"];
    [preferences registerBool:&background default:YES forKey:@"Background"];
    [preferences registerBool:&inverted default:NO forKey:@"Inverted"];
    [preferences registerBool:&gradient default:NO forKey:@"Gradient"];
    [preferences registerBool:&disableAnimations default:NO forKey:@"DisableAnimations"];
    [preferences registerInteger:&location default:0 forKey:@"Location"];
    [preferences registerFloat:&thickness default:5.0 forKey:@"Thickness"];
    [preferences registerFloat:&size default:1.0 forKey:@"Size"];
    [preferences registerFloat:&offset default:0.0 forKey:@"Offset"];
    [preferences registerFloat:&horizontalOffset default:0.0 forKey:@"HorizontalOffset"];
    [preferences registerFloat:&verticalOffset default:0.0 forKey:@"VerticalOffset"];
    [preferences registerFloat:&cornerRadius default:0.0 forKey:@"CornerRadius"];
    [preferences registerFloat:&opacity default:1.0 forKey:@"Opacity"];

    mediaColor = [UIColor whiteColor];
    ringerColor = [UIColor whiteColor];
    gradientColor = [UIColor blackColor];
    backgroundColor = [UIColor blackColor];

    reloadColors();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadColors, (CFStringRef)@"me.nepeta.flashyhud/ReloadColors", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)refreshHUD, (CFStringRef)@"me.nepeta.flashyhud/ReloadPrefs", NULL, (CFNotificationSuspensionBehavior)kNilOptions);

    %init(FlashyHUD);
}
