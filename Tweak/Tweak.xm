#import <Cephei/HBPreferences.h>
#import <libcolorpicker.h>
#import "Tweak.h"

HBPreferences *preferences;

BOOL enabled = true;
BOOL hasShadow = true;
BOOL inverted = false;
BOOL gradient = false;
BOOL background = true;
NSInteger location = 0; // 0: top; 1: right; 2: bottom; 3: left
CGFloat thickness = 5;
CGFloat verticalMargin = 0;
CGFloat horizontalMargin = 0;
CGFloat cornerRadius = 0;
CGFloat opacity = 1.0;
UIColor *mediaColor = nil;
UIColor *ringerColor = nil;
UIColor *gradientColor = nil;
UIColor *backgroundColor = nil;
UIView *lastHUD = nil;

CGRect getFrameForProgress(float progress, CGRect bounds) {
    CGFloat innerWidth = (bounds.size.width - horizontalMargin * 2.0);
    CGFloat innerHeight = (bounds.size.height - verticalMargin * 2.0);

    if (inverted) {
        switch (location) {
            case 0: //top
                return CGRectMake(innerWidth + horizontalMargin - innerWidth * progress,
                                verticalMargin,
                                innerWidth * progress,
                                thickness);
            case 1: //right
                return CGRectMake(bounds.size.width - thickness - horizontalMargin,
                                verticalMargin,
                                thickness,
                                innerHeight * progress);
            case 2: //bottom
                return CGRectMake(innerWidth + horizontalMargin - innerWidth * progress,
                                bounds.size.height - thickness - verticalMargin,
                                innerWidth * progress,
                                thickness);
            default: //left
                return CGRectMake(horizontalMargin,
                                verticalMargin,
                                thickness,
                                innerHeight * progress);
        }
    }

    switch (location) {
        case 0: //top
            return CGRectMake(horizontalMargin,
                            verticalMargin,
                            innerWidth * progress,
                            thickness);
        case 1: //right
            return CGRectMake(bounds.size.width - thickness - horizontalMargin,
                            innerHeight + verticalMargin - innerHeight * progress,
                            thickness,
                            innerHeight * progress);
        case 2: //bottom
            return CGRectMake(horizontalMargin,
                            bounds.size.height - thickness - verticalMargin,
                            innerWidth * progress,
                            thickness);
        default: //left
            return CGRectMake(horizontalMargin,
                            innerHeight + verticalMargin - innerHeight * progress,
                            thickness,
                            innerHeight * progress);
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

%property (nonatomic, retain) CAGradientLayer *flhLayer;
%property (nonatomic, retain) CAGradientLayer *flhBackgroundLayer;

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
    if ([self isKindOfClass:%c(SBRingerHUDView)]) {
        color = ringerColor;
    }

    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.frame = bounds;
    self.alpha = opacity;

    if (!self.flhBackgroundLayer) {
        self.layer.sublayers = nil;
        self.layer.masksToBounds = NO;
        self.flhBackgroundLayer = [[CAGradientLayer alloc] init];
        self.flhBackgroundLayer.masksToBounds = NO;
 
        [self.layer addSublayer:self.flhBackgroundLayer];
    }

    if (!self.flhLayer) {
        self.flhLayer = [[CAGradientLayer alloc] init];
        self.flhLayer.masksToBounds = NO;
 
        [self.layer addSublayer:self.flhLayer];

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"frame"];
        animation.duration = 0.15f;
        [self.flhLayer addAnimation:animation forKey:@"frame"];
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

        self.flhBackgroundLayer.shadowOpacity = 0.5;
        self.flhBackgroundLayer.shadowRadius = thickness;
        self.flhBackgroundLayer.shadowColor = backgroundColor.CGColor;
        self.flhBackgroundLayer.shadowOffset = getShadowOffset();
    } else {
        self.flhLayer.shadowOpacity = 0;
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

    self.alpha = 0.0;
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 1.0;
    } completion:nil];
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
    preferences = [[HBPreferences alloc] initWithIdentifier:@"me.nepeta.flashyhud"];
    [preferences registerDefaults:@{
        @"Enabled": @YES,
        @"HasShadow": @YES,
        @"Background": @YES,
        @"Inverted": @NO,
        @"Gradient": @NO,
        @"Location": @(0),
        @"Thickness": @(5.0),
        @"VerticalMargin": @(0.0),
        @"HorizontalMargin": @(0.0),
        @"CornerRadius": @(0.0),
        @"Opacity": @(1.0),
    }];

    [preferences registerBool:&enabled default:YES forKey:@"Enabled"];
    [preferences registerBool:&hasShadow default:YES forKey:@"HasShadow"];
    [preferences registerBool:&background default:YES forKey:@"Background"];
    [preferences registerBool:&inverted default:NO forKey:@"Inverted"];
    [preferences registerBool:&gradient default:NO forKey:@"Gradient"];
    [preferences registerInteger:&location default:0 forKey:@"Location"];
    [preferences registerFloat:&thickness default:5.0 forKey:@"Thickness"];
    [preferences registerFloat:&verticalMargin default:0.0 forKey:@"VerticalMargin"];
    [preferences registerFloat:&horizontalMargin default:0.0 forKey:@"HorizontalMargin"];
    [preferences registerFloat:&cornerRadius default:0.0 forKey:@"CornerRadius"];
    [preferences registerFloat:&opacity default:1.0 forKey:@"Opacity"];

    mediaColor = [UIColor whiteColor];
    ringerColor = [UIColor whiteColor];
    gradientColor = [UIColor blackColor];

    reloadColors();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadColors, (CFStringRef)@"me.nepeta.flashyhud/ReloadColors", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)refreshHUD, (CFStringRef)@"me.nepeta.flashyhud/ReloadPrefs", NULL, (CFNotificationSuspensionBehavior)kNilOptions);

    %init(FlashyHUD);
}
