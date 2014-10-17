//
//  MoviesViewController.m
//  RottenTomatoesDemo
//
//  Created by Vishy Poosala on 10/13/14.
//  Copyright (c) 2014 Vi Po. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailedViewController.h"
#import "SVProgressHUD.h"
#import "AFNetworkReachabilityManager.h"
#import "MovieCollectionViewCell.h"


@interface MoviesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *moviesTableView; 
@property (weak, nonatomic) IBOutlet UICollectionView *moviesCollectionView;
@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSMutableArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UIView *errorBar;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic) BOOL loadedMovie;
@property (strong, nonatomic) NSString *src;
@property (nonatomic) BOOL isFiltered;


@end

@implementation MoviesViewController

- (void) setSource:(NSString *)src {
    self.src = src;
    self.tabBarItem.title = @"Hello!";
}
- (IBAction)segmentControlChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    if (selectedSegment == 0) {
        [self.moviesTableView setHidden:NO];
        [self.moviesCollectionView setHidden:YES];
        [self.segmentControl setHidden:NO];
    } else {
        [self.moviesTableView setHidden:YES];
        [self.moviesCollectionView setHidden:NO];
        [self.segmentControl setHidden:NO];

    }
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (void) viewWillAppear:(BOOL)animated {
    [[self.tabBarController.tabBar.items objectAtIndex:0] setTitle:@"Box Office"];
    [[self.tabBarController.tabBar.items objectAtIndex:0] setImage:[UIImage imageNamed:@"movie32.png"]];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setTitle:@"DVD"];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setImage:[UIImage imageNamed:@"dvd32.png"]];
    if ([self.src isEqualToString:@"boxoffice"]) {
            self.title = @"Movies";
    } else {
        self.title = @"Top Rentals";
    }
}

- (void) getMovies {
    
    if (! [AFNetworkReachabilityManager sharedManager].reachable) return;
    
    
    NSURL *url;
    if ([self.src isEqualToString:@"boxoffice"]) {
       url =  [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=ak5hmp7ctwk9a6anywauwg4s"];
    } else {
        url =  [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/current_releases.json?apikey=ak5hmp7ctwk9a6anywauwg4s"];
    }
    

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [SVProgressHUD show];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [SVProgressHUD dismiss];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.movies = responseDictionary[@"movies"];
        
        [self.moviesTableView reloadData];
        [self.refreshControl endRefreshing];
        [self.moviesCollectionView reloadData];
        
    }];
}
- (void)viewDidLoad {

    self.loadedMovie = false;
    [super viewDidLoad];
    [self.errorBar setHidden:YES];
    self.errorLabel.text = @"Network Error";
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    // Do any additional setup after loading the view from its nib.
    self.moviesTableView.delegate = self;
    self.moviesTableView.dataSource = self;
    self.searchBar.delegate = self;
    self.moviesTableView.rowHeight = 100;
    self.moviesCollectionView.delegate = self;
    self.moviesCollectionView.dataSource = self;
    
    
    [self.moviesTableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];

    
    [self.moviesCollectionView registerNib:[UINib nibWithNibName:@"MovieCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MovieCollectionViewCell"];
  
    [self.moviesCollectionView setHidden:YES];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.moviesTableView insertSubview:self.refreshControl atIndex:0];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"connection status changed");
        if (! [AFNetworkReachabilityManager sharedManager].reachable) {
            [self.errorBar setHidden:NO];
        } else {
            [self.errorBar setHidden:YES];
            if (! self.loadedMovie) {
                self.loadedMovie = true;
                [self getMovies];
            }

        }
    }];
}

- (void)onRefresh {
    [self getMovies];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isFiltered) return self.filteredMovies.count;
    else return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    NSDictionary *movie;
    
    if (self.isFiltered) movie = self.filteredMovies[indexPath.row];
    else movie = self.movies[indexPath.row];

    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"synopsis"];
    NSString *posterUrl = [movie valueForKeyPath:@"posters.thumbnail"];
    [cell.posterView setImageWithURL:[NSURL URLWithString:posterUrl]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MovieDetailedViewController *mdvc = [[MovieDetailedViewController alloc]init];
    if (self.isFiltered) mdvc.movie = self.filteredMovies[indexPath.row];
    else mdvc.movie = self.movies[indexPath.row];

    
    [self.navigationController pushViewController:mdvc animated:YES];
    
}

- (void)searchTableList {
    NSString *searchString = self.searchBar.text;
 
    for (NSDictionary* movie in self.movies)
    {

        NSRange nameRange = [movie[@"title"] rangeOfString:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
        if(nameRange.location != NSNotFound)
        {
            [self.filteredMovies addObject:movie];
        }
    }
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isFiltered = YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if(searchText.length == 0)
    {
        self.isFiltered = FALSE;
    }
    else
    {
        self.isFiltered = TRUE;
        
        
        if (self.filteredMovies == nil)
            self.filteredMovies = [[NSMutableArray alloc] init];
        else
            [self.filteredMovies removeAllObjects];
        
        
    }
    [self.moviesTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self searchTableList];
    [self.moviesTableView reloadData];
    [self.moviesCollectionView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    /*[self searchTableList];
    [self.moviesTableView reloadData];*/
}

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (self.isFiltered) return self.filteredMovies.count;
    else return self.movies.count;
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MovieCollectionViewCell" forIndexPath:indexPath];
    NSDictionary *movie;
    if (self.isFiltered) movie = self.filteredMovies[indexPath.row];
    else movie = self.movies[indexPath.row];
    
    NSString *posterUrl = [movie valueForKeyPath:@"posters.thumbnail"];
    cell.backgroundColor = [UIColor whiteColor];
    
    [cell.thumbNailImage setImageWithURL:[NSURL URLWithString:posterUrl]];
    
    return cell;
}

// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    MovieDetailedViewController *mdvc = [[MovieDetailedViewController alloc]init];
    if (self.isFiltered) mdvc.movie = self.filteredMovies[indexPath.row];
    else mdvc.movie = self.movies[indexPath.row];
    
    
    [self.navigationController pushViewController:mdvc animated:YES];

    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSString *searchTerm = self.searches[indexPath.section]; FlickrPhoto *photo =
    //self.searchResults[searchTerm][indexPath.row];
    // 2
    CGSize retval = CGSizeMake(120, 120);
    // retval.height += 35;
    //retval.width += 35;
    return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
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
