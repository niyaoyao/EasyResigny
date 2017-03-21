//
//  ERDragTextField.m
//  EasyResigny
//
//  Created by NiYao on 20/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
//

#import "ERDragTextField.h"

@implementation ERDragTextField

- (void)awakeFromNib {
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *board = [sender draggingPasteboard];
    NSArray *files = [board propertyListForType:NSFilenamesPboardType];
    if (files.count <= 0) {
        return NO;
    }
    self.stringValue = [files firstObject];
    return YES;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    if (!self.isEnabled) {
        return NSDragOperationNone;
    }
    
    NSPasteboard *board = [sender draggingPasteboard];
    NSDragOperation dragOperationMask = [sender draggingSourceOperationMask];
    
    if ([[board types] containsObject:NSColorPboardType]) {
        if (dragOperationMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    
    if ([[board types] containsObject:NSFilenamesPboardType]) {
        if (dragOperationMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }

    return NSDragOperationNone;
}

@end
