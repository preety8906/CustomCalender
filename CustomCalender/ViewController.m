//
//  ViewController.m
//  CustomCalender
//
//  Created by Preety Pednekar on 15/05/15.
//  Copyright (c) 2015 Preety Pednekar. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
@property (nonatomic, strong) NSMutableDictionary *previousMonthDetails;
@property (nonatomic, strong) NSMutableDictionary *currentMonthDetails;
@property (nonatomic, strong) NSMutableDictionary *nextMonthDetails;
@property (nonatomic, strong) NSDate    *todayDate;

@end

@implementation ViewController (Private)

// check if today
-(BOOL) isDayToday:(int) day month:(int) month andYear:(int) year
{
    BOOL isToday = NO;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy";
    NSString *yearString = [formatter stringFromDate: self.todayDate];
    int todayYear = yearString.intValue;
    formatter.dateFormat = @"MM";
    NSString *monthString = [formatter stringFromDate: self.todayDate];
    int todayMonth = monthString.intValue;
    formatter.dateFormat = @"dd";
    NSString *dateString = [formatter stringFromDate: self.todayDate];
    int todayDay = dateString.intValue;
    
    if (todayDay == day && todayMonth == month && todayYear == year)
    {
        isToday = YES;
    }
    
    return isToday;
}

// Form actual grid to show calender of a specified month and specified number of days
-(UIView *) prepareCalenderViewWithMonthDict: (NSDictionary *) monthDict
{
    int month       = (int)[[monthDict objectForKey: KEY_MONTH] intValue];
    int year        = (int)[[monthDict objectForKey: KEY_YEAR] intValue];
    int startDay    = (int)[[monthDict objectForKey: KEY_START_DAY] intValue];
    int totalDays   = (int)[[monthDict objectForKey: KEY_TOTAL_DAYS] intValue];
    int preMonthTotalDays   = (int)[[monthDict objectForKey: KEY_PREVIOUS_TOTAL_DAYS] intValue];
    
    self.todayDate = [NSDate date];
    
    float viewWidth = 7 * DAY_CELL_WIDTH;   // a week has 7 days so multiply by 7
    float viewX = (self.view.frame.size.width - viewWidth)/2;
    UIView *newMonthView = [[UIView alloc] initWithFrame: CGRectMake(viewX, 0, viewWidth, self.calenderView.frame.size.height)];
    
    float x = 0.0;
    float y = 0.0;
    int currentDay = 1; // start week from Sunday (=1)
    
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
        // if start day is not falling on sunday, move current day to start day and fill the last dates of previous months for first weekdays till start day is reached
        
        int datePointer = 1; // start from sunday (=1)
        while (datePointer < startDay)
        {
            // Create day button cell
            DayButtonCell *dayCell = (DayButtonCell *)[[[NSBundle mainBundle] loadNibNamed: XIB_DAY_BUTTON_CELL
                                                                                     owner: self
                                                                                   options: nil] objectAtIndex: kTypeDateCell];
            
            dayCell.preNextDateLabel.text   = [NSString stringWithFormat: @"%d", (preMonthTotalDays - startDay + datePointer + 1)];
            dayCell.preNextDateLabel.hidden = NO;
            dayCell.dateLabel.hidden        = YES;
            
            CGRect frame = dayCell.frame;
            frame.origin.x = x;
            frame.origin.y = y;
            dayCell.frame  = frame;
            
            [newMonthView addSubview: dayCell];
            
            // increment x to place next tile for next date
            x+= DAY_CELL_WIDTH;
            datePointer++;
        }
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
        
        if ([self isDayToday: currentDay month: month andYear: year])
        {
            dayCell.backgroundView.backgroundColor = [UIColor greenColor];
        }
        
        [newMonthView addSubview: dayCell];
        
        // increment x to place next tile for next date
        x+= DAY_CELL_WIDTH;
        
        if (x >= (7*DAY_CELL_WIDTH))
        {
            // one row is full. move to next row and reset x to 0
            x = 0;
            y += DAY_CELL_HEIGHT;
        }
        
        currentDay++;
    }
    
    int nextMonthStartDate = 1;
    
    while (x != 0 && x < (7 * DAY_CELL_WIDTH))
    {
        // if end day is not falling on saturday, fill the last weekdays by next month start dates
        
        // Create day button cell
        DayButtonCell *dayCell = (DayButtonCell *)[[[NSBundle mainBundle] loadNibNamed: XIB_DAY_BUTTON_CELL
                                                                                 owner: self
                                                                               options: nil] objectAtIndex: kTypeDateCell];
                
        dayCell.preNextDateLabel.text   = [NSString stringWithFormat: @"%d", nextMonthStartDate++];
        dayCell.preNextDateLabel.hidden = NO;
        dayCell.dateLabel.hidden        = YES;
                
        CGRect frame = dayCell.frame;
        frame.origin.x = x;
        frame.origin.y = y;
        dayCell.frame  = frame;
                
        [newMonthView addSubview: dayCell];
                
        // increment x to place next tile for next date
        x+= DAY_CELL_WIDTH;
    }
    
    return newMonthView;
}

// prepare previous view of scrollView
-(void) preparePreviousViewOfScrollView
{
    int previousMonth = [[self.currentMonthDetails objectForKey: KEY_MONTH] intValue] - 1;
    int previousYear = [[self.currentMonthDetails objectForKey: KEY_YEAR] intValue];

    if (previousMonth < 1)
    {
        // if current month is Jan (=1) then previous month will be Dec(=12) of previous year.
        previousMonth = 12;
        previousYear--;
    }

    // Calculate number of days of previous month of previous month
    int prepreMonth   = previousMonth - 1;
    int prepreYear    = previousYear;
    if (prepreMonth < 1)
    {
        prepreMonth = 12;
        prepreYear--;
    }

    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    // create NSDate of 1st day of current month to show the complete calender of current month
    NSDateComponents *dateCom = [[NSDateComponents alloc] init];
    dateCom.day = 1;
    dateCom.month = prepreMonth;
    dateCom.year = prepreYear;
    
    NSDate *startDate = [gregorian dateFromComponents: dateCom];
    dateCom = [gregorian components: NSCalendarUnitWeekday fromDate: startDate];
    
    // get total number of days in a month
    // do set month: dateCom.month = month;
    NSRange range = [gregorian rangeOfUnit: NSCalendarUnitDay
                                    inUnit: NSCalendarUnitMonth
                                   forDate: startDate];
    int preMonthTotalDays = (int)range.length;
    
    self.previousMonthDetails = [self getDetailsForMonth: previousMonth andYear: previousYear];
    [self.previousMonthDetails setObject: [NSNumber numberWithInt: preMonthTotalDays] forKey: KEY_PREVIOUS_TOTAL_DAYS];

    self.previousView = [self prepareCalenderViewWithMonthDict: self.previousMonthDetails];

    [self.calenderView addSubview: self.previousView];
}

// prepare next view of scrollView
-(void) prepareNextViewOfScrollView
{
    int nextMonth = [[self.currentMonthDetails objectForKey: KEY_MONTH] intValue] + 1;
    int nextYear = [[self.currentMonthDetails objectForKey: KEY_YEAR] intValue];
    if (nextMonth > 12)
    {
        // if current month is Dec (=12) then next month will be Jan (=1) of next year.
        nextMonth = 1;
        nextYear  = nextYear + 1;
    }
    
    self.nextMonthDetails = [self getDetailsForMonth: nextMonth andYear: nextYear];
    [self.nextMonthDetails setObject: [self.currentMonthDetails objectForKey: KEY_TOTAL_DAYS] forKey: KEY_PREVIOUS_TOTAL_DAYS];
    
    self.nextView = [self prepareCalenderViewWithMonthDict: self.nextMonthDetails];
    
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
    [self.currentMonthDetails setObject: [self.previousMonthDetails objectForKey: KEY_TOTAL_DAYS] forKey: KEY_PREVIOUS_TOTAL_DAYS];
    self.currentView = [self prepareCalenderViewWithMonthDict: self.currentMonthDetails];
    
    CGRect frame = self.currentView.frame;
    frame.origin.x = selfWidth + (selfWidth - frame.size.width)/2;
    self.currentView.frame = frame;
    [self.calenderView addSubview: self.currentView];
    
    // prepare next view
    [self prepareNextViewOfScrollView];
}

// get current month information
-(NSMutableDictionary *) getDetailsForMonth: (int) month andYear: (int) year
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
    
    NSMutableDictionary *monthDetailsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: month], KEY_MONTH,
                                      [NSNumber numberWithInt: startDay], KEY_START_DAY,
                                      [NSNumber numberWithInt: totalDays], KEY_TOTAL_DAYS,
                                      [NSNumber numberWithInt: year], KEY_YEAR, nil];
    return monthDetailsDict;
}

#pragma mark - ScrollView delegate

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
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
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    // Set contentSize of scrollView
    CGRect calenderFrame = self.calenderView.frame;
    
    // multiply by 3 as only 3 views are taken to manage the calender scroll view
    float width = 3 * (calenderFrame.size.width);
    
    [self.calenderView setContentSize: CGSizeMake(width, self.calenderView.frame.size.height)];
    [self.calenderView scrollRectToVisible: CGRectMake(self.view.frame.size.width, calenderFrame.origin.y, calenderFrame.size.width, calenderFrame.size.height) animated: NO];
    self.currentPoint = self.calenderView.contentOffset;
    
    // by default, load current, previous and next months
    [self resetToCurrentDate];
}

#pragma mark - UIButton action

// method to reset the calender to current month
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
