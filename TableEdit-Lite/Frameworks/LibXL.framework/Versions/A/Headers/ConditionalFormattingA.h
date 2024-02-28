///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                    LibXL C++ headers version 4.2.0                        //
//                                                                           //
//                 Copyright (c) 2008 - 2023 XLware s.r.o.                   //
//                                                                           //
//   THIS FILE AND THE SOFTWARE CONTAINED HEREIN IS PROVIDED 'AS IS' AND     //
//                COMES WITH NO WARRANTIES OF ANY KIND.                      //
//                                                                           //
//          Please define LIBXL_STATIC variable for static linking.          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

#ifndef LIBXL_CONDITIONALFORMATTINGA_H
#define LIBXL_CONDITIONALFORMATTINGA_H

#include "setup.h"
#include "handle.h"
#include "enum.h"

#ifdef __cplusplus
extern "C"
{
#endif

    XLAPI void XLAPIENTRY xlConditionalFormattingAddRangeA(ConditionalFormattingHandle handle, int rowFirst, int rowLast, int colFirst, int colLast);

    XLAPI void XLAPIENTRY xlConditionalFormattingAddRuleA(ConditionalFormattingHandle handle, int type, ConditionalFormatHandle cFormat, const char* value, int stopIfTrue);

    XLAPI void XLAPIENTRY xlConditionalFormattingAddTopRuleA(ConditionalFormattingHandle handle, ConditionalFormatHandle cFormat, int value, int bottom, int percent, int stopIfTrue);

    XLAPI void XLAPIENTRY xlConditionalFormattingAddOpNumRuleA(ConditionalFormattingHandle handle, int op, ConditionalFormatHandle cFormat, double value1, double value2, int stopIfTrue);
    XLAPI void XLAPIENTRY xlConditionalFormattingAddOpStrRuleA(ConditionalFormattingHandle handle, int op, ConditionalFormatHandle cFormat, const char* value1, const char* value2, int stopIfTrue);

    XLAPI void XLAPIENTRY xlConditionalFormattingAddAboveAverageRuleA(ConditionalFormattingHandle handle, ConditionalFormatHandle cFormat, int aboveAverage, int equalAverage, int stdDev, int stopIfTrue);

    XLAPI void XLAPIENTRY xlConditionalFormattingAddTimePeriodRuleA(ConditionalFormattingHandle handle, ConditionalFormatHandle cFormat, int timePeriod, int stopIfTrue);

    XLAPI void XLAPIENTRY xlConditionalFormattingAdd2ColorScaleRuleA(ConditionalFormattingHandle handle, int minColor, int maxColor, int minType, double minValue, int maxType, double maxValue, int stopIfTrue);
    XLAPI void XLAPIENTRY xlConditionalFormattingAdd2ColorScaleFormulaRuleA(ConditionalFormattingHandle handle, int minColor, int maxColor, int minType, const char* minValue, int maxType, const char* maxValue, int stopIfTrue);

    XLAPI void XLAPIENTRY xlConditionalFormattingAdd3ColorScaleRuleA(ConditionalFormattingHandle handle, int minColor, int midColor, int maxColor, int minType, double minValue, int midType, double midValue, int maxType, double maxValue, int stopIfTrue);
    XLAPI void XLAPIENTRY xlConditionalFormattingAdd3ColorScaleFormulaRuleA(ConditionalFormattingHandle handle, int minColor, int midColor, int maxColor, int minType, const char* minValue, int midType, const char* midValue, int maxType, const char* maxValue, int stopIfTrue);

#ifdef __cplusplus
}
#endif

#endif



