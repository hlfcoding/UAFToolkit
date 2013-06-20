//
//  UAFViewController.m
//  UAFToolkit
//
//  Created by Peng Wang on 6/20/13.
//  Copyright (c) 2013 UseAllFive. All rights reserved.
//

#import "UAFViewController.h"

@implementation UAFViewController

@synthesize previousNavigationItemIdentifier, nextNavigationItemIdentifier, customNavigationController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self _commonInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self _commonInit];
  }
  return self;
}

- (id)init
{
  self = [super init];
  if (self) {
    [self _commonInit];
  }
  return self;
}

#pragma mark - UAFObject

- (void)_commonInit {}

@end