//
//  ViewController.m
//  CustomCalender
//
//  Created by Preety Pednekar on 15/05/15.
//  Copyright (c) 2015 Preety Pednekar. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DayButtonCell.h"
#import "Constants.h"


@interface ViewController ()

@property (nonatomic, strong) UIView    *previousView;
@property (nonatomic, strong) UIView    *currentView;
@property (nonatomic, strong) UIView    *nextView;
@property (nonatomic, assign) CGPoint   currentPoint;
@property (nonatomic, strong) NSDictionary *previousMonthDetails;
@property (nonatomic, strong) NSDictionary *currentMonthDetails;
@property (nonatomic, strong) NSDictionary *nextMonthDetails;

@end

@implementation ViewController (Private)

// Form actual grid to show calender of a specified month and specified number of days
- (UIView *) prepareCalenderViewForMonth:(int) month year:(int) year startDay:(int) startDay andTotalDays:(int) totalDays
{
    float viewWidth = 7 * DAY_CELL_WIDTH;
    float viewX = (self.view.frame.size.width - viewWidth)/2;
    UIView *newMonthView = [[UIView alloc] initWithFrame: CGRectMake(viewX, 0, viewWidth, self.calenderView.frame.size.height)];
    
    float x = 0.0;
    float y = 0.0;
    int currentDay = 1;
    
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    // add month name
    UILabel *monthName = [[UILabel alloc] initWithFrame: CGRectMake(0, y, viewWidth, MONTH_NAME_LABEL_HEIGHT)];
    monthName.text = [NSString stringWithFormat: @"%@ %d", [[gregorian monthSymbols] objectAtIndex: (month - 1)], year];
    monthName.textAlignment = NSTextAlignmentCenter;
    monthName.font = [UIFont fontWithName: FONT_NAME size: FONT_SIZE];
    monthName.backgroundColor = [UIColor lightGrayColor];
    [newMonthView addSubview: monthName];
    y += MONTH_NAME_LABEL_HEIGHT;
    
    // add days initials
    NSArray *daysList = [gregorian shortWeekdaySymbols];
    for (NSString *weekDay in daysList)
    {
        DayButtonCell *weekdayCell = (DayButtonCell *)[[[NSBundle mainBundle] loadNibNamed: XIB_DAY_BUTTON_CELL
                                                                                     owner: self
                                                                                   options: nil] objectAtIndex: kTypeWeekdayCell];
        weekdayCell.dayName.text = weekDay;
    
        CGRect frame = weekdayCell.frame;
        frame.origin.x = x;
        frame.origin.y = y;
        weekdayCell.frame = frame;
        
        [newMonthView addSubview: weekdayCell];
        x += DAY_CELL_WIDTH;
    }
    
    // reset x to zero as dates will be loaded in next row
    // also increment y to next row
    x = 0.0;
    y += WEEKDAY_CELL_HEIGHT;
    
    if (startDay != currentDay)
    {
        // if start day is not falling on sunday, move current day to start day and leave some empty spaces for first weekdays till start day is reached
        
        x = (startDay-currentDay) * DAY_CELL_WIDTH;
    }
    
    while (currentDay <= totalDays)
    {
        // Create day button cell
        DayButtonCell *dayCell = (DayButtonCell *)[[[NSBundle mainBundle] loadNibNamed: XIB_DAY_BUTTON_CELL
                                                                                 owner: self
                                                                               options: nil] objectAtIndex: kTypeDateCell];

        dayCell.dateLabel.text = [NSString stringWithFormat: @"%d", currentDay];
        
        CGRect frame = dayCell.frame;
        frame.origin.x = x;
        frame.origin.y = y;
        dayCell.frame  = frame;
        
        [newMonthView addSubview: dayCell];
        
        x+= DAY_CELL_WIDTH;
        
        if (x >= (7*DAY_CELL_WIDTH))
        {
            // one row is full. move to next row
            x = 0;
            y += DAY_CELL_HEIGHT;
        }
        
        currentDay++;
    }
    
    CALayer *layer = newMonthView.layer;
    layer.borderColor = [UIColor lightGrayColor].CGColor;
    layer.borderWidth = 1.0f;
    
    return newMonthView;
}

// prepare previous view of scrollView
-(void) preparePreviousViewOfScrollView
{
    int previousMonth = [[self.currentMonthDetails objectForKey: KEY_MONTH] intValue] - 1;
    int previousYear = [[self.currentMonthDetails objectForKey: KEY_YEAR] intValue];
    if (previousMonth < 1)
    {
        previousMonth = 12;
        previousYear  = previousYear - 1;
    }
    
    self.previousMonthDetails = [self getDetailsForMonth: previousMonth andYear: previousYear];
    self.previousView = [self prepareCalenderViewForMonth: [[self.previousMonthDetails objectForKey: KEY_MONTH] intValue]
                                                     year: previousYear
                                                 startDay: [[self.previousMonthDetails objectForKey: KEY_START_DAY] intValue]
                                             andTotalDays: [[self.previousMonthDetails objectForKey: KEY_TOTAL_DAYS] intValue]];

    [self.calenderView addSubview: self.previousView];
}

// prepare next view of scrollView
-(void) prepareNextViewOfScrollView
{
    int nextMonth = [[self.currentMonthDetails objectForKey: KEY_MONTH] intValue] + 1;
    int nextYear = [[self.currentMonthDetails objectForKey: KEY_YEAR] intValue];
    if (nextMonth > 12)
    {
        nextMonth = 1;
        nextYear  = nextYear + 1;
    }
    
    self.nextMonthDetails = [self getDetailsForMonth: nextMonth andYear: nextYear];
    self.nextView = [self prepareCalenderViewForMonth: [[self.nextMonthDetails objectForKey: KEY_MONTH] intValue]
                                                 year: nextYear
                                             startDay: [[self.nextMonthDetails objectForKey: KEY_START_DAY] intValue]
                                         andTotalDays: [[self.nextMonthDetails objectForKey: KEY_TOTAL_DAYS] intValue]];

    CGRect frame = self.nextView.frame;
    frame.origin.x = (self.view.frame.size.width)*2 + (self.view.frame.size.width - frame.size.width)/2;
    self.nextView.frame = frame;

    [self.calenderView addSubview: self.nextView];
}

// reset calender scrollview to current date
-(void) resetToCurrentDate
{
    [self.previousView removeFromSuperview];
    [self.currentView removeFromSuperview];
    [self.nextView removeFromSuperview];
    
    // get current month and year
    NSDate *jan1 = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy";
    NSString *yearString = [formatter stringFromDate: jan1];
    int year = yearString.intValue;
    formatter.dateFormat = @"MM";
    NSString *monthString = [formatter stringFromDate: jan1];
    int month = monthString.intValue;
    
    float selfWidth = self.view.frame.size.width;
    self.currentMonthDetails = [self getDetailsForMonth: month andYear: year];
    
    // prepare previous view
    [self preparePreviousViewOfScrollView];
    
    // prepare current view
    self.currentView = [self prepareCalenderViewForMonth: [[self.currentMonthDetails objectForKey: KEY_MONTH] intValue]
                                                    year: year
                                                startDay: [[self.currentMonthDetails objectForKey: KEY_START_DAY] intValue]
                                            andTotalDays: [[self.currentMonthDetails objectForKey: KEY_TOTAL_DAYS] intValue]];
    CGRect frame = self.currentView.frame;
    frame.origin.x = selfWidth + (selfWidth - frame.size.width)/2;
    self.currentView.frame = frame;
    [self.calenderView addSubview: self.currentView];
    
    // prepare next view
    [self prepareNextViewOfScrollView];
}

// get current month information
-(NSDictionary *) getDetailsForMonth: (int) month andYear: (int) year
{
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    // create NSDate of 1st day of current month to show the complete calender of current month
    NSDateComponents *dateCom = [[NSDateComponents alloc] init];
    dateCom.day = 1;
    dateCom.month = month;
    dateCom.year = year;

    NSDate *startDate = [gregorian dateFromComponents: dateCom];
    dateCom = [gregorian components: NSCalendarUnitWeekday fromDate: startDate];
    // get weekday for 1st day of current month
    // 1 = Sunday, 2 = Monday and so on
    int startDay = (int)[dateCom weekday];
    
    // get total number of days in a month
    // do set month: dateCom.month = month;
    NSRange range = [gregorian rangeOfUnit: NSCalendarUnitDay
                                    inUnit: NSCalendarUnitMonth
                                   forDate: startDate];
    int totalDays = (int)range.length;
    
    NSDictionary *monthDetailsDict = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: month], KEY_MONTH,
                                      [NSNumber numberWithInt: startDay], KEY_START_DAY,
                                      [NSNumber numberWithInt: totalDays], KEY_TOTAL_DAYS,
                                      [NSNumber numberWithInt: year], KEY_YEAR, nil];
    return monthDetailsDict;
}

#pragma mark - ScrollView delegate

//-(void) scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    NSLog(@"Scrollview did scroll");
//}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"Scrollview did end decelerating");
    
    CGPoint contentOffset = scrollView.contentOffset;
    float selfWidth     = self.view.frame.size.width;
        
    float limitX = self.currentPoint.x + (selfWidth/2);
    if (contentOffset.x > limitX)
    {
        // scrolled right
        
        [self.previousView removeFromSuperview];
        [self.currentView removeFromSuperview];
        [self.nextView removeFromSuperview];
        
        self.nextView.frame     = self.currentView.frame;
        self.currentView.frame  = self.previousView.frame;
        
        self.previousView   = self.currentView;
        self.currentView    = self.nextView;
        
        [scrollView addSubview: self.previousView];
        [scrollView addSubview: self.currentView];
        
        // modify the current month details
        self.previousMonthDetails = self.currentMonthDetails;
        self.currentMonthDetails  = self.nextMonthDetails;
        [self prepareNextViewOfScrollView];
        
    }
    else if (contentOffset.x < self.currentPoint.x)
    {
        // scrolled left
        
        [self.previousView removeFromSuperview];
        [self.currentView removeFromSuperview];
        [self.nextView removeFromSuperview];
        
        self.previousView.frame   = self.currentView.frame;
        self.currentView.frame    = self.nextView.frame;
        
        self.nextView       = self.currentView;
        self.currentView    = self.previousView;
        
        [scrollView addSubview: self.previousView];
        [scrollView addSubview: self.currentView];
        
        // modify currentmonth details
        self.nextMonthDetails       = self.currentMonthDetails;
        self.currentMonthDetails    = self.previousMonthDetails;
        [self preparePreviousViewOfScrollView];
    }
    else
    {
        // scrolled but on same pages
    }
    
    contentOffset.x = selfWidth;
    
    [scrollView setContentOffset: contentOffset];
    self.currentPoint = scrollView.contentOffset;
}


@end

@implementation ViewController

@synthesize calenderView;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"in view did load");
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    // Set contentSize of scrollView
    CGRect calenderFrame = self.calenderView.frame;
    float width = 3 * (calenderFrame.size.width);
    
    [self.calenderView setContentSize: CGSizeMake(width, self.calenderView.frame.size.height)];
    [self.calenderView scrollRectToVisible: CGRectMake(self.view.frame.size.width, calenderFrame.origin.y, calenderFrame.size.width, calenderFrame.size.height) animated: NO];
    self.currentPoint = self.calenderView.contentOffset;
    
    [self resetToCurrentDate];
}

#pragma mark - UIButton action

-(IBAction) resetCalender:(id)sender
{
    [self resetToCurrentDate];
}

#pragma mark - Orientation methods

-(NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
