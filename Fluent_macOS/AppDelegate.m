//
//  AppDelegate.m
//  Fluent_macOS
//
//  Created by Jinwoo Kim on 6/10/23.
//

#import "AppDelegate.h"
#import "WallpapersViewController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    WallpapersViewController *contentViewController = [WallpapersViewController new];
    NSWindow *window = [NSWindow new];
    window.styleMask = NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullSizeContentView | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled;
    window.movableByWindowBackground = YES;
    window.title = NSProcessInfo.processInfo.processName;
    window.releasedWhenClosed = NO;
    window.titlebarAppearsTransparent = YES;
    window.titleVisibility = NSWindowTitleHidden;
    window.minSize = window.contentMinSize;
    window.contentViewController = contentViewController;
    [contentViewController release];
    [window makeKeyAndOrderFront:nil];
    [window release];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

@end
