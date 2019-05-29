//
//  NSObject+Toast.m
//  TTTUpAccelerate
//
//  Created by yanzhen on 2018/11/19.
//  Copyright © 2018 yanzhen. All rights reserved.
//

#import "NSObject+Toast.h"

@implementation NSObject (Toast)

@end

@implementation UIView (UAE)

- (void)showMessage:(NSString *)message
{
    UIView *toast = [self getMessgeShow:message];
    toast.userInteractionEnabled = NO;
    toast.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    toast.alpha = 0;
    [self addSubview:toast];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        toast.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
            toast.alpha = 0;
        } completion:^(BOOL finished) {
            [toast removeFromSuperview];
        }];
    }];
}

#pragma mark - private
- (UIView *)getMessgeShow:(NSString *)message
{
    UIView *toastView = [[UIView alloc] init];
    toastView.backgroundColor = [UIColor blackColor];
    toastView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    toastView.layer.cornerRadius = 3;
    toastView.layer.shadowColor = [UIColor blackColor].CGColor;
    toastView.layer.shadowOpacity = 1;
    toastView.layer.shadowRadius = 6;
    toastView.layer.shadowOffset = CGSizeMake(4, 4);
    //
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    UIFont *font = [UIFont systemFontOfSize:16];
    titleLabel.font = font;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = message;
    
    CGSize maxSize = CGSizeMake(self.bounds.size.width * 0.8, self.bounds.size.height * 0.8);
    CGSize messageSize = [message boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    titleLabel.frame = CGRectMake(10, 10, messageSize.width, messageSize.height);
    toastView.frame = CGRectMake(0, 0, messageSize.width + 2 * 10, messageSize.height + 2 * 10);
    [toastView addSubview:titleLabel];
    return toastView;
}

#pragma mark - property
-(void)setBorderWidth:(CGFloat)borderWidth{
    self.layer.borderWidth = borderWidth;
}

-(CGFloat)borderWidth{
    return 12;
}

-(void)setBorderColor:(UIColor *)borderColor{
    self.layer.borderColor = borderColor.CGColor;
}

-(UIColor *)borderColor{
    return UIColor.redColor;
}

-(void)setCornerRadius:(CGFloat)cornerRadius{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
}

-(CGFloat)cornerRadius{
    return 12;
}
@end
@implementation UIViewController (UAE)
-(void)showMessage:(NSString *)message {
    [self.view showMessage:message];
}
@end
