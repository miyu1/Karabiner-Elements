#import "DevicesTableViewController.h"
#import "DevicesTableCellView.h"
#import "FnFunctionKeysTableViewController.h"
#import "KarabinerKit/KarabinerKit.h"
#import "NotificationKeys.h"
#import "SimpleModificationsTableViewController.h"
#import <pqrs/weakify.h>

@interface DevicesTableViewController ()

@property(weak) IBOutlet NSTableView* tableView;
@property(weak) IBOutlet NSTableView* externalKeyboardTableView;
@property(weak) IBOutlet SimpleModificationsTableViewController* simpleModificationsTableViewController;
@property(weak) IBOutlet FnFunctionKeysTableViewController* fnFunctionKeysTableViewController;
@property(weak) IBOutlet NSPanel* hasCapsLockLedConfirmationPanel;
@property(weak) IBOutlet NSWindow* window;
@property KarabinerKitSmartObserverContainer* observers;

@end

@implementation DevicesTableViewController

- (void)setup {
  self.observers = [KarabinerKitSmartObserverContainer new];
  @weakify(self);

  {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    id o = [center addObserverForName:kKarabinerKitConfigurationIsLoaded
                               object:nil
                                queue:[NSOperationQueue mainQueue]
                           usingBlock:^(NSNotification* note) {
                             @strongify(self);
                             if (!self) {
                               return;
                             }

                             [self.tableView reloadData];
                             [self.externalKeyboardTableView reloadData];
                           }];
    [self.observers addObserver:o notificationCenter:center];
  }

  {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    id o = [center addObserverForName:kKarabinerKitDevicesAreUpdated
                               object:nil
                                queue:[NSOperationQueue mainQueue]
                           usingBlock:^(NSNotification* note) {
                             @strongify(self);
                             if (!self) {
                               return;
                             }

                             [self.tableView reloadData];
                             [self.externalKeyboardTableView reloadData];
                           }];
    [self.observers addObserver:o notificationCenter:center];
  }
}

- (void)valueChanged:(id)sender {
  KarabinerKitCoreConfigurationModel* coreConfigurationModel = [KarabinerKitConfigurationManager sharedManager].coreConfigurationModel;

  NSInteger row = [self.tableView rowForView:sender];
  if (row != -1) {
    DevicesTableCellView* cellView = [self.tableView viewAtColumn:0 row:row makeIfNecessary:NO];
    libkrbn_device_identifiers deviceIdentifiers = cellView.deviceIdentifiers;
    [coreConfigurationModel setSelectedProfileDeviceIgnore:&(deviceIdentifiers)
                                                     value:(cellView.checkbox.state == NSControlStateValueOff)];
    [coreConfigurationModel save];
    goto finish;
  }

  row = [self.externalKeyboardTableView rowForView:sender];
  if (row != -1) {
    DevicesTableCellView* cellView = [self.externalKeyboardTableView viewAtColumn:0 row:row makeIfNecessary:NO];
    libkrbn_device_identifiers deviceIdentifiers = cellView.deviceIdentifiers;
    [coreConfigurationModel setSelectedProfileDeviceDisableBuiltInKeyboardIfExists:&(deviceIdentifiers)
                                                                             value:(cellView.checkbox.state == NSControlStateValueOn)];
    [coreConfigurationModel save];
    goto finish;
  }

finish:
  [self.simpleModificationsTableViewController updateConnectedDevicesMenu];
  [self.fnFunctionKeysTableViewController updateConnectedDevicesMenu];
}

@end