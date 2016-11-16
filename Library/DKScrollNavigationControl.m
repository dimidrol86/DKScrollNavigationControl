#import "DKScrollNavigationControl.h"
#import <PureLayout/PureLayout.h>

@interface DKScrollNavigationControl() <UIScrollViewDelegate>

{
    NSMutableArray<UILabel*> *labels;
    CGFloat lastContentOffset;
    NSInteger lastPage;
}

@end


@implementation DKScrollNavigationControl

#pragma mark - initializers
-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}


-(instancetype)init {
    self=[super init];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)initialize {
    
    self.delegate = self;
    
    self.clipsToBounds=NO;
    [self setScrollEnabled:YES];
    [self setPagingEnabled:YES];

}


#pragma mark - Setters
-(void)setSource:(NSArray *)source
{
    _currentPage=0;
    labels=[NSMutableArray new];
    _source=source;
    int i=0;

    for (NSString *s in [_source objectEnumerator]) {
        @autoreleasepool {
            UILabel *l=[[UILabel alloc] initWithFrame:CGRectMake(i*self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
            l.userInteractionEnabled=YES;
            l.tag=i;
            
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap:)];
            [l addGestureRecognizer:tap];
            
            [l setTextAlignment:NSTextAlignmentCenter];
            l.adjustsFontSizeToFitWidth =YES;
            if (_font) {
                [l setFont:_font];
            }
            else {
                int fontsize=15;
                [l setFont:[UIFont systemFontOfSize:fontsize]];
            }
            if (_textColor){
                [l setTextColor:_textColor];
            }
            else {
                [l setTextColor:[UIColor whiteColor]];
            }
            [l setText:s];
            [l setAlpha:(i==0) ? 1.0f : 0.5f];
            [self addSubview:l];
            [labels addObject:l];
        }
        i++;
    }
    
}

-(void)setAsyncScrollView:(UIScrollView *)asyncScrollView {
    _asyncScrollView = asyncScrollView;
    _asyncScrollView.delegate = self;
}


-(void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    for (UILabel *label in [labels objectEnumerator]) {
        [label setTextColor:textColor];
    }
}

-(void)setFont:(UIFont *)font{
    _font = font;
    for (UILabel *label in [labels objectEnumerator]) {
        [label setFont:font];
    }
}

#pragma mark - Actions

-(void)labelTap:(UITapGestureRecognizer*)tap
{
    [self goToPage:tap.view.tag];
}

#pragma mark - handle touches outside bounds of scrollview

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    return view ;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return YES;
}

#pragma mark - custom scroll To methods

-(void)scrollToPage:(NSInteger)page
{
    [self scrollToPage:page animated:false];
}


-(void)scrollToPage:(NSInteger)page animated:(BOOL)animated
{
    CGRect frame = self.frame;
    
    [self setContentOffset:CGPointMake(frame.size.width * page, 0) animated:animated];
    
    if (!animated) {
        
        for (UILabel *label in [labels objectEnumerator]) {
            [label setAlpha:0.5f];
        }
        
        UILabel *curLabel= [labels objectAtIndex:page];
        [curLabel setAlpha:1.0f];
    
    }
}


-(void)goToPage:(NSInteger)page
{
    [UIView animateWithDuration:.25f animations:^{
        [self scrollToPage:page];
        
        if (_asyncScrollView){
            CGRect frame = _asyncScrollView.frame;
            [_asyncScrollView setContentOffset:CGPointMake(frame.size.width * page, 0) animated:NO];
        }
        
    } completion:^(BOOL finished) {}];
}

#pragma mark - helpers
-(CGFloat)scrollCoefficient {
    return self.frame.size.width / _asyncScrollView.frame.size.width;
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //determine scroll direction
    DKScrollDirection scrollDirection;
    if (lastContentOffset > scrollView.contentOffset.x)
        scrollDirection = ScrollDirectionRight;
    else
        scrollDirection = ScrollDirectionLeft;
    
    lastContentOffset = scrollView.contentOffset.x;
    
    //determine page number
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    
    NSInteger p = floorf(fractionalPage);
    if (p >= 0 && p < _source.count) {
        _currentPage=p;
    }
    
    if (scrollView == _asyncScrollView) {
        CGFloat offset=roundf(_asyncScrollView.contentOffset.x * [self scrollCoefficient]);
        self.contentOffset = CGPointMake(offset, 0);
    }
    else if (scrollView == self) {
        
        if (_currentPage != lastPage) {
            if ([_delegateVC respondsToSelector:@selector(DKScrollNavigationControlFinishPageChanging:)]) {
                [_delegateVC DKScrollNavigationControlFinishPageChanging:_currentPage];
            }
        }
        if (_currentPage >= 0 && _currentPage + 1 < _source.count) {
            CGFloat alpha;
            if (scrollDirection==ScrollDirectionLeft)
            {
                alpha=1-0.5f*(scrollView.contentOffset.x-(pageWidth*_currentPage))/pageWidth;
                
                UILabel *l=[labels objectAtIndex:_currentPage];
                [l setAlpha:alpha];
                
                if (labels.count>_currentPage+1) {
                    UILabel *l2=[labels objectAtIndex:_currentPage+1];
                    [l2 setAlpha:1.5f-alpha];
                }
            }
            else if (scrollDirection==ScrollDirectionRight)
            {
                alpha=1+0.5f*(scrollView.contentOffset.x-(pageWidth*(_currentPage+1)))/pageWidth;
                
                UILabel *l=[labels objectAtIndex:_currentPage+1];
                [l setAlpha:alpha];
                
                UILabel *l2=[labels objectAtIndex:_currentPage];
                [l2 setAlpha:1.5f-alpha];
            }
        }
    }
    
    lastPage = _currentPage;
    
    if ([_delegateVC respondsToSelector:@selector(scrollViewDidScroll:)]){
        [_delegateVC scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([_delegateVC respondsToSelector:@selector(scrollViewDidZoom:)]){
        [_delegateVC scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([_delegateVC respondsToSelector:@selector(scrollViewWillBeginDragging:)]){
        [_delegateVC scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([_delegateVC respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]){
        [_delegateVC scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([_delegateVC respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]){
        [_delegateVC scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([_delegateVC respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]){
        [_delegateVC scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([_delegateVC respondsToSelector:@selector(scrollViewDidEndDecelerating:)]){
        [_delegateVC scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if ([_delegateVC respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]){
        [_delegateVC scrollViewDidEndScrollingAnimation:scrollView];
    }

}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([_delegateVC respondsToSelector:@selector(viewForZoomingInScrollView:)]){
        return [_delegateVC viewForZoomingInScrollView:scrollView];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view{
    if ([_delegateVC respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]){
        [_delegateVC scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    if ([_delegateVC respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]){
        [_delegateVC scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if ([_delegateVC respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [_delegateVC scrollViewShouldScrollToTop:scrollView];
    }
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if ([_delegateVC respondsToSelector:@selector(scrollViewDidScrollToTop:)]){
        [_delegateVC scrollViewDidScrollToTop:scrollView];
    }
}


@end
