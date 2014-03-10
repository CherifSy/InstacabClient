//
//  TripEndViewController.m
//  Hopper
//
//  Created by Pavel Tisunov on 05/11/13.
//  Copyright (c) 2013 Bright Stripe. All rights reserved.
//

#import "ICReceiptViewController.h"
#import "ICClient.h"
#import "ICClientService.h"
#import "UIColor+Colours.h"
#import "ICFeedbackViewController.h"

@interface ICReceiptViewController ()
@end

@implementation ICReceiptViewController {
    NSLocale *_ruLocale;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Use Russian localte, because I use English locale on my dev machine
        _ruLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleText = @"КВИТАНЦИЯ";
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    
    _billingActivityView.color = [UIColor grayColor];
    
    _fareSection.backgroundColor = [UIColor colorFromHexString:@"#f4f7f7"];
    _ratingSection.backgroundColor = [UIColor colorFromHexString:@"#e2e2e1"];

    [self setupStarRating];
    
    ICTrip *trip = [ICClient sharedInstance].tripPendingRating;
    
    // Display timestamp
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd MMMM yyyy, HH:mm";
    dateFormatter.locale = _ruLocale;
    
    // We've got it in milliseconds
    NSTimeInterval epochTime = [trip.dropoffAt doubleValue];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:epochTime];
    
    _timestampLabel.text = [[dateFormatter stringFromDate:date] uppercaseString];
//    _timestampLabel.text = @"16 ФЕВРАЛЯ 2014, 14:07";
    
    double fare = [trip.fareBilledToCard doubleValue];
//    _fareLabel.text = @"270 р.";
    
    // Show progress while fare being billed to card
    if (fare == 0) {
        [[ICClient sharedInstance] addObserver:self forKeyPath:@"tripPendingRating" options:NSKeyValueObservingOptionNew context:nil];
        
        CATransition *transition = [CATransition animation];
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        transition.duration = 0.35;
        transition.fillMode = kCAFillModeBoth;
        
        _fareLabel.text = @"";
        [_fareLabel.layer addAnimation:transition forKey:@"kCATransitionFade"];
        
        _billingStatusLabel.text = [@"Оплачиваю..." uppercaseString];
        
        _starRating.enabled = NO;
        [_billingActivityView startAnimating];
    }
    else {
        [self showFare:fare];
    }
}

- (void)showFare:(double)fare {
    // Display fare with comma as decimal separator
    // LATER: This should be handled by server backend => Trip.fareString
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.locale = _ruLocale;
    
    _fareLabel.text = [NSString stringWithFormat:@"%@ р.", [formatter stringFromNumber:[NSNumber numberWithDouble:fare]]];
    
    _billingStatusLabel.text = [@"Оплачено Картой" uppercaseString];
    _starRating.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[ICClientService sharedInstance] trackScreenView:@"Receipt"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    ICTrip *trip = (ICTrip *)change[NSKeyValueChangeNewKey];
    double fare = [trip.fareBilledToCard doubleValue];
    
    if (fare > 0) {
        [_billingActivityView stopAnimating];
        _fareLabel.hidden = NO;
        
        [self showFare:fare];
        
        [[ICClient sharedInstance] removeObserver:self forKeyPath:@"tripPendingRating"];
    }
}

-(void)setupStarRating {
    _starRating.starImage = [UIImage imageNamed:@"rating_star_empty.png"];
    _starRating.starHighlightedImage = [UIImage imageNamed:@"rating_star_full.png"];
    _starRating.maxRating = 5.0;
    _starRating.delegate = self;
    _starRating.horizontalMargin = 12;
    _starRating.editable = YES;
    _starRating.displayMode = EDStarRatingDisplayFull;
    [_starRating setNeedsDisplay];
}

-(void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating
{
    ICFeedbackViewController *vc = [[ICFeedbackViewController alloc] initWithNibName:@"ICFeedbackViewController" bundle:nil];
    vc.driverRating = rating;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
