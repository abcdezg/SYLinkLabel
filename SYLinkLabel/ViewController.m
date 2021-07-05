//
//  ViewController.m
//  SYLinkLabel
//
//  Created by mac on 2021/7/5.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import "SYLinkLabel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    UIScrollView *scrollView = [UIScrollView new];
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    NSArray *arr = @[@"https://th.bing.com/th/id/OIP.fz7YF7WM34x7Z5JLnnqFdAHaEM?pid=ImgDet&rs=1",
                     @"https://th.bing.com/th/id/OIP.G_ux0rS2aGQBgFpNchSzlAHaEo?pid=ImgDet&rs=1",
                     @"https://www.shijuepi.com/uploads/allimg/200924/1-200924110P5.jpg",
                     @"https://th.bing.com/th/id/OIP.gI3wopkH8Hc-rw1Lh0lKVQHaEo?pid=ImgDet&rs=1",
                     @"https://th.bing.com/th/id/OIP.fz7YF7WM34x7Z5JLnnqFdAHaEM?pid=ImgDet&rs=1"
    ];
    
    NSMutableString *strM = [NSMutableString string];
    CGFloat screenWidth = CGRectGetWidth(UIScreen.mainScreen.bounds);
    CGFloat halfWidth = floor(screenWidth*0.5);
    // 支持全局css
//    [strM appendFormat:@"<style>img{width:%.0fpx;height:auto;}div{display:block;}</style>",halfWidth];
    for (int i = 0; i < arr.count; i++) {
        NSString *subStr = arr[i];
        if (i == 0) {
            [strM appendString:[NSString stringWithFormat:@"<div style=\"width:50%%;height:auto;\"><img src=\"%@\"/></div>",subStr]];
            
        }
        else if (i == 1 || i == 2) {
            [strM appendString:[NSString stringWithFormat:@"<span><img src=\"%@\" style=\"width:%.0fpx;height:auto;\"/></span>",subStr,halfWidth]];
        }
        else if (i == 3) {
            [strM appendString:[NSString stringWithFormat:@"<span style=\"width:25%%;height:20px;\">You can click image now.</span><span><img src=\"%@\" style=\"width:25%%;height:auto;\"/></span>",subStr]];
        }
        else {
            [strM appendString:[NSString stringWithFormat:@"</br><span style=\"margin-left:20px;\">The margin-left style didn't work!</span><span><img src=\"%@\" style=\"width:25%%;height:auto;\"/></span>",subStr]];
        }
    }
    
//    //简单拼接
//    for (int i = 0; i < arr.count; i++) {
//        NSString *subStr = arr[i];
//        [strM appendString:[NSString stringWithFormat:@"<div><img src=\"%@\"'/></div>",subStr]];
//    }
    
//    NSString *str = [NSString stringWithFormat:@"<style>img{max-width:50%%;height:auto;}</style><div><img src=\"%@\"/></div>",[arr componentsJoinedByString:@"\"/></div><div><img src=\""]];
    NSData *data = [strM dataUsingEncoding:NSUnicodeStringEncoding];
    NSAttributedString *strAttr = [[NSAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentOption:NSHTMLTextDocumentType,NSCharacterEncodingDocumentOption:@(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
    
    SYLinkLabel *lbl = [SYLinkLabel new];
    lbl.contentMode = UIViewContentModeScaleAspectFit;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.numberOfLines = 0;
    lbl.attributedText = strAttr;
    lbl.touchImageAtIndex = ^(NSUInteger idx) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"点击了第%zd张图片",idx+1] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    };
    [scrollView addSubview:lbl];
    [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(self.view);
        make.height.greaterThanOrEqualTo(self.view);
    }];
    
}


@end
