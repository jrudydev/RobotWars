//
//  TerminatorRobot.m
//  RobotWar
//
//  Created by Rodolfo Gomez on 6/30/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "TerminatorRobot.h"
#import "Bullet.h"

#define ARC4RANDOM_MAX      0x100000000

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFiring,
    RobotStateSearching,
    RobotStateEvade,
    RobotStateSnipe
};

@implementation TerminatorRobot {
    RobotState _currentRobotState;
    
    CGPoint _lastKnownTrajectory;
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    
    BOOL _movingFoward;
    
    int _friendHitPoints;
    int _enemyHitPoints;
}

static int evadeMoveDist = 60;

- (id)init
{
    if (self= [super init])
    {
        _movingFoward= YES;
        _friendHitPoints = 20;
        _enemyHitPoints = 20;
        
        //_currentRobotState = RobotStateFiring;
    }
    
    return self;
}

- (void)run {
    while (true) {
        /*  if (_lastKnownPositionTimestamp < 2.0f && _lastKnownPositionTimestamp != 0.0f)
         {
         _currentRobotState = RobotStateSnipe;
         }
         */
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
                // NSLog(@"tank life: %d <> enemy life: %d", _friendHitPoints, (_enemyHitPoints + 2));
                if (_friendHitPoints < _enemyHitPoints + 2)
                {
                    // enemy has more hit points
                    // time to evade
                    _currentRobotState = RobotStateEvade;
                }
            }
        }
        
        if (_currentRobotState == RobotStateSearching) {
            CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
            /*    if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 2.f)
             {
             CGPoint tankPos = ccp([self robotBoundingBox].origin.x + [self robotBoundingBox].size.width /2, [self robotBoundingBox].origin.y + [self robotBoundingBox].size.height / 2);
             CGPoint pos = ccpAdd(tankPos, [self vectorFromWall]);
             angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:pos];
             }
             else
             {
             angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
             }
             */
            if ((self.currentTimestamp - _lastKnownPositionTimestamp) < 1.f)
            {
                if (angle >= 0) {
                    [self turnGunRight:abs(angle)];
                } else {
                    [self turnGunLeft:abs(angle)];
                }
            }
            
            [self shoot];
            [self moveTank:50];
            [self turnRobotRandomSide:20];
            [self moveTank:50];
            [self turnRobotRandomSide:20];
        }
        
        if (_currentRobotState == RobotStateDefault) {
            
            CGPoint pos = ccp([self arenaDimensions].width / 2, [self arenaDimensions].height / 2);
            
            float angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:pos];
            
            if (angle >= 0)
            {
                [self turnGunRight:abs(angle)];
            }
            else
            {
                [self turnGunLeft:abs(angle)];
            }
            
            [self shoot];
            [self shoot];
            [self shoot];
            
            if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f)
            {
                _currentRobotState = RobotStateSearching;
            }
        }
        
        if (_currentRobotState == RobotStateEvade)
        {
            CGFloat angle = [self angleBetweenHeadingDirectionAndWorldPosition:_lastKnownPosition];
            if (angle > -30 && angle <= 0)
            {
                [self turnRobotLeft:50];
                //_movingFoward = NO;
                
            }
            else if (angle >= 0 && angle < 30)
            {
                [self turnRobotRight:50];
                //_movingFoward = NO;
                
            }
            else if (angle > 150 && angle <= 180)
            {
                [self turnRobotLeft:50];
                //_movingFoward = YES;
                
            }
            else if (angle >= -180 && angle <-150)
            {
                [self turnRobotRight:50];
                //_movingFoward = YES;
            }
            else if (angle > -90 && angle < 90)
            {
                //_movingFoward = NO;
            }
            else
            {
                //_movingFoward = YES;
            }
            
            //int random = ((double)arc4random() / ARC4RANDOM_MAX);
            
            //_movingFoward = (random % 2 == 1) ? YES : NO;
            [self moveTank:evadeMoveDist];
            
            _currentRobotState = RobotStateFiring;
        }
        
        if (_currentRobotState == RobotStateSnipe)
        {
            CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
            if (angle >= 0) {
                [self turnGunRight:abs(angle)];
            } else {
                [self turnGunLeft:abs(angle)];
            }
            [self shoot];
        }
    }
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    // There are a couple of neat things you could do in this handler
    _enemyHitPoints--;
    
    _lastKnownTrajectory = ccpSub(bullet.position, _lastKnownPosition);
    NSLog(@"trajector calc x:%f <> y:%f", _lastKnownTrajectory.x, _lastKnownTrajectory.y);
    
    _lastKnownPosition = bullet.position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
}

- (void)gotHit
{
    _friendHitPoints--;
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    /*if (_currentRobotState != RobotStateFiring) {
     [self cancelActiveAction];
     }
     */
    //_lastKnownTrajectory = ccpSub(position, _lastKnownPosition);
    //NSLog(@"trajector calc x:%d <> y:%d", _lastKnownTrajectory.x, _lastKnownTrajectory.y);
    _lastKnownPosition = position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
    _currentRobotState = RobotStateFiring;
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    if (_currentRobotState != RobotStateTurnaround) {
        [self cancelActiveAction];
        
        RobotState previousState = _currentRobotState;
        _currentRobotState = RobotStateTurnaround;
        NSLog(@"hit angle: %f", angle);
        /*
         // always turn to head straight away from the wall
         if (angle >= 0) {
         [self turnRobotLeft:abs(angle)];
         } else {
         [self turnRobotRight:abs(angle)];
         }
         */
        
        if (_movingFoward)
        {
            // front of tank hit the wall
            // change drive direction
            _movingFoward = NO;
            
            if (angle >= 0) {
                angle = 180 - angle;
                [self turnRobotRight:abs(angle)];
                [self turnGunLeft:abs(angle)];
            } else {
                angle = 180 + angle;
                [self turnRobotLeft:abs(angle)];
                [self turnGunRight:abs(angle)];
            }
            
            /*   // tank is moving in forward direction
             if (angle > -90 && angle < 90)
             {
             
             
             
             }
             else
             {
             _movingFoward = YES;
             }*/
        }
        else
        {
            // back of tank hit the wall
            // change drive direction
            _movingFoward = YES;
            
            if (angle >= 0)
            {
                [self turnRobotLeft:abs(angle)];
                [self turnGunRight:abs(angle)];
            }
            else
            {
                [self turnRobotRight:abs(angle)];
                [self turnGunLeft:abs(angle)];
            }
            /*if (angle > -90 && angle < 90)
             {
             _movingFoward = YES;
             }
             else
             {
             _movingFoward = NO;
             }*/
        }
        
        [self moveTank:100];
        
        _currentRobotState = previousState;
    }
}

- (void)moveTank:(int)distance
{
    if(_movingFoward)
    {
        [self moveAhead:distance];
    }
    else
    {
        [self moveBack:distance];
    }
}

- (CGPoint)vectorFromWall
{
    float distFromLeftWall = [self robotBoundingBox].origin.x + [self robotBoundingBox].size.width / 2;
    float distFromRightWall = [self arenaDimensions].width - ([self robotBoundingBox].origin.x + [self robotBoundingBox].size.width / 2);
    float distFromTopWall = [self robotBoundingBox].origin.y + [self robotBoundingBox].size.height / 2;
    float distFromBottomWall = [self arenaDimensions].height - ([self robotBoundingBox].origin.y + [self robotBoundingBox].size.height / 2);
    
    float closestToWall = distFromLeftWall;
    CGPoint pos= ccp(1, 0);
    if (distFromRightWall < closestToWall)
    {
        closestToWall = distFromRightWall;
        pos= ccp(-1, 0);
    }
    
    if (distFromTopWall < closestToWall)
    {
        closestToWall = distFromTopWall;
        pos = ccp(0, 1);
    }
    
    if (distFromBottomWall < closestToWall)
    {
        closestToWall = distFromBottomWall;
        pos = ccp(0, -1);
    }
    
    return pos;
}

- (void)turnRobotRandomSide:(int)distance
{
    if (arc4random() % 2 == 0)
    {
        [self turnRobotLeft:distance];
    }
    else
    {
        [self turnRobotRight:distance];
    }
}

@end
