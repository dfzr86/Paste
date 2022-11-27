//
//  HotKey.m
//  Paste
//
//  Created by hanxu on 2022/11/24.
//

#import "HotKey.h"
#import <Carbon/Carbon.h>
#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>


@implementation HotKey

+ (void)addGlobalHotKey:(UInt32)keyCode {
    [self addGlobalHotKey:keyCode onlyCmd:NO];
}

+ (void)injectPaste {
    CGEventRef cmd_down = CGEventCreateKeyboardEvent(NULL, kVK_Command, true);
     CGEventPost(kCGHIDEventTap, cmd_down);
     CGEventRef v_down = CGEventCreateKeyboardEvent(NULL, kVK_ANSI_V, true);
     CGEventPost(kCGHIDEventTap, v_down);
     CGEventRef v_up = CGEventCreateKeyboardEvent(NULL, kVK_ANSI_V, false);
     CGEventPost(kCGHIDEventTap, v_up);
     CGEventRef cmd_up = CGEventCreateKeyboardEvent(NULL, kVK_Command, false);
     CGEventPost(kCGHIDEventTap, cmd_up);

     CFRelease(cmd_down);
     CFRelease(v_down);
     CFRelease(v_up);
     CFRelease(cmd_up);
    
    
    //    CGEventRef ref = CGEventCreateKeyboardEvent(NULL, cmdKey + kVK_ANSI_V, false);
    
//    CGEventRef event1, event2, event3, event4;
//    event1 = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)cmdKey, true);
//    event2 = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)kVK_ANSI_V, true);
//    event3 = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)cmdKey, false);
//    event4 = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)kVK_ANSI_V, false);
    
//    CGEventPost(kCGHIDEventTap, event1);
//    CGEventPost(kCGHIDEventTap, event2);
//    CGEventPost(kCGHIDEventTap, event3);
//    CGEventPost(kCGHIDEventTap, event4);
    
    
    //
    //    CGEventRef cmd_down = CGEventCreateKeyboardEvent(NULL, kVK_Command, true);
    //     CGEventPost(kCGHIDEventTap, cmd_down);
    //     CGEventRef v_down = CGEventCreateKeyboardEvent(NULL, kVK_ANSI_V, true);
    //     CGEventPost(kCGHIDEventTap, v_down);
    //     CGEventRef v_up = CGEventCreateKeyboardEvent(NULL, kVK_ANSI_V, false);
    //     CGEventPost(kCGHIDEventTap, v_up);
    //     CGEventRef cmd_up = CGEventCreateKeyboardEvent(NULL, kVK_Command, false);
    //     CGEventPost(kCGHIDEventTap, cmd_up);
    //
    //     CFRelease(cmd_down);
    //     CFRelease(v_down);
    //     CFRelease(v_up);
    //     CFRelease(cmd_up);
    
}

+ (void)addGlobalHotKey:(UInt32)keyCode onlyCmd:(BOOL)onlyCmd {
    EventHotKeyRef       gMyHotKeyRef;
    EventHotKeyID        gMyHotKeyID;
    EventTypeSpec        eventType;
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    InstallApplicationEventHandler(&GlobalHotKeyHandler, 1, &eventType, NULL, NULL);
    gMyHotKeyID.signature = 'asdj';
    gMyHotKeyID.id = keyCode;
    
    RegisterEventHotKey(keyCode,
                        onlyCmd ? cmdKey : cmdKey + shiftKey,
                        gMyHotKeyID,
                        GetApplicationEventTarget(),
                        0,
                        &gMyHotKeyRef);
}

OSStatus GlobalHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,void *userData) {
    EventHotKeyID hkCom;
    GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,
                      sizeof(hkCom),NULL,&hkCom);
    int l = hkCom.id;
    switch (l) {
        case kVK_ANSI_S: {
            NSLog(@"kVK_ANSI_S按下");
        }
            break;
        case kVK_ANSI_X: {
            NSLog(@"kVK_ANSI_X按下");
        }
            break;
        case kVK_ANSI_V: {
            NSLog(@"kVK_ANSI_V按下");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cmd_shift_v_clicked" object:nil];
        }
            break;
        case kVK_ANSI_D: {
            NSLog(@"kVK_ANSI_D按下");
        }
            break;
        case kVK_ANSI_Z: {
            NSLog(@"kVK_ANSI_Z按下");
        }
        case kVK_ANSI_C: {
            NSLog(@"kVK_ANSI_C按下");
        }
            break;
    }
    return noErr;
}


@end
