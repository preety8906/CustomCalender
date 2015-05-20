//
//  Constants.h
//  CustomCalender
//
//  Created by Preety Pednekar on 5/19/15.
//  Copyright (c) 2015 Preety Pednekar. All rights reserved.
//

#ifndef CustomCalender_Constants_h
#define CustomCalender_Constants_h

enum DayButtonCellType
{
    kTypeDateCell = 0,
    kTypeWeekdayCell
};

#define DAY_CELL_WIDTH              50
#define DAY_CELL_HEIGHT             50
#define WEEKDAY_CELL_HEIGHT         40
#define MONTH_NAME_LABEL_HEIGHT     50

#define KEY_MONTH                   @"month"
#define KEY_START_DAY               @"startDay"
#define KEY_TOTAL_DAYS              @"totalDays"
#define KEY_YEAR                    @"year"

#define FONT_NAME                   @"Helvetica-Bold"
#define FONT_SIZE                   20.0f

// Nib names
#define XIB_VIEW_CONTROLLER         @"ViewController"
#define XIB_DAY_BUTTON_CELL         @"DayButtonCell"

#endif
