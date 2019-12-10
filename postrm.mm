/* AFC2 - the original definition of "jailbreak"
 * Copyright (C) 2014  Jay Freeman (saurik)
 * Copyright (C) 2018  Cannathea
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

#include <Foundation/Foundation.h>
#import "easy_spawn.h"

int main(int argc, const char *argv[]) {
    if (argc < 2 || (
        strcmp(argv[1], "abort-install") != 0 &&
        strcmp(argv[1], "remove") != 0 &&
    true)) return 0;

    NSAutoreleasePool *pool([[NSAutoreleasePool alloc] init]);

    NSString *path(@"/System/Library/Lockdown/Services.plist");
    NSMutableDictionary *services([NSMutableDictionary dictionaryWithContentsOfFile:path]);

    if (services != nil && [services objectForKey:@"com.apple.afc2"] != nil) {
        [services removeObjectForKey:@"com.apple.afc2"];
        [services writeToFile:path atomically:YES];
    }

    easy_spawn((const char *[]){(access("/sbin/launchctl", X_OK) != -1) ? "/sbin/launchctl" : "/bin/launchctl", "stop", "com.apple.mobile.lockdown", NULL});

    [pool release];
    return 0;
}
