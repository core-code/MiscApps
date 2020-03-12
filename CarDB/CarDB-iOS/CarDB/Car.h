//
//  Car.h
//  CarDB
//
//  Created by CoreCode on 07.02.14.
//  Copyright © 2018 CoreCode Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Car : NSObject


@property (strong) NSString *modelname;
@property (strong) NSString *brand;

@property (assign) NSInteger weightEU;
@property (assign) NSInteger cylinderCount;
@property (assign) NSInteger displacementCCM;
@property (assign) NSInteger maxHorsepower;
@property (assign) NSInteger maxHorsepowerRRM;
@property (assign) NSInteger maxTorque;
@property (assign) NSInteger maxTorqueRPMLow;
@property (assign) NSInteger maxSpeed;
@property (assign) NSInteger co2Emission;
@property (assign) NSInteger fuelTankSize;
@property (assign) NSInteger wheelsWidthFront;
@property (assign) NSInteger wheelsRatioFront;
@property (assign) NSInteger wheelsRadiusFront;
@property (assign) NSInteger wheelsWidthBack;
@property (assign) NSInteger wheelsRatioBack;
@property (assign) NSInteger wheelsRadiusBack;
@property (assign) NSInteger gearCount;
@property (assign) NSInteger maxSeatCount;
@property (assign) NSInteger minPriceEU;
@property (assign) NSInteger doorCount;
@property (assign) CGFloat minPriceUS;
@property (assign) NSInteger luggageSpaceMin;
@property (assign) NSInteger luggageSpaceMax;
@property (assign) NSInteger widthMM;
@property (assign) NSInteger heightMM;
@property (assign) NSInteger lengthMM;
@property (assign) NSInteger wheelDistanceMM;

@property (assign) float accelerationTo100;
@property (assign) float elasticity80To120;
@property (assign) float fuelConsumptionEUCombined;

	/**/
@property (assign) NSInteger horsepowerPerTonne;
@property (assign) NSInteger horsepowerPerDisplacement;
@property (assign) float heightToWidth;

	/*enums*/
@property (assign) NSInteger fuelType;
@property (assign) NSInteger transmissionType;
@property (assign) NSInteger engineLocation;
@property (assign) NSInteger poweredWheels;
@property (assign) NSInteger adaptiveSuspension;
@property (assign) NSInteger engineAspiration;
@property (assign) NSInteger cylinderLayout;


@end
