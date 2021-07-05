//
//  SYLinkLabel.m
//  image
//
//  Created by mac on 2021/7/4.
//  Copyright © 2021 mac. All rights reserved.
//

#import "SYLinkLabel.h"
#import <objc/message.h>

const char *textAttachmentWeakObjectkey = "sy_weakObj";

//用于接收NSTextAttachment的weak属性的对象
@interface SYWeakObject : NSObject
@property (nonatomic,assign) CGPoint origin;
@property (nonatomic,assign) NSInteger line;
@end

@implementation SYWeakObject
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.line = -1;
    }
    return self;
}
@end

@interface NSTextAttachment (SYPosition)
/// 图片的绘制原点,所在行的最大Y不是本附件则不准确,需要重新计算.
@property (nonatomic,assign) CGPoint origin;
/// 当前行
@property (nonatomic,assign) NSInteger line;
/// 用于KVC取值
@property (nonatomic,assign,readonly) NSInteger originY;
/// 用于接纳属性
@property (nonatomic,strong) SYWeakObject* weakObj;
@end

@implementation NSTextAttachment (SYPosition)

+ (void)initialize {
    [super initialize];
    
    Class class = NSTextAttachment.class;
    SEL sel = @selector(attachmentBoundsForTextContainer:proposedLineFragment:glyphPosition:characterIndex:);
    Method method = class_getInstanceMethod(class, sel);
    method_setImplementation(method, imp_implementationWithBlock(^(__unsafe_unretained Class nativeClass, SEL nativeSel, IMP nativeIMP){
        return ^(NSTextAttachment *textAttachment,NSTextContainer *textContainer,CGRect lineFrag,CGPoint position,NSUInteger charIndex){
            textAttachment.origin = position;
            CGRect rect = ((CGRect(*)(id,NSTextContainer *,CGRect,CGPoint,NSUInteger))nativeIMP)(textAttachment,textContainer,lineFrag,position,charIndex);
            return rect;
        };
    }(class,sel,method_getImplementation(method))));
}

- (void)setWeakObj:(SYWeakObject *)weakObj {
    objc_setAssociatedObject(self, textAttachmentWeakObjectkey, weakObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SYWeakObject *)weakObj {
   SYWeakObject *obj = objc_getAssociatedObject(self, textAttachmentWeakObjectkey);
    if (!obj) {
        obj = [SYWeakObject new];
        [self setWeakObj:obj];
    }
    return obj;
}

- (void)setOrigin:(CGPoint)origin {
    self.weakObj.origin = origin;
}

- (CGPoint)origin {
    return self.weakObj.origin;
}

- (void)setLine:(NSInteger)line {
    self.weakObj.line = line;
}

- (NSInteger)line {
    return self.weakObj.line;
}

- (NSInteger)originY {
    return self.weakObj.origin.y + CGRectGetHeight(self.bounds);
}
@end


@interface SYLinkLabel ()
@property (nonatomic, assign) CGRect showingRect;
@end

@implementation SYLinkLabel

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect attributedTextBounds = [self.attributedText boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    if (self.textAlignment == NSTextAlignmentCenter || self.textAlignment == NSTextAlignmentNatural) {
        self.showingRect = CGRectMake((CGRectGetWidth(self.bounds)-CGRectGetWidth(attributedTextBounds))*0.5, (CGRectGetHeight(self.bounds)-CGRectGetHeight(attributedTextBounds))*0.5, CGRectGetWidth(attributedTextBounds), CGRectGetHeight(attributedTextBounds));
    } else if (self.textAlignment == NSTextAlignmentLeft) {
        self.showingRect = CGRectMake(0, (CGRectGetHeight(self.bounds)-CGRectGetHeight(attributedTextBounds))*0.5, CGRectGetWidth(attributedTextBounds), CGRectGetHeight(attributedTextBounds));
    } else if (self.textAlignment == NSTextAlignmentRight) {
           self.showingRect = CGRectMake(CGRectGetWidth(self.bounds)-CGRectGetWidth(attributedTextBounds), (CGRectGetHeight(self.bounds)-CGRectGetHeight(attributedTextBounds))*0.5, CGRectGetWidth(attributedTextBounds), CGRectGetHeight(attributedTextBounds));
    }
}

- (void)touchesBegan:(UITapGestureRecognizer *)tap {
    NSMutableArray <NSTextAttachment *>*attachments = [NSMutableArray array];
    NSTextAttachment *attachmentBefore;
    for (int i = 0; i < self.attributedText.length; i++) {
        NSRange range;
        
        NSTextAttachment *attachment = [self.attributedText attribute:NSAttachmentAttributeName atIndex:i effectiveRange:&range];
        if ([attachment isKindOfClass:NSTextAttachment.class]) {
            if (attachment.line < 0) {
                if (!attachmentBefore) {
                    attachment.line = i;
                } else {
                    attachment.line = attachmentBefore.line + (attachment.origin.y != attachmentBefore.origin.y);
                }
                attachmentBefore = attachment;
            }
            if (![attachments containsObject:attachment]) {
                [attachments addObject:attachment];
            }
        }
    }
    
    for (int i = 0; i < attachments.count; i++) {
        NSTextAttachment *attachment = attachments[i];
        NSArray <NSTextAttachment *>*lines = [attachments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"line == %d",attachment.line]];
        CGRect attachmentFrame = CGRectZero;
        if (lines.count > 1) {
            CGFloat y = [[lines valueForKeyPath:@"@max.originY"] floatValue];
            attachmentFrame = CGRectMake(self.showingRect.origin.x+attachment.origin.x, self.showingRect.origin.y+y-CGRectGetHeight(attachment.bounds), CGRectGetWidth(attachment.bounds), CGRectGetHeight(attachment.bounds));
        } else {
            CGRect frame = CGRectZero;
            frame.origin = attachment.origin;
            frame.size = attachment.bounds.size;
            attachmentFrame = CGRectOffset(frame, self.showingRect.origin.x, self.showingRect.origin.y);
        }
        CGPoint location = [tap locationInView:self];
        if (CGRectContainsPoint(attachmentFrame, location)) {
            if (self.touchImageAtIndex) {
                self.touchImageAtIndex(i);
            }
            break;
        }
    }
}

@end
