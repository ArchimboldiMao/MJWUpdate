//
//  MJWUpdateTests.m
//  MJWUpdateTests
//
//  Created by Archimboldi Mao on 16/12/2016.
//  Copyright © 2016 Archimboldi Mao. All rights reserved.
//  LICENSE file in the root directory of this source tree.
//

#import <XCTest/XCTest.h>
#import "MJWUpdate.h"

@interface MJWUpdateTests : XCTestCase

@end

@implementation MJWUpdateTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// TODO:
// can't set or mock [[NSBundle mainBundle] bundleIdentifier], so the test is always success.
- (void)testCheckAppStoreLatestVersionWithAppleID {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    /**
     XCTest can't get [NSBundle mainBundle].
     So, I have to mock a bundle from MyAppTests to XCTest.
     https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/04-writing_tests.html
     Note: When you create a new project, a test target and associated test bundle are created for you by default with names derived from the name of your project. For instance, creating a new project named MyApp automatically generates a test bundle named MyAppTests and a test class named MyAppTests with the associated MyAppTests.m implementation file.
     *
    NSBundle *bundleTests = [NSBundle bundleForClass:[self class]];
    NSString *bundleIdentifierTests = [bundleTests bundleIdentifier];
    
    NSMutableArray *identifiers = [[bundleIdentifierTests componentsSeparatedByString:@"Tests"] mutableCopy];
    [identifiers removeLastObject];
    bundleIdentifier = [identifiers componentsJoinedByString:@"Tests"];
     */

    // Facebook App trackID is 284882215, bundleID is com.facebook.Facebook
    XCTestExpectation* expectation = [self expectationWithDescription:@"HTTP request"];
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    NSNumber *appleID = @284882215;
    MJWUpdate *versionUpdate = [MJWUpdate new];
    [versionUpdate checkAppStoreLatestVersionWithAppleID:appleID rootViewController:window.rootViewController block:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
