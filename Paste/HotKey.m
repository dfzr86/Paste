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

+ (void)sendQKeyEventToTextEdit {
    
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
//    CGEventRef cmd_down = CGEventCreateKeyboardEvent(source, kVK_Command, true);
//    CGEventRef cmd_up = CGEventCreateKeyboardEvent(source, kVK_Command, false);
//
    CGEventRef v_down = CGEventCreateKeyboardEvent(source, kVK_ANSI_V, true);
//    CGEventRef v_up = CGEventCreateKeyboardEvent(source, kVK_ANSI_V, false);
//
//    CGEventRef ret = CGEventCreateKeyboardEvent(source, kVK_Return, true);
//
//    CGEventTapLocation location = kCGHIDEventTap;

    CGEventRef event1, event2, event3, event4;
    event1 = CGEventCreateKeyboardEvent (source, (CGKeyCode)56, true);
    event2 = CGEventCreateKeyboardEvent (source, (CGKeyCode)6, true);
//    event3 = CGEventCreateKeyboardEvent (source, (CGKeyCode)6, false);
//    event4 = CGEventCreateKeyboardEvent (source, (CGKeyCode)56, false);
    
//    CGEventPost(0, event1);
    CGEventPost(0, v_down);
//    CGEventPost(0, event2);
//    CGEventPost(0, event3);
//    CGEventPost(0, event4);
//
//    //发送事件
//    CGEventPost(location,z v_down);z
//    
//    CGEventPost(location, v_up);
//    CGEventPost(location, cmd_up);
//    
//    CFRelease(cmd_down);
//    CFRelease(v_down);
//    CFRelease(v_up);
//    CFRelease(cmd_up);
//    CFRelease(source);
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
