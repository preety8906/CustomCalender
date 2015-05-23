//
//  Constants.h
//  CustomCalender
//
//  Created by Preety Pednekar on 5/19/15.
//  Copyright (c) 2015 Preety Pednekar.
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
