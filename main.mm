#import <UIKit/UIKit.h>

// إنشاء واجهة لوحة تحكم الأوتو تاتش العائمة
@interface AutoTouchWindow : UIWindow
@property (nonatomic, strong) UIButton *floatingButton;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UISlider *speedSlider;
@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, assign) BOOL isRunning;
@end

@implementation AutoTouchWindow

- (instancetype)init {
    // جعل النافذة تظهر فوق كل شيء طوال الوقت على الشاشة
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:screenBounds];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 10;
        self.backgroundColor = [UIColor clearColor];
        [self setHidden:NO];
        
        self.isRunning = NO;
        [self createFloatingButton];
        [self createMenuView];
    }
    return self;
}

// 1. إنشاء واجهة الزر العائم وقابليته للتحريك والسحب
- (void)createFloatingButton {
    self.floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.floatingButton.frame = CGRectMake(50, 150, 60, 60);
    self.floatingButton.backgroundColor = [UIColor systemBlueColor];
    self.floatingButton.layer.cornerRadius = 30;
    self.floatingButton.layer.shadowOpacity = 0.5;
    self.floatingButton.layer.shadowRadius = 5;
    self.floatingButton.layer.shadowOffset = CGSizeMake(0, 3);
    
    // إضافة أيقونة النقرة داخل الزر
    if (@available(iOS 13.0, *)) {
        [self.floatingButton setImage:[UIImage systemImageNamed:@"hand.tap.fill"] forState:UIControlStateNormal];
        self.floatingButton.tintColor = [UIColor whiteColor];
    }
    
    // إضافة ميزة تحريك وسحب الزر بالإصبع طوال الوقت
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.floatingButton addGestureRecognizer:panGesture];
    
    // إضافة ميزة النقر لفتح القائمة
    [self.floatingButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.floatingButton];
}

// دالة تحريك الزر العائم مع حركة الإصبع
- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self];
}

// 2. إنشاء قائمة الخصائص والمميزات (لوحة التحكم)
- (void)createMenuView {
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 320)];
    self.menuView.center = self.center;
    self.menuView.backgroundColor = [[UIColor systemBackgroundColor] colorWithAlphaComponent:0.95];
    self.menuView.layer.cornerRadius = 20;
    self.menuView.layer.shadowOpacity = 0.4;
    self.menuView.layer.shadowRadius = 15;
    self.menuView.hidden = YES; // مخفية في البداية
    
    // عنوان اللوحة
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 260, 25)];
    titleLabel.text = @"لوحة تحكم الأوتو";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.menuView addSubview:titleLabel];
    
    // زر تشغيل وإيقاف الأوتو
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.toggleButton.frame = CGRectMake(20, 60, 240, 50);
    self.toggleButton.backgroundColor = [UIColor systemGreenColor];
    [self.toggleButton setTitle:@"▶️ تشغيل الأوتو" forState:UIControlStateNormal];
    [self.toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.toggleButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.toggleButton.layer.cornerRadius = 12;
    [self.toggleButton addTarget:self action:@selector(toggleAutoClick) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:self.toggleButton];
    
    // نص شريط السرعة
    self.speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 240, 20)];
    self.speedLabel.text = @"سرعة النقر: 1.0 ثانية";
    self.speedLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    [self.menuView addSubview:self.speedLabel];
    
    // شريط السرعة لتقليل وزيادة السرعة
    self.speedSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 160, 240, 30)];
    self.speedSlider.minimumValue = 0.1;
    self.speedSlider.maximumValue = 5.0;
    self.speedSlider.value = 1.0;
    [self.speedSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.menuView addSubview:self.speedSlider];
    
    // زر إضافة هدف / نقرة جديدة
    UIButton *addTargetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    addTargetBtn.frame = CGRectMake(20, 210, 240, 45);
    addTargetBtn.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.1];
    [addTargetBtn setTitle:@"➕ إضافة هدف (نقرة)" forState:UIControlStateNormal];
    [addTargetBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    addTargetBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    addTargetBtn.layer.cornerRadius = 10;
    [addTargetBtn addTarget:self action:@selector(addTargetClick) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:addTargetBtn];
    
    // زر مسح الأهداف
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    clearBtn.frame = CGRectMake(20, 265, 240, 30);
    [clearBtn setTitle:@"مسح الأهداف" forState:UIControlStateNormal];
    [clearBtn setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    clearBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [clearBtn addTarget:self action:@selector(clearTargetsClick) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:clearBtn];
    
    [self addSubview:self.menuView];
}

// دالة فتح وإغلاق القائمة عند النقر على الزر العائم
- (void)toggleMenu {
    [UIView animateWithDuration:0.3 animations:^{
        self.menuView.hidden = !self.menuView.hidden;
    }];
}

// دالة تشغيل وإيقاف الأوتو (الزر الأخضر/الأحمر)
- (void)toggleAutoClick {
    self.isRunning = !self.isRunning;
    if (self.isRunning) {
        self.toggleButton.backgroundColor = [UIColor systemRedColor];
        [self.toggleButton setTitle:@"🛑 إيقاف الأوتو" forState:UIControlStateNormal];
        self.floatingButton.backgroundColor = [UIColor systemGreenColor];
    } else {
        self.toggleButton.backgroundColor = [UIColor systemGreenColor];
        [self.toggleButton setTitle:@"▶️ تشغيل الأوتو" forState:UIControlStateNormal];
        self.floatingButton.backgroundColor = [UIColor systemBlueColor];
    }
}

// دالة تحديث نص السرعة عند تحريك الشريط
- (void)sliderChanged:(UISlider *)sender {
    self.speedLabel.text = [NSString stringWithFormat:@"سرعة النقر: %.1f ثانية", sender.value];
}

- (void)addTargetClick {
    // كود إضافة نقطة الهدف على الشاشة
}

- (void)clearTargetsClick {
    // كود مسح نقاط الأهداف وإعادة التعيين
    if (self.isRunning) [self toggleAutoClick];
}

@end

// تشغيل الأداة تلقائياً عند تحميل ملف الـ dylib داخل النظام
static void __attribute__((constructor)) initialize(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        static AutoTouchWindow *window = nil;
        window = [[AutoTouchWindow alloc] init];
    });
}
