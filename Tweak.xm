/* AFC2 - the original definition of "jailbreak"
 * Copyright (C) 2014  Jay Freeman (saurik)
 * Copyright (C) 2018 - 2023  Cannathea
 */

/* GNU General Public License, Version 3 {{{ */
/*
 * Cydia is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * Cydia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Cydia.  If not, see <http://www.gnu.org/licenses/>.
 **/
/* }}} */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "easy_spawn.h"
#import "rootless.h"

#define LDID @"/usr/bin/ldid"
#define FLAG_PATH @"/usr/libexec/afc2dSupport" // Set afc2d to download only once

%group SpringBoardHook
%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
    %orig;

    if (![[NSFileManager defaultManager] fileExistsAtPath:ROOT_PATH_NS(LDID)]) {
        // Alert of confirmation because ldid cannot be put in depends in control file for XinaA15.
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"ldid is required"
                                            message:@"Please Respring after installation."
                                     preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];

        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    } else {
        easy_spawn((const char *[]){ROOT_PATH_C("/usr/bin/afc2dSupport"), NULL});
    }
}
%end
%end

%ctor {
    // Set afc2d to download only once
    if ([[NSFileManager defaultManager] fileExistsAtPath:ROOT_PATH_NS(FLAG_PATH)]) {
        %init(SpringBoardHook);
    }
}
