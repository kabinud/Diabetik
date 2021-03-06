//
//  UASettingsiCloudViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 12/12/2013.
//  Copyright 2013 Nial Giacomelli
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "UASettingsiCloudViewController.h"

@interface UASettingsiCloudViewController ()
{
    UIAlertView *redownloadAlertView;
    UIAlertView *deleteAlertView;
}

// Logic
- (void)toggleiCloudSync:(UISwitch *)sender;
- (void)userDefaultsDidChange:(NSNotification *)note;

@end

@implementation UASettingsiCloudViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.title = NSLocalizedString(@"iCloud", nil);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDefaultsDidChange:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateView];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Logic
- (void)updateView
{
    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width-40.0f, 0.0f)];
    warningLabel.numberOfLines = 0;
    warningLabel.textAlignment = NSTextAlignmentCenter;
    warningLabel.backgroundColor = [UIColor clearColor];
    warningLabel.font = [UAFont standardRegularFontWithSize:14.0f];
    warningLabel.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    if([[NSUserDefaults standardUserDefaults] boolForKey:USMCloudEnabledKey])
    {
        warningLabel.text = NSLocalizedString(@"Use the above options with caution!", nil);
    }
    else
    {
        warningLabel.text = NSLocalizedString(@"If you cannot enable syncing make sure you've allowed Diabetik access to iCloud in the Settings app", nil);
    }
    [warningLabel sizeToFit];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, warningLabel.frame.size.height)];
    warningLabel.frame = CGRectMake(floorf(self.view.frame.size.width/2.0f - warningLabel.frame.size.width/2), 0.0f, warningLabel.frame.size.width, warningLabel.frame.size.height);
    [footerView addSubview:warningLabel];
    
    self.tableView.tableFooterView = footerView;
    [self.tableView reloadData];
}
- (void)toggleiCloudSync:(UISwitch *)sender
{
    [[UACoreDataController sharedInstance] toggleiCloudSync];
}
- (void)userDefaultsDidChange:(NSNotification *)note
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateView];
    });
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return [[[UACoreDataController sharedInstance] ubiquityStoreManager] cloudEnabled] ? 2 : 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return 1;
    if(section == 1) return 2;
    
    return 0;
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return NSLocalizedString(@"iCloud", nil);
    }
    else if(section == 1)
    {
        return NSLocalizedString(@"Options", nil);
    }
    
    return @"";
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}
- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    UAGenericTableHeaderView *header = [[UAGenericTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, aTableView.frame.size.width, 40.0f)];
    [header setText:[self tableView:aTableView titleForHeaderInSection:section]];
    return header;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UAGenericTableViewCell *cell = (UAGenericTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UASettingCell"];
    if (cell == nil)
    {
        cell = [[UAGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UASettingCell"];
    }
    [cell setCellStyleWithIndexPath:indexPath andTotalRows:[aTableView numberOfRowsInSection:indexPath.section]];
    
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        cell.textLabel.text = NSLocalizedString(@"iCloud sync", nil);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.detailTextLabel.text = nil;
        
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        [switchControl addTarget:self action:@selector(toggleiCloudSync:) forControlEvents:UIControlEventTouchUpInside];
        [switchControl setOn:[[[UACoreDataController sharedInstance] ubiquityStoreManager] cloudEnabled]];
        [switchControl setEnabled:[[[UACoreDataController sharedInstance] ubiquityStoreManager] cloudAvailable]];
        cell.accessoryView = switchControl;
    }
    else if(indexPath.section == 1 && indexPath.row == 0)
    {
        cell.textLabel.text = NSLocalizedString(@"Redownload iCloud data", nil);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.detailTextLabel.text = nil;
    }
    else if(indexPath.section == 1 && indexPath.row == 1)
    {
        cell.textLabel.text = NSLocalizedString(@"Delete Diabetik iCloud data", nil);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.detailTextLabel.text = nil;
    }
    
    return cell;
}

#pragma mar - UITableViewDelegate methods
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            [[[UACoreDataController sharedInstance] ubiquityStoreManager] reloadStore];
            /*
            redownloadAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Redownload iCloud data", nil)
                                                             message:NSLocalizedString(@"Are you sure you'd like to redownload data from iCloud?", nil)
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                   otherButtonTitles:NSLocalizedString(@"Redownload", nil), nil];
            [redownloadAlertView show];
            */
        }
        else
        {
            deleteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete iCloud data", nil)
                                                         message:NSLocalizedString(@"Are you sure you'd like to delete all Diabetik iCloud data? This action is irreversible!", nil)
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               otherButtonTitles:NSLocalizedString(@"Delete", nil), nil];
            [deleteAlertView show];
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == redownloadAlertView)
    {
        if(buttonIndex == [alertView firstOtherButtonIndex])
        {
            [[[UACoreDataController sharedInstance] ubiquityStoreManager] deleteCloudStoreLocalOnly:YES];
        }
    }
    else if(alertView == deleteAlertView)
    {
        if(buttonIndex == [alertView firstOtherButtonIndex])
        {
            [[[UACoreDataController sharedInstance] ubiquityStoreManager] deleteCloudContainerLocalOnly:NO];
        }
    }
}

@end
