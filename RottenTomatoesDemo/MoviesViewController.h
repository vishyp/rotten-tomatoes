//
//  MoviesViewController.h
//  RottenTomatoesDemo
//
//  Created by Vishy Poosala on 10/13/14.
//  Copyright (c) 2014 Vi Po. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
- (void) setSource: (NSString *) src;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end
