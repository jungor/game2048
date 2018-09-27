//
//  ViewController.m
//  game2048
//
//  Created by Techsviewer on 2018/9/22.
//  Copyright © 2018年 jungor. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+Util.h"

/* ------- begin 遍历顺序 -------- */
static int leftSeq[4][4] = {
    {0,1,2,3},
    {4,5,6,7},
    {8,9,10,11},
    {12,13,14,15},
};

static int rightSeq[4][4] = {
    {3,2,1,0},
    {7,6,5,4},
    {11,10,9,8},
    {15,14,13,12},
};

static int upSeq[4][4] = {
    {0,4,8,12},
    {1,5,9,13},
    {2,6,10,14},
    {3,7,11,15},
};

static int downSeq[4][4] = {
    {12,8,4,0},
    {13,9,5,1},
    {14,10,6,2},
    {15,11,7,3},
};
/* ------- end 遍历顺序 -------- */

@interface ViewController () {
    BOOL _isFinish;
    NSMutableArray<UIView*> * _gridList;
    NSMutableArray<UIView*> * _cellList;
    NSMutableArray<UILabel*> * _lbList;
    NSDictionary<NSString*, UIColor*> * _bgColorMap;
    NSDictionary<NSString*, UIColor*> * _fgColorMap;
    NSMutableDictionary<NSNumber*, NSMutableArray<UIView*>*> * _gridCellMap;
    NSMutableDictionary<NSNumber*, NSMutableArray<UILabel*>*> * _gridLbMap;
}
@property(nonatomic) BOOL isFinish;
@property(nonatomic, readonly) NSMutableArray<UIView*> *gridList; // 位置
@property(nonatomic, readonly) NSDictionary<NSString*, UIColor*> *bgColorMap; // 背景色对应表
@property(nonatomic, readonly) NSDictionary<NSString*, UIColor*> *fgColorMap; // 字体颜色对应表
@property(nonatomic) NSMutableDictionary<NSNumber*, NSMutableArray<UIView*>*> *gridCellMap; // 记录每个位置的cell（颜色格子）。移动过程中合并之前，可能在同一个位置会有多个cell，所以用数组
@property(nonatomic) NSMutableDictionary<NSNumber*, NSMutableArray<UILabel*>*> *gridLbMap; // 记录每个位置的label（数字文本）

@end

@implementation ViewController

- (NSDictionary<NSString*, UIColor*>*) bgColorMap {
    if (!_bgColorMap) {
        CGFloat hue = 180.0;
        NSMutableArray<UIColor*> *bgColorArray = [[NSMutableArray<UIColor*> alloc] init];
        NSArray *numArray = @[@"2", @"4", @"8", @"16", @"32", @"64", @"128", @"256", @"512", @"1024", @"2048"];
        // 格子背景颜色选择
        while (bgColorArray.count < 11) {
            UIColor *color = [UIColor colorWithHue:hue/360 saturation:1.0 brightness:1.0 alpha:1.0];
            [bgColorArray addObject:color];
            if (bgColorArray.count == 4 || bgColorArray.count == 8) {
                hue += 45;
            } else {
                hue += 15;
            }
        }
        _bgColorMap = [NSDictionary dictionaryWithObjects:bgColorArray forKeys:numArray];
    }
    return _bgColorMap;
}

- (NSDictionary<NSString*, UIColor*>*) fgColorMap {
    if (!_fgColorMap) {
        // 前景色计算
        NSMutableArray<UIColor*> *fgColorArray = [[NSMutableArray<UIColor*> alloc] init];
        NSArray *numArray = self.bgColorMap.allKeys;
        NSArray<UIColor*> *bgColorArray = self.bgColorMap.allValues;
        [bgColorArray enumerateObjectsUsingBlock:^(UIColor *bgColor, NSUInteger idx, BOOL *stop) {
            [fgColorArray addObject:[UIColor textColorWithBackgroundColor:bgColor]];
        }];
        _fgColorMap = [NSDictionary dictionaryWithObjects:fgColorArray forKeys:numArray];
    }
    return _fgColorMap;
}

- (NSMutableArray<UIView*> *) gridList {
    if (!_gridList) {
        NSArray<UIView*> *subViews = self.view.subviews;
        _gridList = [[NSMutableArray alloc] init];
        for (int i = 0; i < subViews.count; i++) {
            [_gridList addObject:subViews[i]];
        }
    }
    return _gridList;
}

//- (NSMutableDictionary<NSNumber*, NSMutableArray<UIView*>*> *) gridCellMap {
//    if (!_gridCellMap) {
//        _gridCellMap = [[NSMutableDictionary alloc]init];
//    }
//    return _gridCellMap;
//}
//
//- (NSMutableDictionary<NSNumber*, NSMutableArray<UILabel*>*> *) gridLbMap {
//    if (!_gridLbMap) {
//        _gridLbMap = [[NSMutableDictionary alloc]init];
//    }
//    return _gridLbMap;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self resetGameGrid];
}

/**
 重置游戏
 */
- (void) resetGameGrid {
    self.gridCellMap = [[NSMutableDictionary alloc] init];
    self.gridLbMap = [[NSMutableDictionary alloc] init];
    int r1 = arc4random_uniform(16);
    int r2;
    do {
        r2 = arc4random_uniform(16);
    } while (r1 == r2);
    //    r1 = 1;
    //    r2 = 2;
    int idxList[2] = {r1, r2};
    for (int i = 0; i < 2; i++) {
        [self createCellAndLbWithRandomNumberAtIndex:idxList[i]];
    }
    [self renderAll];
    
}

/**
 获取某位置grid上的格子cell
 
 @param grid 位置
 @return 对应的格子
 */
- (UIView*) getCellAtGrid:(UIView*)grid {
    //    NSValue *key = [self getKeyOfView:grid];
    NSNumber *key = @([self.gridList indexOfObject:grid]);
    NSMutableArray *cellList = self.gridCellMap[key];
    if (cellList && cellList.count > 0) {
        return cellList[0];
    } else {
        return nil;
    }
}

/**
 获取某位置grid上的标签label
 
 @param grid 位置
 @return 对应的标签
 */
- (UILabel*) getLbAtGrid:(UIView*)grid {
    //    NSValue *key = [self getKeyOfView:grid];
    NSNumber *key = @([self.gridList indexOfObject:grid]);
    NSMutableArray *lbList = self.gridLbMap[key];
    if (lbList && lbList.count > 0) {
        return lbList[0];
    } else {
        return nil;
    }
}


/**
 获取某格子cell所在位置grid
 
 @param cell 格子
 @return 所在位置
 */
- (UIView*) getGridOfCell:(UIView*)cell {
    //    return self.cellGridMap[[self getKeyOfView:cell]];
    for (NSNumber *key in self.gridCellMap) {
        if ([self.gridCellMap[key] containsObject:cell]) {
            return self.gridList[[key intValue]];
        }
    }
    return nil;
}

/**
 获取某标签label所在位置grid
 
 @param lb 标签
 @return 所在位置
 */
- (UIView*) getGridOfLb:(UILabel*)lb {
    for (NSNumber *key in self.gridLbMap) {
        if ([self.gridLbMap[key] containsObject:lb]) {
            return self.gridList[[key intValue]];
        }
    }
    return nil;
}

/**
 把格子cell移动到位置grid
 
 @param cell 格子
 @param grid 位置
 */
- (void) putCell:(UIView*)cell AtGrid:(UIView*)grid {
    NSNumber *key;
    UIView *oldGrid = [self getGridOfCell:cell];
    if (oldGrid == grid) return;
    if (oldGrid) {
        key = @([self.gridList indexOfObject:oldGrid]);
        [self.gridCellMap[key] removeObject:cell];
    }
    key = @([self.gridList indexOfObject:grid]);
    NSMutableArray *cellList = self.gridCellMap[key];
    if (!cellList) {
        cellList = self.gridCellMap[key] = [[NSMutableArray alloc]init];
    }
    [cellList addObject:cell];
}


/**
 把标签移动到位置grid
 
 @param lb 标签
 @param grid 位置
 */
- (void) putLb:(UILabel*)lb AtGrid:(UIView*)grid {
    NSNumber *key;
    UIView *oldGrid = [self getGridOfLb:lb];
    if (oldGrid == grid) return;
    if (oldGrid) {
        key = @([self.gridList indexOfObject:oldGrid]);
        [self.gridLbMap[key] removeObject:lb];
    }
    key = @([self.gridList indexOfObject:grid]);
    NSMutableArray *list = self.gridLbMap[key];
    if (!list) {
        list = self.gridLbMap[key] = [[NSMutableArray alloc]init];
    }
    [list addObject:lb];
}


/**
 在指定索引idx对应的位置创建随机数字的格子和标签
 
 @param idx 位置grid的索引
 */
- (void) createCellAndLbWithRandomNumberAtIndex:(int)idx {
    UIView *cell;
    UIView *grid;
    UILabel *lb;
    NSString *num;
    int r = arc4random_uniform(10);
    if (r == 0) {
        num = @"4";
    } else {
        num = @"2";
    }
    grid = self.gridList[idx];
    cell = [[UIView alloc]initWithFrame:grid.frame];
    cell.backgroundColor = self.bgColorMap[num];
    cell.layer.opacity = 0;
    lb = [[UILabel alloc]initWithFrame:cell.frame];
    lb.layer.opacity = 0;
    lb.text = num;
    lb.textAlignment = NSTextAlignmentCenter;
    lb.textColor = self.fgColorMap[num];
    lb.center = cell.center;
    [self putCell:cell AtGrid:grid];
    [self putLb:lb AtGrid:grid];
    [self.view addSubview:cell];
    [self.view addSubview:lb];
    // 使得有渐入效果
    lb.layer.opacity = 1;
    cell.layer.opacity = 1;
}


/**
 根据最新的位置对应表重新渲染画面，并带动画
 */
- (void) renderAll {
    NSLog(@"rendering");
    __block BOOL hadMove = NO;
    // 移动到新位置
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        for (NSNumber *key in self.gridCellMap) {
            NSArray<UIView*> *cellList = self.gridCellMap[key];
            NSArray<UILabel*> *lbList = self.gridLbMap[key];
            for (int i = 0; i < cellList.count; i++) {
                UIView *cell = cellList[i];
                UILabel*lb = lbList[i];
                UIView *grid = [self getGridOfCell:cell];
                if (![self.view.subviews containsObject:cell]) {
                    [self.view addSubview:cell];
                }
                if (![self.view.subviews containsObject:lb]) {
                    [self.view addSubview:lb];
                }
                if (!CGRectEqualToRect(grid.frame, cell.frame)) {
                    [cell setFrame:grid.frame];
                    [lb setFrame:grid.frame];
                    hadMove = YES;
                }
            }
        };
    } completion:nil];
    
    
    // 合并相同数字
    for (NSNumber *key in self.gridCellMap) {
        NSMutableArray<UIView*> *cellList = self.gridCellMap[key];
        NSMutableArray<UILabel*> *lbList = self.gridLbMap[key];
        if (cellList && cellList.count > 1) {
            UILabel* lb = lbList[0];
            UIView *cell = cellList[0];
            [cellList[1] removeFromSuperview];
            [lbList[1] removeFromSuperview];
            [cellList removeObjectAtIndex:1];
            [lbList removeObjectAtIndex:1];
            lb.text = [NSString stringWithFormat:@"%i", [lb.text intValue]*2];
            lb.textColor = self.fgColorMap[lb.text];
            cell.backgroundColor = self.bgColorMap[lb.text];
            CGAffineTransform oldTf = cell.transform;
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                cell.transform = CGAffineTransformMakeScale(1.2, 1.2);
            } completion:nil];
            [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                cell.transform = oldTf;
            } completion:nil];
            
        }
    };
    // 判断否结束
    [UIView animateWithDuration:0.1 delay:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (hadMove) {
            NSMutableArray<NSNumber*> *arr3 = [[NSMutableArray alloc] init];
            for (int i = 0; i < self.gridList.count; i++) {
                NSNumber *key = @(i);
                NSArray<UIView*> *cellList = self.gridCellMap[key];
                NSArray<UILabel*> *lbList = self.gridLbMap[key];
                if (!cellList || cellList.count == 0) {
                    [arr3 addObject:key];
                } else {
                    if ([lbList[0].text compare:@"1024"] == kCFCompareEqualTo) {
                        self.isFinish = YES;
                        [self didFinishWithTitle:@"你赢了"];
                        return;
                    }
                }
            }
            if (arr3.count > 0) {
                // 未结束需要创建新数字
                int idx = arr3[arc4random_uniform((int)arr3.count)].intValue;
                [self createCellAndLbWithRandomNumberAtIndex:idx];
                NSLog(@"created!");
            } else {
                self.isFinish = YES;
                [self didFinishWithTitle:@"你输了"];
            }
        }
    } completion:nil];
    
}

/**
 根据手势滑动方向dir更新位置对应表

 @param dir 手势滑动方向
 */
- (void)updateWithDir:(UISwipeGestureRecognizerDirection)dir {
    if (self.isFinish) {
        return;
    }
    // 选择遍历顺序
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
        // 有数字的格子view
        NSMutableArray<UIView*> *arr1 = [[NSMutableArray alloc] init];
        // 有数字的格子label
        NSMutableArray<UILabel*> *arr2 = [[NSMutableArray alloc] init];
        for (int idx = 0; idx < 4; idx++) {
            UIView *grid = self.gridList[subSeq[idx]];
            UIView *cell = [self getCellAtGrid:grid];
            UILabel *lb = [self getLbAtGrid:grid];
            if (cell && lb) {
                [arr1 addObject: cell];
                [arr2 addObject:lb];
            }
        }
        // 移动格子（只是更新位置对应表）
        for (int j = 0; j < arr2.count; j++) {
            NSNumber *n1 = @([arr2[j].text intValue]);
            UIView *grid = self.gridList[subSeq[j]];
            [self putCell:arr1[j] AtGrid:grid];
            [self putLb:arr2[j] AtGrid:grid];
            if (j+1 == arr2.count) break;
            NSNumber *n2 = @([arr2[j+1].text intValue]);
            if ([n1 compare:n2] == kCFCompareEqualTo) {
                [self putCell:arr1[j+1] AtGrid:grid];
                [self putLb:arr2[j+1] AtGrid:grid];
                [arr1 removeObjectAtIndex:j+1];
                [arr2 removeObjectAtIndex:j+1];
            }
        }
    }
    [self renderAll];
    
}


/**
 游戏结束时弹窗提醒

 @param title 弹窗标题
 */
- (void) didFinishWithTitle:(NSString*)title {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:@"是否再来一局？"
                                preferredStyle:UIAlertControllerStyleAlert
                                ];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"不了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self resetGameGrid];
        self.isFinish = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:0.5 completion:nil];
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
