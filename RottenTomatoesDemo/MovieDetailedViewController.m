//
//  MovieDetailedViewController.m
//  RottenTomatoesDemo
//
//  Created by Vishy Poosala on 10/13/14.
//  Copyright (c) 2014 Vi Po. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "MovieDetailedViewController.h"


@interface MovieDetailedViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation MovieDetailedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"synopsis"];
    //self.synopsisLabel.frame = CGRectMake(12, 316, 219, 244);
    [self.synopsisLabel setNumberOfLines:0];
    [self.synopsisLabel sizeToFit];

    self.scrollView.contentSize = CGSizeMake(320, 1000);
    NSString *posterUrl = [[self.movie valueForKeyPath:@"posters.thumbnail"] stringByReplacingOccurrencesOfString:@"tmb.jpg" withString:@"ori.jpg"];
    [self.posterImage setImageWithURL:[NSURL URLWithString:posterUrl]];
    self.titleLabel.text = self.movie[@"title"];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
