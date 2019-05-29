//
//  NSObject+Toast.h
//  TTTUpAccelerate
//
//  Created by yanzhen on 2018/11/19.
//  Copyright © 2018 yanzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Toast)

@end

@interface UIView (UAE)
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, strong) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;

- (void)showMessage:(NSString *)message;

@end

@interface UIViewController (UAE)
- (void)showMessage:(NSString *)message;
@end

