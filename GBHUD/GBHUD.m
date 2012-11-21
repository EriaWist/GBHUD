//
//  GBHUD.m
//  GBHUD
//
//  Created by Luka Mirosevic on 21/11/2012.
//  Copyright (c) 2012 Goonbee. All rights reserved.
//

#define kAnimationDuration 0.2

#define kDefaultSize (CGSize){100, 110}
#define kDefaultCornerRadius 8
#define kDefaultSymbolSize (CGSize){60, 60}
#define kDefaultSymbolTopOffset 16
#define kDefaultTextBottomOffset 8
#define kDefaultFont [UIFont fontWithName:@"Helvetica-Bold" size:12]
#define kDefaultBackdropColor [UIColor colorWithWhite:0 alpha:0.5]
#define kDefaultTextColor [UIColor whiteColor]

#import "GBHUD.h"
#import "GBHUDView.h"


@interface GBHUD()

@property (assign, nonatomic, readwrite) BOOL isShowingHUD;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) GBHUDView *hudView;

@end


@implementation GBHUD {
    CGSize _size;
    CGFloat _cornerRadius;
    CGSize _symbolSize;
    CGFloat _symbolTopOffset;
    CGFloat _textBottomOffset;
    UIFont *_font;
    UIColor *_backdropColor;
    UIColor *_textColor;
}

#pragma mark - acc

-(CGFloat)cornerRadius {
    if (_cornerRadius == 0) {
        return kDefaultCornerRadius;
    }
    else {
        return _cornerRadius;
    }
}

-(CGSize)symbolSize {
    if (CGSizeEqualToSize(_symbolSize, CGSizeZero)) {
        return kDefaultSymbolSize;
    }
    else {
        return _symbolSize;
    }
}

-(CGFloat)symbolTopOffset {
    if (_symbolTopOffset == 0) {
        return kDefaultSymbolTopOffset;
    }
    else {
        return _symbolTopOffset;
    }
}

-(CGFloat)textBottomOffset {
    if (_textBottomOffset == 0) {
        return kDefaultTextBottomOffset;
    }
    else {
        return _textBottomOffset;
    }
}

-(UIFont *)font {
    if (!_font) {
        return kDefaultFont;
    }
    else {
        return _font;
    }
}

-(UIColor *)backdropColor {
    if (!_backdropColor) {
        return kDefaultBackdropColor;
    }
    else {
        return _backdropColor;
    }
}

-(UIColor *)textColor {
    if (!_textColor) {
        return kDefaultTextColor;
    }
    else {
        return _textColor;
    }
}

-(CGSize)size {
    if (CGSizeEqualToSize(_size, CGSizeZero)) {
        return kDefaultSize;
    }
    else {
        return _size;
    }
}

-(void)setSize:(CGSize)size {
    _size = size;
    
//    self.hudView.si
    self.hudView.frame = CGRectMake((self.containerView.bounds.size.width - size.width)/2.0, (self.containerView.bounds.size.height - size.height)/2.0, size.width, size.height);
}

-(void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    
    self.hudView.cornerRadius = cornerRadius;
}

-(void)setDisableUserInteraction:(BOOL)disableUserInteraction {
    _disableUserInteraction = disableUserInteraction;
    
    self.containerView.userInteractionEnabled = disableUserInteraction;
}

-(void)setSymbolSize:(CGSize)symbolSize {
    _symbolSize = symbolSize;
    
    self.hudView.symbolSize = symbolSize;
}

-(void)setSymbolTopOffset:(CGFloat)symbolTopOffset {
    _symbolTopOffset = symbolTopOffset;
    
    self.hudView.symbolTopOffset = symbolTopOffset;
}

-(void)setTextBottomOffset:(CGFloat)textBottomOffset {
    _textBottomOffset = textBottomOffset;
    
    self.hudView.labelBottomOffset = textBottomOffset;
}

-(void)setFont:(UIFont *)font {
    _font = font;
    
    self.hudView.font = font;
}

-(void)setBackdropColor:(UIColor *)backdropColor {
    _backdropColor = backdropColor;
    
    self.hudView.backdropColor = backdropColor;
}

-(void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    
    self.hudView.textColor = textColor;
}

#pragma mark - mem

+(GBHUD *)sharedHUD {
    static GBHUD* _sharedHUD;
    
    @synchronized(self)
    {
        if (!_sharedHUD)
            _sharedHUD = [[GBHUD alloc] init];
        
        return _sharedHUD;
    }
}

-(id)init {
    if (self = [super init]) {
        //init ivars
        self.size = CGSizeZero;
        self.symbolSize = CGSizeZero;
        self.symbolTopOffset = 0;
        self.textBottomOffset = 0;
        self.font = nil;
        self.backdropColor = nil;
        self.textColor = nil;
    }
    
    return self;
}

-(void)dealloc {
    [self dismissHUDAnimated:NO];
    
    self.hudView = nil;
    self.containerView = nil;
    self.font = nil;
    self.backdropColor = nil;
    self.textColor = nil;
}

#pragma mark - public API

-(void)showHUDWithType:(GBHUDType)type text:(NSString *)text animated:(BOOL)animated {
    UIImage *image = nil;//foo todo
    UIImageView *symbolImageView = [[UIImageView alloc] initWithImage:image];
    [self showHUDWithView:symbolImageView text:text animated:animated];
}

-(void)showHUDWithImage:(UIImage *)image text:(NSString *)text animated:(BOOL)animated {
    UIImageView *symbolImageView = [[UIImageView alloc] initWithImage:image];
    [self showHUDWithView:symbolImageView text:text animated:animated];
}

-(void)showHUDWithView:(UIView *)symbolView text:(NSString *)text animated:(BOOL)animated {
    if (!self.isShowingHUD) {
        //fetch the target view which the entire hud view will be added to
        UIView *targetView = [[UIApplication sharedApplication] keyWindow];
        
        //create the hud view
        GBHUDView *newHUD = [[GBHUDView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
        newHUD.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        newHUD.symbolView = symbolView;
        newHUD.text = text;
        newHUD.textColor = self.textColor;
        newHUD.backdropColor = self.backdropColor;
        newHUD.font = self.font;
        newHUD.symbolSize = self.symbolSize;
        newHUD.symbolTopOffset = self.symbolTopOffset;
        newHUD.labelBottomOffset = self.textBottomOffset;
        newHUD.cornerRadius = self.cornerRadius;
        
        //create the container and add the hud to it
        UIView *containerView = [[UIView alloc] initWithFrame:targetView.bounds];
        containerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        containerView.userInteractionEnabled = self.disableUserInteraction;
        [containerView addSubview:newHUD];
        
        //center the hud in the container
        newHUD.center = containerView.center;
        
        //draw the view
        [targetView addSubview:containerView];
        
        //store in properties
        self.hudView = newHUD;
        self.containerView = containerView;
        
        //set flag
        self.isShowingHUD = YES;
        
        //animations
        if (animated) {
            //first shrink to 0
            newHUD.transform = CGAffineTransformMakeScale(0.1, 0.1);
            
            //then scale up a bit too much
            [UIView animateWithDuration:kAnimationDuration*0.5 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
                newHUD.transform = CGAffineTransformMakeScale(1.15, 1.15);
            } completion:^(BOOL finished) {
                
                //bounce back
                [UIView animateWithDuration:kAnimationDuration*0.2 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
                    newHUD.transform = CGAffineTransformMakeScale(0.95, 0.95);
                } completion:^(BOOL finished) {
                    
                    //settle
                    [UIView animateWithDuration:kAnimationDuration*0.25 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
                        newHUD.transform = CGAffineTransformMakeScale(1, 1);
                    } completion:^(BOOL finished) {
                        //noop
                    }];
                }];
                
            }];
        }
        else {
        }
    }
    else {
        NSLog(@"GBHUD: can't show new HUD, already showing one.");
    }
}

-(void)dismissHUDAnimated:(BOOL)animated {
    void(^completedBlock)(void) = ^{
        [self.containerView removeFromSuperview];
        self.containerView = nil;
        self.isShowingHUD = NO;
    };
    
    if (animated) {
        [UIView animateWithDuration:kAnimationDuration*0.6 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            self.hudView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        } completion:^(BOOL finished) {
            completedBlock();
        }];
    }
    else {
        completedBlock();
    }
}

@end