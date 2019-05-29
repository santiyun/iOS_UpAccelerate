//
//  UAHud.m
//  TTTUpAccelerate
//
//  Created by yanzhen on 2018/11/19.
//  Copyright © 2018 yanzhen. All rights reserved.
//

#import "UAHud.h"
static const BOOL UAHudWhite = NO;
static const CGFloat UAHudWH = 80;

@interface UAHud ()
@property (nonatomic, strong) UIView *uaView;
@end

@implementation UAHud
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _uaView = [[UIView alloc] init];
        _uaView.backgroundColor = UAHudWhite ? [UIColor colorWithWhite:0.8 alpha:0.6] : [UIColor blackColor];
        
        _uaView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _uaView.layer.cornerRadius = 5;
        [self addSubview:_uaView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _uaView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
}

+ (void)hudShow:(UIView *)view
{
    [self hudHide:view];
    UAHud *hud = [[UAHud alloc] initWithFrame:view.bounds];
    
    UIActivityIndicatorView *indicatorView = [hud buildActivityIndicatorView];
    hud.uaView.frame = CGRectMake(0, 0, UAHudWH, UAHudWH);
    indicatorView.center = CGPointMake(UAHudWH / 2, UAHudWH / 2);
    
    [view addSubview:hud];
}

+(void)hudHide:(UIView *)view
{
    for (UIView *hud in view.subviews) {
        if ([hud isKindOfClass:[UAHud class]]) {
            [UIView animateWithDuration:1 animations:^{
                hud.alpha = 0;
            } completion:^(BOOL finished) {
                [hud removeFromSuperview];
            }];
        }
    }
}
#pragma mark - private
- (UIActivityIndicatorView *)buildActivityIndicatorView
{
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.color = UAHudWhite ? [UIColor blackColor] : [UIColor whiteColor];
    [indicatorView startAnimating];
    [_uaView addSubview:indicatorView];
    return indicatorView;
}
@end
