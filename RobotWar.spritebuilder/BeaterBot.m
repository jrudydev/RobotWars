//
//  BeaterBot.m
//  RobotWar
//
//  Created by Arad Reed on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "BeaterBot.h"
#import "Bullet.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateRunning,
    RobotStateChasing,
    RobotStateFiring,
    RobotStateSearching
};

@implementation BeaterBot  {
    RobotState _currentRobotState;
    
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    
    BOOL _leftCorner;
    BOOL _leftSide;
    
    int _enemyHealth;
    int _botHealth;
}

- (void)run {
    while (true) {
        if (_currentRobotState == RobotStateFiring) {
            
            if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                _currentRobotState = RobotStateSearching;
            } else {
                CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                if (angle >= 0) {
                    [self turnGunRight:abs(angle)];
                } else {
                    [self turnGunLeft:abs(angle)];
                }
                [self shoot];
            }
        }
        
        if (_currentRobotState == RobotStateSearching) {
            CGPoint gunDirection = [self gunHeadingDirection];
            
            CCLOG(@"(%f, %f)", gunDirection.x, gunDirection.y);
            
            if (_leftSide) {
                // Left Side Start
                
                if (_leftCorner) {
                    if (gunDirection.y >= 0)
                        [self turnGunRight:110];
                    if (gunDirection.x <= 0) {
                        [self turnGunLeft:110];
                    }
                }
                else {
                    if (gunDirection.y <= 0)
                        [self turnGunLeft:110];
                    if (gunDirection.x <= 0) {
                        [self turnGunRight:110];
                    }
                }
            }
            else {
                // Right Side start
                
                if (_leftCorner) {
                    if (gunDirection.y <= 0)
                        [self turnGunRight:110];
                    if (gunDirection.x >= 0)
                        [self turnGunLeft:110];
                }
                else {
                    if (gunDirection.y >= 0)
                        [self turnGunLeft:110];
                    if (gunDirection.x >= 0)
                        [self turnGunRight:110];
                }
            }
            
            [self turnGunRight:10];
            [self shoot];
            
        }
        
        if (_currentRobotState == RobotStateRunning) {
            if (_leftCorner) {
                [self moveBack:300];
            }
            
            else {
                [self moveAhead:300];
            }
            
            _leftCorner = !_leftCorner;
            _currentRobotState = RobotStateSearching;
            
        }
        
        if (_currentRobotState == RobotStateDefault) {
            _leftCorner = TRUE;
            if (self.position.x < 320)
                _leftSide = TRUE;
            
            else
                _leftSide = FALSE;
            
            _botHealth = 20;
            _enemyHealth = 20;
            
            [self moveAhead: 10];
            [self turnRobotLeft:90];
            [self moveAhead:100];
        }
    }
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    // There are a couple of neat things you could do in this handler
    _enemyHealth--;
    [self shoot];
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    if (_currentRobotState != RobotStateFiring) {
        [self cancelActiveAction];
    }
    
    _lastKnownPosition = position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
    _currentRobotState = RobotStateFiring;
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    RobotState previousState = _currentRobotState;
    _currentRobotState = RobotStateSearching;
    
    if (previousState == RobotStateDefault) {
        [self turnGunRight:90];
    }
    
    [self moveBack:10];
    
}

- (void)gotHit {
    _botHealth--;
    
    _currentRobotState = RobotStateRunning;
}

@end