#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIControl.h>

@interface SBHUDView : UIView

@property (assign,nonatomic) float progress;
@property (nonatomic, retain) CAGradientLayer *flhLayer;
@property (nonatomic, retain) CAGradientLayer *flhBackgroundLayer;
-(void)setProgress:(float)arg1 ;
-(float)flhRealProgress;

@end

@interface SBVolumeHUDView : SBHUDView

@end

@interface SBRingerHUDView : SBHUDView

-(BOOL)isSilent;

@end

@interface SBHUDWindow : UIWindow

@end