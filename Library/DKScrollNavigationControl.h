
#import <UIKit/UIKit.h>

typedef enum scrolldirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} DKScrollDirection;

@protocol DKScrollNavigationControlDelegate <NSObject,UIScrollViewDelegate>
-(void)DKScrollNavigationControlFinishPageChanging:(NSInteger)page;
@end

@interface DKScrollNavigationControl : UIScrollView

/** DKScrollNavigationControl delegate */
@property (nonatomic,nullable,weak) id<DKScrollNavigationControlDelegate> delegateVC;

/** Source array of strings with the name items */
@property (nonatomic,nullable,strong) NSArray <NSString*> *source;

/** Current page */
@property (nonatomic,readonly) NSInteger currentPage;



/** Corresponding scroll view for async scroll */
@property (nonatomic,nullable,weak) UIScrollView *asyncScrollView;

/** Strip color */
@property (nonatomic,nullable,strong) UIColor *stripColor;

/** Items text color */
@property (nonatomic,nullable,strong) UIColor *textColor;

/** Strip height */
@property (nonatomic) CGFloat stripHeight;


/** Go to specific page */
-(void)goToPage:(NSInteger)page;

@end
