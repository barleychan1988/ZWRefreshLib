//  代码地址: https://github.com/CoderMJLee/MJRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
//  UIScrollView+MJRefresh.m
//  MJRefreshExample
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "UIScrollView+MJRefresh.h"
#import "MJRefreshHeader.h"
#import "MJRefreshFooter.h"
#import "MJRefreshTrailer.h"
#import <objc/runtime.h>

#import "SCRefreshHeader.h"
#import "SCStaticHeader.h"
#import "SCAutoFooter.h"

@implementation NSObject (MJRefresh)

+ (void)exchangeInstanceMethod1:(SEL)method1 method2:(SEL)method2
{
    method_exchangeImplementations(class_getInstanceMethod(self, method1), class_getInstanceMethod(self, method2));
}

+ (void)exchangeClassMethod1:(SEL)method1 method2:(SEL)method2
{
    method_exchangeImplementations(class_getClassMethod(self, method1), class_getClassMethod(self, method2));
}

@end

@implementation UIScrollView (MJRefresh)

#pragma mark - header
static const char MJRefreshHeaderKey = '\0';
- (void)setMj_header:(MJRefreshHeader *)mj_header
{
    if (mj_header != self.mj_header) {
        // 删除旧的，添加新的
        [self.mj_header removeFromSuperview];
        [self insertSubview:mj_header atIndex:0];
        
        // 存储新的
        objc_setAssociatedObject(self, &MJRefreshHeaderKey,
                                 mj_header, OBJC_ASSOCIATION_RETAIN);
    }
}

- (MJRefreshHeader *)mj_header
{
    return objc_getAssociatedObject(self, &MJRefreshHeaderKey);
}

#pragma mark - footer
static const char MJRefreshFooterKey = '\0';
- (void)setMj_footer:(MJRefreshFooter *)mj_footer
{
    if (mj_footer != self.mj_footer) {
        // 删除旧的，添加新的
        [self.mj_footer removeFromSuperview];
        [self insertSubview:mj_footer atIndex:0];
        
        // 存储新的
        objc_setAssociatedObject(self, &MJRefreshFooterKey,
                                 mj_footer, OBJC_ASSOCIATION_RETAIN);
    }
}

- (MJRefreshFooter *)mj_footer
{
    return objc_getAssociatedObject(self, &MJRefreshFooterKey);
}

#pragma mark - footer
static const char MJRefreshTrailerKey = '\0';
- (void)setMj_trailer:(MJRefreshTrailer *)mj_trailer {
    if (mj_trailer != self.mj_trailer) {
        // 删除旧的，添加新的
        [self.mj_trailer removeFromSuperview];
        [self insertSubview:mj_trailer atIndex:0];
        
        // 存储新的
        objc_setAssociatedObject(self, &MJRefreshTrailerKey,
                                 mj_trailer, OBJC_ASSOCIATION_RETAIN);
    }
}

- (MJRefreshTrailer *)mj_trailer {
    return objc_getAssociatedObject(self, &MJRefreshTrailerKey);
}

#pragma mark - 过期
- (void)setFooter:(MJRefreshFooter *)footer
{
    self.mj_footer = footer;
}

- (MJRefreshFooter *)footer
{
    return self.mj_footer;
}

- (void)setHeader:(MJRefreshHeader *)header
{
    self.mj_header = header;
}

- (MJRefreshHeader *)header
{
    return self.mj_header;
}

#pragma mark - other
- (NSInteger)mj_totalDataCount
{
    NSInteger totalCount = 0;
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;

        for (NSInteger section = 0; section < tableView.numberOfSections; section++) {
            totalCount += [tableView numberOfRowsInSection:section];
        }
    } else if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;

        for (NSInteger section = 0; section < collectionView.numberOfSections; section++) {
            totalCount += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalCount;
}

static const char MJRefreshReloadDataBlockKey = '\0';
- (void)setMj_reloadDataBlock:(void (^)(NSInteger))mj_reloadDataBlock
{
    [self willChangeValueForKey:@"mj_reloadDataBlock"]; // KVO
    objc_setAssociatedObject(self, &MJRefreshReloadDataBlockKey, mj_reloadDataBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"mj_reloadDataBlock"]; // KVO
}

- (void (^)(NSInteger))mj_reloadDataBlock
{
    return objc_getAssociatedObject(self, &MJRefreshReloadDataBlockKey);
}

- (void)executeReloadDataBlock
{
    !self.mj_reloadDataBlock ? : self.mj_reloadDataBlock(self.mj_totalDataCount);
}
@end

@implementation UITableView (MJRefresh)

+ (void)load
{
    [self exchangeInstanceMethod1:@selector(reloadData) method2:@selector(mj_reloadData)];
}

- (void)mj_reloadData
{
    [self mj_reloadData];
    
    [self executeReloadDataBlock];
}
@end

@implementation UICollectionView (MJRefresh)

+ (void)load
{
    [self exchangeInstanceMethod1:@selector(reloadData) method2:@selector(mj_reloadData)];
}

- (void)mj_reloadData
{
    [self mj_reloadData];
    
    [self executeReloadDataBlock];
}
@end

@implementation UIScrollView (AddRefresh)

#pragma mark header

- (void)addHeaderWithTarget:(id)target action:(SEL)action
{
    if (target == nil || action == nil)
    {
        __block UIScrollView *scrollViewSelf = self;
        self.mj_header = [SCStaticHeader headerWithRefreshingBlock:^{[scrollViewSelf.mj_header endRefreshing];}];
    }
    else
    {
        self.mj_header = [SCRefreshHeader headerWithRefreshingTarget:target refreshingAction:action];
    }
}

- (void)addHeaderWithCallback:(void (^)(void))callback
{
    if (callback == nil)
    {
        __block UIScrollView *scrollViewSelf = self;
        self.mj_header = [SCStaticHeader headerWithRefreshingBlock:^{[scrollViewSelf.mj_header endRefreshing];}];
    }
    else
    {
        self.mj_header = [SCRefreshHeader headerWithRefreshingBlock:callback];
    }
}

- (void)headerBeginRefreshing
{
    [self.mj_header beginRefreshing];
}

- (void)headerEndRefreshing
{
    [self.mj_header endRefreshing];
}

#pragma mark footer

- (void)addFooterWithTarget:(id)target action:(SEL)action
{
    if (target == nil || action == nil)
    {
    }
    else
    {
        SCAutoFooter *footer = [SCAutoFooter footerWithRefreshingTarget:target refreshingAction:action];
        self.mj_footer = footer;
        footer.refreshingTitleHidden = YES;
    }
}

- (void)addFooterWithCallback:(void (^)(void))callback
{
    if (callback == nil)
    {
    }
    else
    {
        SCAutoFooter *footer = [SCAutoFooter footerWithRefreshingBlock:callback];
        self.mj_footer = footer;
        footer.refreshingTitleHidden = YES;
    }
}
/**
 *  移除上拉刷新尾部控件
 */
- (void)removeFooter
{
    [self.mj_footer removeFromSuperview];
    self.mj_footer = nil;
}

/**
 *  主动让上拉刷新尾部控件进入刷新状态
 */
- (void)footerBeginRefreshing
{
    [self.mj_footer beginRefreshing];
}

- (void)footerEndRefreshing
{
    [self.mj_footer endRefreshing];
}

- (void)footerFinishedRefreshing
{
    [self.mj_footer endRefreshingWithNoMoreData];
}

@end
