//
//  ICPromoViewController.m
//  InstaCab
//
//  Created by Pavel Tisunov on 22/04/14.
//  Copyright (c) 2014 Bright Stripe. All rights reserved.
//

#import "ICPromoViewController.h"

@implementation ICTextField

-(CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 30, -10);
}

-(CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 30, -10);
}

@end

@interface ICPromoViewController ()

@end

@implementation ICPromoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleText = @"ПРОМО-ПРЕДЛОЖЕНИЕ";
    
    self.view.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    
    _borderView.layer.borderColor = [UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1].CGColor;
    _borderView.layer.borderWidth = 1.0;
    _borderView.layer.cornerRadius = 3.0;
    
    _promoCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    _promoCodeTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"promo_icon_grey.png"]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIFont *font = [UIFont systemFontOfSize:13];
    NSDictionary *attributes = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName:[UIColor colorWithRed:42/255.0 green:43/255.0 blue:42/255.0 alpha:1],
    };
    [backButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Применить" style:UIBarButtonItemStyleDone target:self action:@selector(applyPromo)];
    applyButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = applyButton;
    
    attributes = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName:[UIColor colorWithRed:46/255.0 green:167/255.0 blue:31/255.0 alpha:1]
    };
    [applyButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    attributes = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName:[UIColor lightGrayColor]
    };
    [applyButton setTitleTextAttributes:attributes forState:UIControlStateDisabled];

}

- (void)applyPromo {
    
}

- (void)back
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
