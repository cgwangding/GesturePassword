//
//  GesturePasswordView.m
//  GesturePassword
//
//  Created by AD-iOS on 15/7/17.
//  Copyright (c) 2015年 Adinnet. All rights reserved.
//

#import "GesturePasswordView.h"

#define ScreenW     [UIScreen mainScreen].bounds.size.width

@interface GesturePasswordView()
//存储9个基础点
@property (strong, nonatomic) NSMutableArray *basePointArray;
//存储当前选中的点
@property (strong, nonatomic) NSMutableArray *curSelArray;
//当前固定的线的点，已经用线连接
@property (strong, nonatomic) NSMutableArray *lineArray;

//用来保存密码
@property (strong, nonatomic) NSMutableArray *pwdArray;

//当前手指的触点
@property (nonatomic) CGPoint currentTouch;

//是否正在触摸，默认NO,为YES时可以画可移动的那条线
@property (assign,nonatomic) BOOL isTouchMoving;

//是否需要清空所有的线以及该变了的点，所有有关设置密码时用
@property (assign, nonatomic) BOOL isNeedKeepLine;

@property (assign, nonatomic) BOOL isNeedShowingWrongPwdState;

//修改密码时使用，用来记录修改密码状态
@property (assign, nonatomic) BOOL isChangingPassword;

@end

@implementation GesturePasswordView

- (void)setMode:(GestureMode)mode
{
    _mode = mode;
    
    if (mode == GestureModeModifyPassword) {
        self.isChangingPassword = YES;
        //先验证密码,然后再设置密码
        _mode = GestureModeVerifyPassword;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.basePointColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
        self.lightPointColor = [UIColor whiteColor];
        self.pointCircleColor = [[UIColor whiteColor] colorWithAlphaComponent:.25];
        self.lineColor = [UIColor whiteColor];
        self.wrongTintColor = [UIColor redColor];
        self.topInset = 50;
        self.leftInset = 50;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画9个基础点
    [self bulidBasePwdUIWithContext:context];
    
    if (self.isNeedShowingWrongPwdState) {
        //密码错误时调用
        [self buildUIForWrongPwdStateWithContext:context];
    }else{
        //画选中点的图像
        [self bulidLightPointWithContect:context];
        //画已连接的线
        [self bulidLineWithContext:context];
        if (self.isTouchMoving) {
            //画活动的线
            [self buildCurrentLineWithContext:context];
        }
    }

}

- (void)bulidBasePwdUIWithContext:(CGContextRef)context
{
    
    //计算生成9个点的位置
    CGFloat pointDistance = (ScreenW - 2 * self.leftInset) / 2;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            CGPoint point = CGPointMake(self.leftInset + pointDistance * j, self.topInset + i*pointDistance);
            if (![self.basePointArray containsObject:[NSValue valueWithCGPoint:point]]) {
                [self.basePointArray addObject:[NSValue valueWithCGPoint:point]];
            }
            CGContextAddEllipseInRect(context, CGRectMake(point.x - 10, point.y - 10, 20, 20));
        }
    }
    CGContextSetFillColorWithColor(context, self.basePointColor.CGColor);
    CGContextFillPath(context);
}

- (void)bulidLightPointWithContect:(CGContextRef)context
{
    //画两个圆环
    CGMutablePathRef muStrokePath1 = CGPathCreateMutable();
    CGMutablePathRef muStrokePath2 = CGPathCreateMutable();
    for (NSValue *pValue in self.curSelArray) {
        //画亮起的圆
        CGContextAddEllipseInRect(context, [self makeRectFromPoint:[pValue CGPointValue]]);
        
        CGPathMoveToPoint(muStrokePath1, NULL,[pValue CGPointValue].x + 10, [pValue CGPointValue].y);
        CGPathAddArc(muStrokePath1, NULL, [pValue CGPointValue].x, [pValue CGPointValue].y, 10, 0, M_PI * 2, NO);
        CGPoint curPoint = CGPathGetCurrentPoint(muStrokePath1);
        CGPathMoveToPoint(muStrokePath2, NULL, curPoint.x + 4,curPoint.y);
        
        CGPathAddArc(muStrokePath2, NULL, [pValue CGPointValue].x, [pValue CGPointValue].y, 14, 0, M_PI * 2, NO);
        
    }
    //画亮起的圆
    CGContextSetFillColorWithColor(context, self.lightPointColor.CGColor);
    CGContextFillPath(context);
    
    //画圆环1
    CGContextAddPath(context, muStrokePath1);
    CGContextSetStrokeColorWithColor(context, self.pointCircleColor.CGColor);
    CGContextSetLineWidth(context, 3);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(muStrokePath1);
    
        //画圆环2
    CGContextAddPath(context, muStrokePath2);
    CGContextSetStrokeColorWithColor(context, self.pointCircleColor.CGColor);
    CGContextSetLineWidth(context, 3);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(muStrokePath2);
    
    
}

- (void)bulidLineWithContext:(CGContextRef)context
{
    //保存手势密码，只有设置密码时才保存
    if (self.isNeedKeepLine == NO && self.lineArray.count > 0 && self.mode == GestureModeSetPassword) {
        [self savePwdWithArray:self.lineArray];
    }
    
    if (self.lineArray.count < 2) {
        return;
    }
    CGPoint *points = (CGPoint*)malloc(sizeof(CGPoint) * self.lineArray.count);
    for (int i = 0; i < self.lineArray.count; i++) {
        CGPoint point = [self.lineArray[i] CGPointValue];
        points[i].x = point.x;
        points[i].y = point.y;
    }
    CGContextAddLines(context, points, self.lineArray.count);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 1);
    CGContextStrokePath(context);
}

/**
 *  密码错误时使用这个来画
 *
 *  @param context 当前的上下文
 */
- (void)buildUIForWrongPwdStateWithContext:(CGContextRef)context
{
    CGPoint *points = (CGPoint*)malloc(sizeof(CGPoint) * self.lineArray.count);
    for (int i = 0; i < self.lineArray.count; i++) {
        CGPoint point = [self.lineArray[i] CGPointValue];
        points[i].x = point.x;
        points[i].y = point.y;
    }
    CGContextAddLines(context, points, self.lineArray.count);
    CGContextSetStrokeColorWithColor(context, self.wrongTintColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 1);
    CGContextStrokePath(context);
    
    
    CGMutablePathRef muStrokePath1 = CGPathCreateMutable();
    CGMutablePathRef muStrokePath2 = CGPathCreateMutable();
    for (NSValue *pValue in self.curSelArray) {
        CGContextAddEllipseInRect(context, [self makeRectFromPoint:[pValue CGPointValue]]);
        
        CGPathMoveToPoint(muStrokePath1, NULL,[pValue CGPointValue].x + 10, [pValue CGPointValue].y);
        CGPathAddArc(muStrokePath1, NULL, [pValue CGPointValue].x, [pValue CGPointValue].y, 10, 0, M_PI * 2, NO);
        CGPoint curPoint = CGPathGetCurrentPoint(muStrokePath1);
        CGPathMoveToPoint(muStrokePath2, NULL, curPoint.x + 4,curPoint.y);
        
        CGPathAddArc(muStrokePath2, NULL, [pValue CGPointValue].x, [pValue CGPointValue].y, 14, 0, M_PI * 2, NO);
        
    }
    
    CGContextSetFillColorWithColor(context, self.wrongTintColor.CGColor);
    CGContextFillPath(context);
    
    
    CGContextAddPath(context, muStrokePath1);
    CGContextSetStrokeColorWithColor(context, [self.wrongTintColor colorWithAlphaComponent:.45].CGColor);
    CGContextSetLineWidth(context, 3);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(muStrokePath1);
    
    CGContextAddPath(context, muStrokePath2);
    CGContextSetStrokeColorWithColor(context, [self.wrongTintColor colorWithAlphaComponent:.45f].CGColor);
    CGContextSetLineWidth(context, 3);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(muStrokePath2);
    
    
}

- (void)buildCurrentLineWithContext:(CGContextRef)context
{
    if (self.lineArray.count > 0) {
        CGPoint lastPoint = [[self.lineArray lastObject] CGPointValue];
        CGContextMoveToPoint(context,lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(context, self.currentTouch.x, self.currentTouch.y);
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineWidth(context, 1);
        CGContextStrokePath(context);
    }
}

/**
 *  判断密码是否一样
 *
 *  @param array 当前输入的密码
 *
 *  @return bool值，YES一样，NO不一样
 */
- (BOOL)checkPwdCorrectWithArray:(NSArray*)array
{
    NSArray *readArray = [self readPwd];
    if (readArray.count != array.count) {
        return NO;
    }
    
    int  i = 0;
    BOOL isAllPass = YES;
    for (NSValue *value in array) {
        if (![readArray[i] isEqualToValue:value]) {
            isAllPass = NO;
            break;
        }
        i++;
    }
    return isAllPass;
}

- (NSValue*)isPointTouchInRect:(CGPoint)point
{
    for (NSValue *pointValue in self.basePointArray) {
        CGPoint pValue= [pointValue CGPointValue];
        CGRect rect = [self makeRectFromPoint:pValue];
        if (point.x > rect.origin.x && point.y > rect.origin.y && point.x < CGRectGetMaxX(rect) && point.y < CGRectGetMaxY(rect)) {
            return pointValue;
        }
    }
    
    return nil;
}

- (CGRect)makeRectFromPoint:(CGPoint)point
{
    return CGRectMake(point.x - 10, point.y - 10, 20, 20);
}


#pragma mark - Save && Read

- (void)savePwdWithArray:(NSArray*)array
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"gespwd"];
    BOOL isSucceed = [NSKeyedArchiver archiveRootObject:array toFile:path];
    if (isSucceed) {
        NSLog(@"密码保存成功");
    }else{
        NSLog(@"密码保存失败");
    }
}

- (NSArray*)readPwd
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"gespwd"];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}


#pragma mark - Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    self.isTouchMoving = YES;
    if (self.isNeedShowingWrongPwdState) {
        self.isNeedShowingWrongPwdState = NO;
        [self.curSelArray removeAllObjects];
        [self.lineArray removeAllObjects];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    NSValue *value = [self isPointTouchInRect:currentPoint];
    if (value) {
        //是触摸到触摸点
        if (![self.curSelArray containsObject:value]) {
            [self.curSelArray addObject:value];
            [self.lineArray addObject:value];
            
        }
        
        
    }
    self.currentTouch = currentPoint;
     [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isTouchMoving = NO;
    [self setNeedsDisplay];
    
    switch (self.mode) {
        case GestureModeModifyPassword:
        {
            //修改密码，已通过先使用验证密码后设置密码模式实现
            
        }
            break;
        case GestureModeSetPassword:
        {
            //设置密码
            if (self.isNeedKeepLine) {
                if ([self checkPwdCorrectWithArray:self.lineArray] == NO) {
                    self.isNeedShowingWrongPwdState = YES;
                    
                }
                if ([self.delegate respondsToSelector:@selector(gesturePasswordViewDidCheckPassword:)]) {
                    [self.delegate gesturePasswordViewDidCheckPassword:!self.isNeedShowingWrongPwdState];
                }
            }
            
            if (self.isNeedKeepLine == NO) {
                [self.curSelArray removeAllObjects];
                [self.lineArray removeAllObjects];
                self.isNeedKeepLine = !self.isNeedKeepLine;
                if ([self.delegate respondsToSelector:@selector(gesturePasswordViewHadSetPassword)]) {
                    [self.delegate gesturePasswordViewHadSetPassword];
                }
            }
        }
            break;
        case GestureModeVerifyPassword:
        {
            //验证密码
            if (self.isNeedKeepLine == NO) {
                if ([self checkPwdCorrectWithArray:self.lineArray] == NO) {
                    self.isNeedShowingWrongPwdState = YES;
                    
                }else{
                    if (self.isChangingPassword) {
                        self.mode = GestureModeSetPassword;
                        [self.lineArray removeAllObjects];
                        [self.curSelArray removeAllObjects];
                        if ([self.delegate respondsToSelector:@selector(gesturePasswordViewChangePasswordModeVerifyPasswordSucced)]) {
                            [self.delegate gesturePasswordViewChangePasswordModeVerifyPasswordSucced];
                        }
                        return;
                    }
                }
                if ([self.delegate respondsToSelector:@selector(gesturePasswordViewDidCheckPassword:)]) {
                    [self.delegate gesturePasswordViewDidCheckPassword:!self.isNeedShowingWrongPwdState];
                }
            }
        }
            break;
        default:
            break;
    }
    

    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesCancelled");
    self.isTouchMoving = NO;
    
    
}

#pragma mark - getter

- (NSMutableArray *)basePointArray
{
    if (_basePointArray == nil) {
        _basePointArray = [NSMutableArray array];
    }
    return _basePointArray;
}

- (NSMutableArray *)curSelArray
{
    if (_curSelArray == nil) {
        _curSelArray = [NSMutableArray array];
    }
    return _curSelArray;
}

- (NSMutableArray *)lineArray
{
    if (_lineArray == nil) {
        _lineArray = [NSMutableArray array];
    }
    return _lineArray;
}

- (NSMutableArray *)pwdArray
{
    if (_pwdArray == nil) {
        NSArray *pwd = [self readPwd];
        if (pwd) {
            _pwdArray = [NSMutableArray arrayWithArray:pwd];
        }else{
            _pwdArray = [NSMutableArray array];
        }
    }
    return _pwdArray;
}

@end
