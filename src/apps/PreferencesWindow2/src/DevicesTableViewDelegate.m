#import "DevicesTableViewDelegate.h"
#import "DevicesTableCellView.h"
#import "DevicesTableViewController.h"
#import "KarabinerKit/KarabinerKit.h"
#import "libkrbn/libkrbn.h"

@interface DevicesTableViewDelegate ()

@property(weak) IBOutlet DevicesTableViewController* devicesTableViewController;

@end

@implementation DevicesTableViewDelegate

- (NSView*)tableView:(NSTableView*)tableView viewForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)row {
  if ([tableColumn.identifier isEqualToString:@"DevicesExternalKeyboardColumn"]) {
    DevicesTableCellView* result = [tableView makeViewWithIdentifier:@"DevicesExternalKeyboardCellView" owner:self];
    KarabinerKitConnectedDevices* connectedDevices = [KarabinerKitDeviceManager sharedManager].connectedDevices;
    libkrbn_device_identifiers deviceIdentifiers = [connectedDevices deviceIdentifiersAtIndex:row];

    result.checkbox.title = [NSString stringWithFormat:@"%@ (%@) [%lld,%lld]",
                                                       [connectedDevices productAtIndex:row],
                                                       [connectedDevices manufacturerAtIndex:row],
                                                       deviceIdentifiers.vendor_id,
                                                       deviceIdentifiers.product_id];
    result.checkbox.state = NSControlStateValueOff;

    if ([connectedDevices isBuiltInKeyboardAtIndex:row] ||
        [connectedDevices isBuiltInTrackpadAtIndex:row] ||
        [connectedDevices isBuiltInTouchBarAtIndex:row]) {
      result.checkbox.enabled = NO;
    } else {
      result.checkbox.enabled = YES;
      result.checkbox.action = @selector(valueChanged:);
      result.checkbox.target = self.devicesTableViewController;

      result.deviceIdentifiers = [connectedDevices deviceIdentifiersAtIndex:row];

      KarabinerKitCoreConfigurationModel* coreConfigurationModel = [KarabinerKitConfigurationManager sharedManager].coreConfigurationModel;
      if ([coreConfigurationModel selectedProfileDeviceDisableBuiltInKeyboardIfExists:(&deviceIdentifiers)]) {
        result.checkbox.state = NSControlStateValueOn;
      } else {
        result.checkbox.state = NSControlStateValueOff;
      }
    }

    // ----------------------------------------
    result.keyboardImage.hidden = !(deviceIdentifiers.is_keyboard);
    result.mouseImage.hidden = !(deviceIdentifiers.is_pointing_device);

    // ----------------------------------------
    return result;
  }

  return nil;
}

@end