#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>

static NSString *safeBundleName(NSString *bundle) {
  NSMutableString *out = [NSMutableString stringWithCapacity:bundle.length];
  NSCharacterSet *allowed = [NSCharacterSet alphanumericCharacterSet];

  for (NSUInteger i = 0; i < bundle.length; i++) {
    unichar ch = [bundle characterAtIndex:i];
    unichar safe = [allowed characterIsMember:ch] ? ch : (unichar)'_';
    [out appendFormat:@"%C", safe];
  }

  return out;
}

static NSString *tmpDir(void) {
  NSString *tmp = [[[NSProcessInfo processInfo] environment] objectForKey:@"TMPDIR"];
  if (!tmp || tmp.length == 0) tmp = @"/tmp";
  return tmp;
}

static NSString *statePath(NSString *bundle) {
  return [tmpDir() stringByAppendingPathComponent:
    [NSString stringWithFormat:@"toggle-overlay-app.%@.frames", safeBundleName(bundle)]];
}

static NSString *logPath(void) {
  return [tmpDir() stringByAppendingPathComponent:@"toggle-overlay-app.log"];
}

static void logEvent(NSString *bundle, NSString *message) {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
  formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS ZZZZZ";

  NSString *line = [NSString stringWithFormat:@"%@ bundle=%@ %@\n",
    [formatter stringFromDate:[NSDate date]],
    bundle ?: @"",
    message ?: @""];

  NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:logPath()];

  if (!handle) {
    [line writeToFile:logPath()
           atomically:YES
             encoding:NSUTF8StringEncoding
                error:nil];
    return;
  }

  [handle seekToEndOfFile];
  [handle writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
  [handle closeFile];
}

static BOOL getWindowFrame(AXUIElementRef window, CGPoint *origin, CGSize *size) {
  CFTypeRef posValue = NULL;
  CFTypeRef sizeValue = NULL;

  AXError posErr = AXUIElementCopyAttributeValue(window, kAXPositionAttribute, &posValue);
  AXError sizeErr = AXUIElementCopyAttributeValue(window, kAXSizeAttribute, &sizeValue);

  if (posErr != kAXErrorSuccess || sizeErr != kAXErrorSuccess || !posValue || !sizeValue) {
    if (posValue) CFRelease(posValue);
    if (sizeValue) CFRelease(sizeValue);
    return NO;
  }

  BOOL ok = AXValueGetValue((AXValueRef)posValue, kAXValueCGPointType, origin)
    && AXValueGetValue((AXValueRef)sizeValue, kAXValueCGSizeType, size);

  CFRelease(posValue);
  CFRelease(sizeValue);

  return ok;
}

static void setWindowOrigin(AXUIElementRef window, CGPoint origin) {
  AXValueRef value = AXValueCreate(kAXValueCGPointType, &origin);

  if (value) {
    AXUIElementSetAttributeValue(window, kAXPositionAttribute, value);
    CFRelease(value);
  }
}

static void setWindowSize(AXUIElementRef window, CGSize size) {
  AXValueRef value = AXValueCreate(kAXValueCGSizeType, &size);

  if (value) {
    AXUIElementSetAttributeValue(window, kAXSizeAttribute, value);
    CFRelease(value);
  }
}

static CGRect displayBoundsForPoint(CGPoint point) {
  uint32_t count = 0;
  CGGetActiveDisplayList(0, NULL, &count);

  if (count > 0) {
    CGDirectDisplayID displays[count];
    CGGetActiveDisplayList(count, displays, &count);

    for (uint32_t i = 0; i < count; i++) {
      CGRect bounds = CGDisplayBounds(displays[i]);
      if (CGRectContainsPoint(bounds, point)) return bounds;
    }
  }

  return CGDisplayBounds(CGMainDisplayID());
}

static NSArray *copyWindowsForApp(NSRunningApplication *app) {
  AXUIElementRef appElement = AXUIElementCreateApplication(app.processIdentifier);
  if (!appElement) return @[];

  CFTypeRef value = NULL;
  AXError err = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute, &value);

  CFRelease(appElement);

  if (err != kAXErrorSuccess || !value) return @[];

  return CFBridgingRelease(value);
}

static NSArray<NSRunningApplication *> *runningApps(NSString *bundle) {
  return [NSRunningApplication runningApplicationsWithBundleIdentifier:bundle];
}

static BOOL isRegularFocusableApp(NSRunningApplication *app) {
  if (!app) return NO;
  if (app.isTerminated) return NO;
  if (!app.bundleIdentifier || app.bundleIdentifier.length == 0) return NO;
  if (app.activationPolicy != NSApplicationActivationPolicyRegular) return NO;

  return YES;
}

static NSRunningApplication *appBelowTarget(NSRunningApplication *targetApp) {
  if (!targetApp) return nil;

  pid_t targetPID = targetApp.processIdentifier;

  CFArrayRef windowInfo = CGWindowListCopyWindowInfo(
    kCGWindowListOptionOnScreenOnly,
    kCGNullWindowID
  );

  if (!windowInfo) return nil;

  NSArray *windows = CFBridgingRelease(windowInfo);

  for (NSDictionary *window in windows) {
    NSNumber *pidNumber = window[(id)kCGWindowOwnerPID];
    NSNumber *layerNumber = window[(id)kCGWindowLayer];
    NSDictionary *bounds = window[(id)kCGWindowBounds];

    if (!pidNumber || !layerNumber) continue;

    pid_t pid = (pid_t)[pidNumber intValue];

    // Skip the target app itself.
    if (pid == targetPID) continue;

    // Normal app windows are usually layer 0.
    if ([layerNumber intValue] != 0) continue;

    // Skip zero-size / junk windows.
    if (bounds) {
      CGFloat width = [bounds[@"Width"] doubleValue];
      CGFloat height = [bounds[@"Height"] doubleValue];

      if (width <= 1 || height <= 1) continue;
    }

    NSRunningApplication *candidate =
      [NSRunningApplication runningApplicationWithProcessIdentifier:pid];

    if (!isRegularFocusableApp(candidate)) continue;

    return candidate;
  }

  return nil;
}

static void focusAppWithoutMovingMouse(NSRunningApplication *app) {
  if (!app) return;

  [app activateWithOptions:NSApplicationActivateAllWindows |
                           NSApplicationActivateIgnoringOtherApps];
}

static void moveMouseToCenterOfFirstWindow(NSRunningApplication *app) {
  NSArray *windows = copyWindowsForApp(app);
  if (windows.count == 0) return;

  AXUIElementRef window = (__bridge AXUIElementRef)[windows objectAtIndex:0];

  CGPoint origin = CGPointZero;
  CGSize size = CGSizeZero;

  if (!getWindowFrame(window, &origin, &size)) return;

  CGPoint center = CGPointMake(
    origin.x + size.width / 2.0,
    origin.y + size.height / 2.0
  );

  CGWarpMouseCursorPosition(center);
  CGAssociateMouseAndMouseCursorPosition(true);
}

static void activateApp(NSRunningApplication *app) {
  [app activateWithOptions:NSApplicationActivateAllWindows |
                           NSApplicationActivateIgnoringOtherApps];

  // Give macOS a brief moment to bring the app/window forward
  // before querying its window geometry.
  [NSThread sleepForTimeInterval:0.05];

  moveMouseToCenterOfFirstWindow(app);
}

static int stash(NSString *bundle, NSRunningApplication *app) {
  NSArray *windows = copyWindowsForApp(app);
  NSMutableString *state = [NSMutableString string];
  NSUInteger saved = 0;

  for (id windowObject in windows) {
    AXUIElementRef window = (__bridge AXUIElementRef)windowObject;

    CGPoint origin = CGPointZero;
    CGSize size = CGSizeZero;

    if (!getWindowFrame(window, &origin, &size)) continue;

    [state appendFormat:@"%lu %.0f %.0f %.0f %.0f\n",
      (unsigned long)saved,
      origin.x,
      origin.y,
      size.width,
      size.height];

    CGPoint center = CGPointMake(
      origin.x + size.width / 2.0,
      origin.y + size.height / 2.0
    );

    CGRect display = displayBoundsForPoint(center);

    CGPoint stashed = CGPointMake(
      CGRectGetMaxX(display) - 5.0,
      origin.y
    );

    setWindowOrigin(window, stashed);

    saved++;
  }

  if (saved == 0) {
    logEvent(bundle, @"action=stash status=no-windows");
    return 2;
  }

  NSError *error = nil;

  [state writeToFile:statePath(bundle)
          atomically:YES
            encoding:NSUTF8StringEncoding
               error:&error];

  if (error) {
    logEvent(bundle, [NSString stringWithFormat:
      @"action=stash status=write-error error=%@", error]);
    return 3;
  }

  logEvent(bundle, [NSString stringWithFormat:
    @"action=stash status=ok windows=%lu", (unsigned long)saved]);

  return 0;
}

static int restore(NSString *bundle, NSRunningApplication *app) {
  NSString *path = statePath(bundle);

  NSString *contents = [NSString stringWithContentsOfFile:path
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];

  if (!contents) {
    logEvent(bundle, @"action=restore status=no-state");
    return 4;
  }

  NSArray *windows = copyWindowsForApp(app);

  NSArray<NSString *> *lines =
    [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

  NSUInteger restored = 0;

  for (NSString *line in lines) {
    if (line.length == 0) continue;

    unsigned long idx = 0;
    double x = 0;
    double y = 0;
    double w = 0;
    double h = 0;

    if (sscanf(line.UTF8String, "%lu %lf %lf %lf %lf", &idx, &x, &y, &w, &h) != 5) {
      continue;
    }

    if (idx >= windows.count) continue;

    AXUIElementRef window = (__bridge AXUIElementRef)[windows objectAtIndex:idx];

    setWindowSize(window, CGSizeMake(w, h));
    setWindowOrigin(window, CGPointMake(x, y));

    restored++;
  }

  [[NSFileManager defaultManager] removeItemAtPath:path error:nil];

  activateApp(app);

  logEvent(bundle, [NSString stringWithFormat:
    @"action=restore status=ok windows=%lu", (unsigned long)restored]);

  return 0;
}

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    if (argc != 2) {
      fprintf(stderr, "usage: toggle-overlay-app bundle-id\n");
      return 64;
    }

    NSString *bundle = [NSString stringWithUTF8String:argv[1]];
    NSArray<NSRunningApplication *> *apps = runningApps(bundle);
    NSString *path = statePath(bundle);

    logEvent(bundle, @"event=invoked");

    if (apps.count > 0 && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
      int status = restore(bundle, apps[0]);

      if (status == 0) {
        printf("action=restore\n");
      }

      return status;
    }

    NSRunningApplication *frontmost = [[NSWorkspace sharedWorkspace] frontmostApplication];

    if (apps.count > 0 && [frontmost.bundleIdentifier isEqualToString:bundle]) {
      NSRunningApplication *below = appBelowTarget(apps[0]);

      if (below) {
        logEvent(bundle, [NSString stringWithFormat:
          @"action=focus-below candidate=%@ pid=%d",
          below.bundleIdentifier,
          below.processIdentifier]);
      } else {
        logEvent(bundle, @"action=focus-below candidate=none");
      }

      int status = stash(bundle, apps[0]);

      if (status == 0) {
        if (below) {
          focusAppWithoutMovingMouse(below);

          logEvent(bundle, [NSString stringWithFormat:
            @"action=focus-below status=ok bundle=%@ pid=%d",
            below.bundleIdentifier,
            below.processIdentifier]);
        } else {
          logEvent(bundle, @"action=focus-below status=skipped");
        }

        printf("action=stash\n");
      }

      return status;
    }

    BOOL launched = NO;

    if (apps.count == 0) {
      NSURL *appURL = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:bundle];

      if (appURL) {
        [[NSWorkspace sharedWorkspace] openApplicationAtURL:appURL
                                              configuration:[NSWorkspaceOpenConfiguration configuration]
                                          completionHandler:nil];

        launched = YES;

        logEvent(bundle, @"action=open-requested status=ok");
      } else {
        logEvent(bundle, @"action=open-requested status=no-app-url");
      }

      for (NSUInteger i = 0; i < 20; i++) {
        [NSThread sleepForTimeInterval:0.05];

        apps = runningApps(bundle);

        logEvent(bundle, [NSString stringWithFormat:
          @"action=poll-running count=%lu", (unsigned long)apps.count]);

        if (apps.count > 0) break;
      }
    }

    if (apps.count > 0) {
      activateApp(apps[0]);

      NSString *action = launched ? @"open" : @"show";

      logEvent(bundle, [NSString stringWithFormat:
        @"action=%@ status=ok pid=%d",
        action,
        apps[0].processIdentifier]);

      printf("action=%s\n", launched ? "open" : "show");

      return 0;
    }

    logEvent(bundle, @"action=activate status=failed");

    return 1;
  }
}
