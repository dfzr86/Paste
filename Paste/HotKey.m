//
//  HotKey.m
//  Paste
//
//  Created by hanxu on 2022/11/24.
//

#import "HotKey.h"
#import <Carbon/Carbon.h>

@implementation HotKey

+ (void)addGlobalHotKey:(UInt32)keyCode {
    [self addGlobalHotKey:keyCode onlyCmd:NO];
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
