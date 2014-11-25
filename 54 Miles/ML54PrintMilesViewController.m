//
//  ML54PrintMilesViewController.m
//  54 Miles
//
//  Created by Chris Goodwin on 1/7/14.
//  Copyright (c) 2014 Chris Goodwin. All rights reserved.
//

#import "ML54PrintMilesViewController.h"
#import "UserMiles.h"
#define miles54Queue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define miles54MileageRateURL [NSURL URLWithString:@"http://www.hannylicious.com/54/current-mileage.php"] //2
#import <QuartzCore/QuartzCore.h>

@interface ML54PrintMilesViewController ()
{
    NSArray *monthArray, *allTableData;
    NSMutableArray *yearArray;
    NSString *selectedMonth;
    NSString *selectedYear;
    NSDate *startOfMonth, *endOfMonth, *drivenDate;
}
@end

@implementation ML54PrintMilesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    _userEmailTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _suggestedMileageLabel.text = @"$0.00";
    //****PICKERVIEW SETUP****//
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    _datePicker.delegate = self;
    _datePicker.dataSource = self;
    //Month Array of all months
    monthArray = [[NSMutableArray alloc]init];
    monthArray = [df monthSymbols];
    //Get Current Month
    [df setDateFormat:@"MMMM"];
    NSString *currentMonth = [NSString stringWithFormat:@"%@", [df stringFromDate:date]];
    NSUInteger currentMonthIndex = [monthArray indexOfObject:currentMonth];
    [_datePicker selectRow:currentMonthIndex inComponent:0 animated:YES];
    //Initialize our yearArray
    yearArray = [[NSMutableArray alloc]init];
    //Get Last Year
    [dateComponents setYear:-1];
    NSDate *lastYearDate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
    [df setDateFormat:@"yyyy"];
    NSString *lastYear = [NSString stringWithFormat:@"%@", [df stringFromDate:lastYearDate]];
    [yearArray addObject:lastYear];
    //Current Year
    [df setDateFormat:@"yyyy"];
    NSString *currentYear = [NSString stringWithFormat:@"%@", [df stringFromDate:date]];
    [yearArray addObject:currentYear];
    //Get Next Year
    [dateComponents setYear:+1];
    NSDate *nextYearDate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
    [df setDateFormat:@"yyyy"];
    NSString *nextYear = [NSString stringWithFormat:@"%@", [df stringFromDate:nextYearDate]];
    [yearArray addObject:nextYear];
    //Reload the components because we've added things to our arrays
    [_datePicker reloadAllComponents];
    //Set the picker component to the current year
    NSUInteger currentYearIndex = [yearArray indexOfObject:currentYear];
    [_datePicker selectRow:currentYearIndex inComponent:1 animated:YES];
    //****END PICKERVIEW DATA****//
    selectedMonth = [monthArray objectAtIndex:currentMonthIndex];
    selectedYear = [yearArray objectAtIndex:currentYearIndex];
    //get Rate & Set suggestedMileageRate
    dispatch_async(miles54Queue, ^{
        NSData *rateData = [NSData dataWithContentsOfURL:miles54MileageRateURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:rateData waitUntilDone:YES];
    });
    _emailMilesButton.layer.cornerRadius = 13;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 2;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_datePicker){
        if (component == 0){
            return [monthArray count];
        }
        if (component == 1){
            return [yearArray count];
        } else {
            return 0;
        }
    }
    return 0;
}

// Title for Row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_datePicker){
        if (component == 0){
            //Set label text
            return [monthArray objectAtIndex:row];
        }
        if (component == 1){
            return [yearArray objectAtIndex:row];
        } else {
            return 0;
        }
    }
    return 0;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_datePicker){
        if (component == 0){
            selectedMonth = [monthArray objectAtIndex:row];
        }
        if (component == 1){
            selectedYear = [yearArray objectAtIndex:row];
        }
    }
}

- (void)fetchedData:(NSData *)responseData {
    //Parse out JSON data
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSString *stringRate = [json valueForKey:@"currentRate"];
    NSInteger intRate = [stringRate integerValue];
    //Format appropriately and set the suggestedMileageLabel as dollars/cents
    NSNumberFormatter *currFormatter = [[NSNumberFormatter alloc]init];
    currFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    currFormatter.maximumFractionDigits = 3;
    currFormatter.currencySymbol = @"$";
    currFormatter.currencyDecimalSeparator = @".";
    double decimalRate = (intRate * .01);
    NSNumber *numRate = [NSNumber numberWithDouble:decimalRate];
    NSString *formedLabelRate = [currFormatter stringFromNumber:numRate];
    _suggestedMileageLabel.text = formedLabelRate;
    //Format as decimal to 3 places and set the text field automatically for user
    NSNumberFormatter *decFormatter = [[NSNumberFormatter alloc]init];
    decFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    decFormatter.maximumFractionDigits = 3;
    currFormatter.decimalSeparator = @".";
    NSString *formedDecRate = [decFormatter stringFromNumber:numRate];
    _mileageRateTextField.text = formedDecRate;
}




- (IBAction)emailMiles:(id)sender {
    [self exportToExcel];
    //Get the user entered email into an array
    NSArray *emailRecipients = [NSArray arrayWithObject:_userEmailTextField.text];
    NSString *fileName = [NSString stringWithFormat:@"54-Mileage-%@-%@.xls", selectedMonth, selectedYear];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc]init];
    mailController.mailComposeDelegate = self;
    [mailController setToRecipients:emailRecipients];
    [mailController setSubject:[NSString stringWithFormat:@"Monthly Mileage for %@ %@", selectedMonth, selectedYear]];
    [mailController setMessageBody:[NSString stringWithFormat:@"Attached is your monthly mileage for %@ %@", selectedMonth, selectedYear] isHTML:YES];
    [mailController addAttachmentData:[NSData dataWithContentsOfFile:appFile] mimeType:@"xls" fileName:fileName];
    if (mailController)[self presentViewController:mailController animated:YES completion:nil];
    
}

- (void)exportToExcel
{
    //Get the data we will need (fetch records from month/year user specified)
    NSPredicate *monthPredicates = [self predicateToRetrieveMonthTrips];
    _fetchedResultsController = [UserMiles MR_fetchAllSortedBy:@"driven_date" ascending:YES withPredicate:monthPredicates groupBy:nil delegate:self];
    NSError *error;
    [_fetchedResultsController performFetch:&error];
    allTableData = [_fetchedResultsController fetchedObjects];
    NSString *header = @"<?xml version=\"1.0\"?>\n<?mso-application progid=\"Excel.Sheet\"?>\n<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\"\nxmlns:o=\"urn:schemas-microsoft-com:office:office\"\nxmlns:x=\"urn:schemas-microsoft-com:office:excel\"\nxmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\"\nxmlns:html=\"http://www.w3.org/TR/REC-html40\">\n<Styles><Style ss:ID=\"s11\"><Alignment ss:Horizontal=\"Center\" ss:Vertical=\"Bottom\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style><Style ss:ID=\"s12\"><Alignment ss:Horizontal=\"Center\" ss:Vertical=\"Bottom\"/></Style><Style ss:ID=\"s13\"><Alignment ss:Horizontal=\"Center\" ss:Vertical=\"Bottom\"/><Font ss:Bold=\"1\"/></Style><Style ss:ID=\"s14\"><Alignment ss:Horizontal=\"Center\" ss:Vertical=\"Bottom\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders><Font ss:Bold=\"1\"/><Interior ss:Color=\"#C0C0C0\" ss:Pattern=\"Solid\"/></Style><Style ss:ID=\"s15\"><Alignment ss:Horizontal=\"Center\" ss:Vertical=\"Bottom\"/><Font ss:Bold=\"1\"/><NumberFormat ss:Format=\"&quot;$&quot;#,##0.00\"/></Style></Styles>\n<Worksheet ss:Name=\"54Mileage\">\n<Table ss:DefaultColumnWidth=\"117\">";
    NSString *columnAutoWidth30 = @"<Column ss:AutoFitWidth=\"1\" ss:Width=\"125\"/>\n";
    NSString *columnAutoWidth16 = @"<Column ss:AutoFitWidth=\"1\" ss:Width=\"95\"/>\n";
    //NSString *columncount = @"\" ss:ExpandedRowCount=\"";
    //NSString *rowcount = @"\" x:FullColumns=\"1\"x:FullRows=\"1\">\n";
    
    NSString *rowStart = @"<Row>\n";
    NSString *rowEnd = @"\n</Row>\n";
    
    NSString *stringStart = @"<Cell><Data ss:Type=\"String\">";
    NSString *stringEnd = @"</Data></Cell>";

    NSString *borderStringStart = @"<Cell ss:StyleID=\"s11\"><Data ss:Type=\"String\">";
    NSString *borderStringEnd = @"</Data></Cell>";
    
    NSString *borderNumberStart = @"<Cell ss:StyleID=\"s11\"><Data ss:Type=\"Number\">";
    NSString *borderNumberEnd = @"</Data></Cell>";
    
    NSString *centeredStringStart = @"<Cell ss:StyleID=\"s12\"><Data ss:Type=\"String\">";
    NSString *centeredStringEnd = @"</Data></Cell>";
    
    NSString *centeredBoldStringStart = @"<Cell ss:StyleID=\"s13\"><Data ss:Type=\"String\">";
    NSString *centeredBoldBGStringStart = @"<Cell ss:StyleID=\"s14\"><Data ss:Type=\"String\">";

    int numberOfRows = 0;
    
    for (UserMiles *trip in allTableData) {
        numberOfRows = numberOfRows + 1;
    }
    //Total Miles formula
    NSString *totalMilesFormulaStart = [NSString stringWithFormat:@"<Cell ss:StyleID=\"s13\" ss:Formula=\"=SUM(R[-%d]C[2]:R[-2]C[2])\"><Data ss:Type=\"Number\">",(numberOfRows+1)];
    NSString *totalMilesFormulaEnd = @"</Data></Cell>";
    //Total due formula
    NSString *dollarAmountFormulaStart = [NSString stringWithFormat:@"<Cell ss:StyleID=\"s15\" ss:Formula=\"=R[0]C[-2]*%@\"><Data ss:Type=\"Number\">",_mileageRateTextField.text];
    NSString *dollarAmountFormulaEnd = @"</Data></Cell>";
    
    //Needed to set the default pagebreak after the data
    NSString *worksheetOptions = @"\n<WorksheetOptions xmlnx=\"urn:schemas-microsoft-com:office:excel\">\n<Print>\n<ValidPrinterInfo/>\n<Scale>92</Scale>\n</Print></WorksheetOptions>\n";
    
    NSString *footer = [NSString stringWithFormat:@"</Table>\n%@\n</Worksheet>\n</Workbook>", worksheetOptions];
    
    NSString *xlsstring = @"";
    
    xlsstring = [NSString stringWithFormat:@"%@%@%@%@%@%@", header,columnAutoWidth30,columnAutoWidth16,columnAutoWidth16,columnAutoWidth16,columnAutoWidth16];
    
    //MAIN CONTENTS BEGINNING//
    //Person Making Claim line
    xlsstring = [xlsstring stringByAppendingFormat:@"%@ %@Person Making Claim:%@ %@%@%@ %@%@ %@Signature: %@ %@%@ %@", rowStart, stringStart, stringEnd, stringStart,[[NSUserDefaults standardUserDefaults] objectForKey:@"fullName"], stringEnd, stringStart, stringEnd, stringStart, stringEnd, stringStart, stringEnd, rowEnd ];
    //Blank Line
    xlsstring = [xlsstring stringByAppendingFormat:@"%@%@", rowStart, rowEnd];
    //Month/Year & Account Code Line
    NSString *line1Date = [NSString stringWithFormat:@"%@ %@", selectedMonth, selectedYear];
    xlsstring = [xlsstring stringByAppendingFormat:@"%@ %@Month/Year:%@ %@%@%@ %@%@ %@Account Code:%@ %@", rowStart,stringStart,stringEnd,stringStart,line1Date,stringEnd,stringStart,stringEnd,stringStart, stringEnd,rowEnd];
    //Blank Line
    xlsstring = [xlsstring stringByAppendingFormat:@"%@%@", rowStart, rowEnd];
    //School / Address Line
    xlsstring = [xlsstring stringByAppendingFormat:@"%@ %@School:%@ %@%@%@ %@%@ %@Home Address:%@ %@%@%@ %@", rowStart, stringStart, stringEnd, stringStart, [[NSUserDefaults standardUserDefaults] objectForKey:@"baseSchool"], stringEnd, stringStart, stringEnd, stringStart, stringEnd, stringStart, [[NSUserDefaults standardUserDefaults] objectForKey:@"homeAddress"],stringEnd, rowEnd];
    //Blank Line
    xlsstring = [xlsstring stringByAppendingFormat:@"%@%@", rowStart, rowEnd];
    //Header of Data
    xlsstring = [xlsstring stringByAppendingFormat:@"%@ %@Date%@ %@From%@ %@To%@ %@Number Of Miles%@ %@Reason For Trip%@ %@", rowStart, centeredBoldBGStringStart, stringEnd, centeredBoldBGStringStart, stringEnd,centeredBoldBGStringStart, stringEnd,centeredBoldBGStringStart, stringEnd,centeredBoldBGStringStart, stringEnd, rowEnd];
    //Iterate for each trip
    for (UserMiles *trip in allTableData) {
        //Format the Date
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setTimeZone:[NSTimeZone localTimeZone]];
        [df setDateFormat:@"MM/dd/YYYY"];
        NSString *tripDrivenDate = [df stringFromDate:trip.driven_date];
        //Append the data
        xlsstring = [xlsstring stringByAppendingFormat:@"%@ %@%@%@ %@%@%@ %@%@%@ %@%@%@ %@", rowStart, borderStringStart,tripDrivenDate ,borderStringEnd, borderStringStart, trip.beg_school, borderStringEnd, borderStringStart, trip.end_school, borderStringEnd, borderNumberStart, trip.miles, borderNumberEnd, rowEnd];
    }
    //MAIN CONTENTS ENDING//
    //Blank Line
    xlsstring = [xlsstring stringByAppendingFormat:@"%@%@", rowStart, rowEnd];
    //Formula Row
    NSString *formattedAmount = [NSString stringWithFormat:@"@%@", _mileageRateTextField.text];
    xlsstring = [xlsstring stringByAppendingFormat:@"%@ %@Total Miles:%@ %@%@ %@%@%@ %@%@ %@", rowStart, centeredBoldStringStart, stringEnd, totalMilesFormulaStart, totalMilesFormulaEnd, centeredBoldStringStart, formattedAmount, stringEnd, dollarAmountFormulaStart, dollarAmountFormulaEnd, rowEnd];
    //Blank Line
    xlsstring = [xlsstring stringByAppendingFormat:@"%@%@", rowStart, rowEnd];
    //Approved By line
    xlsstring = [xlsstring stringByAppendingFormat:@"%@ %@Approved By (signature):%@ %@%@ %@%@ %@Date:%@%@", rowStart, centeredStringStart, stringEnd, centeredStringStart, stringEnd, centeredStringStart, stringEnd, centeredStringStart, stringEnd, rowEnd ];

    //Footer
    xlsstring = [xlsstring stringByAppendingFormat:@"%@", footer];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFileName = [NSString stringWithFormat:@"54-Mileage-%@-%@.xls", selectedMonth, selectedYear];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:appFileName];
    [xlsstring writeToFile:appFile atomically:YES encoding:NSISOLatin1StringEncoding error:Nil];
    //NSLog(@"%@", documentsDirectory);
    
    
}

- (NSPredicate *)predicateToRetrieveMonthTrips {
    //Standard date format
    //YYYY-MM-dd HH:mm:ss
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    [df setDateFormat:@"MMMM"];
    NSDate *numMonth = [df dateFromString:selectedMonth];
    [df setDateFormat:@"MM"];
    NSString *properIntMonth = [NSString stringWithFormat:@"%@", [df stringFromDate:numMonth]];
    [df setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *begMonthDateString = [NSString stringWithFormat:@"%@-%@-01 00:00:00", selectedYear, properIntMonth];
    startOfMonth = [df dateFromString:begMonthDateString];
    [dateComponents setMonth:+1];
    NSDate *nextMonth = [calendar dateByAddingComponents:dateComponents toDate:startOfMonth options:0];
    NSString *endMonthDateString = [df stringFromDate:nextMonth];
    endOfMonth = [df dateFromString:endMonthDateString];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"driven_date >= %@ AND driven_date < %@ AND driven_date != null", startOfMonth, endOfMonth];
    return predicate;
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;
{
    if (result ==MFMailComposeResultSent){
        NSLog(@"Mail Sent!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}


@end
