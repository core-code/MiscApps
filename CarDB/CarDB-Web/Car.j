/*
 * Car.j
 * CarDB
 *
 * Created by CoreCode on December 1, 2012.
 * Copyright 2012, CoreCode All rights reserved.
 */

@implementation Car : CPObject
{
	CPString modelname @accessors;
	CPString brand @accessors;

	CPInteger weightEU @accessors;
	CPInteger cylinderCount @accessors;
	CPInteger displacementCCM @accessors;
	CPInteger maxHorsepower @accessors;
	CPInteger maxHorsepowerRRM @accessors;
	CPInteger maxTorque @accessors;
	CPInteger maxTorqueRPMLow @accessors;
	CPInteger maxSpeed @accessors;
	CPInteger co2Emission @accessors;
	CPInteger fuelTankSize @accessors;
	CPInteger wheelsWidthFront @accessors;
	CPInteger wheelsRatioFront @accessors;
	CPInteger wheelsRadiusFront @accessors;
	CPInteger wheelsWidthBack @accessors;
	CPInteger wheelsRatioBack @accessors;
	CPInteger wheelsRadiusBack @accessors;
	CPInteger gearCount @accessors;
	CPInteger maxSeatCount @accessors;
	CPInteger minPriceEU @accessors;
	CPInteger doorCount @accessors;
	CPInteger minPriceUS @accessors;
	CPInteger luggageSpaceMin @accessors;
	CPInteger luggageSpaceMax @accessors;
	CPInteger widthMM @accessors;
	CPInteger heightMM @accessors;
	CPInteger lengthMM @accessors;
	CPInteger wheelDistanceMM @accessors;

	float accelerationTo100 @accessors;
	float elasticity80To120 @accessors;
	float fuelConsumptionEUCombined @accessors;

	/**/
	CPInteger horsepowerPerTonne  @accessors;
	CPInteger horsepowerPerDisplacement  @accessors;
	float heightToWidth  @accessors;

	/*enums*/
	CPInteger fuelType @accessors;
	CPInteger transmissionType @accessors;
	CPInteger engineLocation @accessors;
	CPInteger poweredWheels @accessors;
	CPInteger adaptiveSuspension @accessors;
	CPInteger engineAspiration @accessors;
	CPInteger cylinderLayout @accessors;
}
@end
