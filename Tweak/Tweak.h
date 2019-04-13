#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIControl.h>

@interface FLHGradientLayer : CAGradientLayer

@end

@interface SBHUDView : UIView

@property (assign,nonatomic) float progress;
@property (nonatomic, retain) FLHGradientLayer *flhLayer;
@property (nonatomic, retain) FLHGradientLayer *flhBackgroundLayer;
-(void)setProgress:(float)arg1 ;
-(float)flhRealProgress;

@end

@interface SBVolumeHUDView : SBHUDView

@property(assign, nonatomic) int mode;

@end

@interface SBRingerHUDView : SBHUDView

-(BOOL)isSilent;

@end

@interface SBHUDWindow : UIWindow

@end