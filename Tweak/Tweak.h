#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIControl.h>

@interface FLHGradientLayer : CAGradientLayer

@end

@interface SBHUDView : UIView

@property (assign,nonatomic) float progress;
@property (nonatomic, retain) FLHGradientLayer *flhLayer;
@property (nonatomic, retain) FLHGradientLayer *flhBackgroundLayer;
@property (nonatomic, retain) FLHGradientLayer *flhKnobLayer;
@property (nonatomic, assign) CGRect flhFullFrame;

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

@interface SBHUDController : NSObject

+(id)sharedHUDController;
-(void)_orderWindowOut:(id)arg1 ;
-(id)visibleHUDView;
-(void)hideHUDView;
-(id)visibleOrFadingHUDView;
-(void)_recenterHUDView;
-(void)_createUI;
-(void)presentHUDView:(id)arg1 ;
-(void)dealloc;
-(void)_tearDown;
-(void)reorientHUDIfNeeded:(BOOL)arg1 ;
-(void)presentHUDView:(id)arg1 autoDismissWithDelay:(double)arg2 ;

@end

@interface VolumeControl : NSObject

+(id)sharedVolumeControl;
-(void)setMediaVolume:(float)arg1 ;

@end