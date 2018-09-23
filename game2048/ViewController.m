//
//  ViewController.m
//  game2048
//
//  Created by Techsviewer on 2018/9/22.
//  Copyright © 2018年 jungor. All rights reserved.
//

#import "ViewController.h"

int leftSeq[4][4] = {
    {0,1,2,3},
    {4,5,6,7},
    {8,9,10,11},
    {12,13,14,15},
};

int rightSeq[4][4] = {
    {3,2,1,0},
    {7,6,4,5},
    {11,10,9,8},
    {15,14,13,12},
};

int upSeq[4][4] = {
    {0,4,8,12},
    {1,5,9,13},
    {2,6,10,14},
    {3,7,11,15},
};

int downSeq[4][4] = {
    {12,8,4,0},
    {13,9,5,1},
    {14,10,6,2},
    {15,11,7,3},
};

BOOL isFinish = NO;

NSMutableArray<UILabel*> *lbList;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    lbList = [[NSMutableArray alloc] init];
    id subViews = self.view.subviews;
    for (int i = 0; i < [subViews count]; i++) {
        [lbList addObject:[subViews[i] subviews][0]];
    }
    int r1 = arc4random_uniform(16);
    int r2;
    do {
        r2 = arc4random_uniform(16);
    } while (r1 == r2);
    UIView *sv = subViews[r1];
    UILabel *label = sv.subviews[0];
    label.text = [self getNewNumber];
    sv = subViews[r2];
    label = sv.subviews[0];
    label.text = [self getNewNumber];
//    NSLog(@"%@", lbList.description);
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)updateWithDir: (UISwipeGestureRecognizerDirection) dir {
    if (isFinish) {
        return;
    }
    id subViews = self.view.subviews;
    int (*seq)[4] = NULL;
    switch (dir) {
        case UISwipeGestureRecognizerDirectionRight:
            seq = rightSeq;
            break;
        case UISwipeGestureRecognizerDirectionUp:
            seq = upSeq;
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            seq = leftSeq;
            break;
        case UISwipeGestureRecognizerDirectionDown:
            seq = downSeq;
            break;
        default:
            break;
    }
    for (int i = 0; i < 4; i++) {
        int *subSeq = seq[i];
        // 有数字的格子的数字
        NSMutableArray<NSNumber*> *arr1 = [[NSMutableArray alloc] init];
        // 压缩完的数字
        NSMutableArray<NSNumber*> *arr2 = [[NSMutableArray alloc] init];
        for (int idx = 0; idx < 4; idx++) {
            UIView *sv = subViews[subSeq[idx]];
            UILabel *lb = sv.subviews[0];
            if (lb.text.length > 0) {
                [arr1 addObject: [NSNumber numberWithInt:lb.text.intValue]];
            }
        }
        if (arr1.count > 0) {
            [arr2 addObject:arr1[0]];
        }
        for (int j = 1; j < arr1.count; j++) {
            NSNumber *n1 = arr1[j-1];
            NSNumber *n2 = arr1[j];
            if ([n1 compare:n2] == kCFCompareEqualTo) {
                arr2[arr2.count-1] = [NSNumber numberWithInt:(n1.intValue * 2)];
            } else {
                [arr2 addObject:n2];
            }
        }
        for (int idx = 0; idx < 4; idx++) {
            UILabel *lb = lbList[subSeq[idx]];
            if (idx < arr2.count) {
                lb.text = [arr2[idx] stringValue];
            } else {
                lb.text = nil;
            }
        }
    }
    // 压缩完没数字的格子
    NSMutableArray<NSNumber*> *arr3 = [[NSMutableArray alloc] init];
    for (int i = 0; i < 16; i++) {
        if (lbList[i].text.length == 0) {
            [arr3 addObject:[NSNumber numberWithInt:i]];
        } else {
            if ([lbList[i].text compare:@"128"] == kCFCompareEqualTo) {
                isFinish = YES;
                return;
            }
        }
    }
    if (arr3.count > 0) {
        int r = arc4random_uniform((int)arr3.count);
        lbList[arr3[r].intValue].text = [self getNewNumber];
    }
    // todo: check if fail
}

- (NSString*) getNewNumber {
    int r = arc4random_uniform(10);
    if (r <= 3) {
        return @"4";
    } else {
        return @"2";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didSwipeRight:(id)sender {
    NSLog(@"向右滑了");
    UISwipeGestureRecognizer *sgr = sender;
    [self updateWithDir:sgr.direction];
}

- (IBAction)didSwipeLeft:(id)sender {
    NSLog(@"向左滑了");
    UISwipeGestureRecognizer *sgr = sender;
    [self updateWithDir:sgr.direction];
}

- (IBAction)didSwipeDown:(id)sender {
    NSLog(@"向下滑了");
    UISwipeGestureRecognizer *sgr = sender;
    [self updateWithDir:sgr.direction];
}

- (IBAction)didSwipeUp:(id)sender {
    NSLog(@"向上滑了");
    UISwipeGestureRecognizer *sgr = sender;
    [self updateWithDir:sgr.direction];
}


@end
