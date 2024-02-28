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

#ifndef LIBXL_CONDITIONALFORMATTINGW_H
#define LIBXL_CONDITIONALFORMATTINGW_H

#include "setup.h"
#include "handle.h"
#include "enum.h"

#ifdef __cplusplus
extern "C"
{
#endif

    XLAPI void XLAPIENTRY xlConditionalFormattingAddRangeW(ConditionalFormattingHandle handle, int rowFirst, int rowLast, int colFirst, int colLast);

    XLAPI void XLAPIENTRY xlConditionalFormattingAddRuleW(ConditionalFormattingHandle handle, int type, ConditionalFormatHandle cFormat, const wchar_t* value, int stopIfTrue);

    XLAPI void XLAPIENTRY xlConditionalFormattingAddTopRuleW(ConditionalFormattingHandle handle, ConditionalFormatHandle cFormat, int value, int bottom, int percent, int stopIfTrue);

    XLAPI void XLAPIENTRY xlConditionalFormattingAddOpNumRuleW(ConditionalFormattingHandle handle, int op, ConditionalFormatHandle cFormat, double value1, double value2, int stopIfTrue);
    XLAPI void XLAPIENTRY xlConditionalFormattingAddOpStrRuleW(ConditionalFormattingHandle handle, int op, ConditionalFormatHandle cFormat, const wchar_t* value1, const wchar_t* value2, int stopIfTrue);

    XLAPI void XLAPIENTRY xlConditionalFormattingAddAboveAverageRuleW(ConditionalFormattingHandle handle, ConditionalFormatHandle cFormat, int aboveAverage, int equalAverage, int stdDev, int stopIfTrue);

    XLAPI void XLAPIENTRY xlConditionalFormattingAddTimePeriodRuleW(ConditionalFormattingHandle handle, ConditionalFormatHandle cFormat, int timePeriod, int stopIfTrue);

    XLAPI void XLAPIENTRY xlConditionalFormattingAdd2ColorScaleRuleW(ConditionalFormattingHandle handle, int minColor, int maxColor, int minType, double minValue, int maxType, double maxValue, int stopIfTrue);
    XLAPI void XLAPIENTRY xlConditionalFormattingAdd2ColorScaleFormulaRuleW(ConditionalFormattingHandle handle, int minColor, int maxColor, int minType, const wchar_t* minValue, int maxType, const wchar_t* maxValue, int stopIfTrue);

    XLAPI void XLAPIENTRY xlConditionalFormattingAdd3ColorScaleRuleW(ConditionalFormattingHandle handle, int minColor, int midColor, int maxColor, int minType, double minValue, int midType, double midValue, int maxType, double maxValue, int stopIfTrue);
    XLAPI void XLAPIENTRY xlConditionalFormattingAdd3ColorScaleFormulaRuleW(ConditionalFormattingHandle handle, int minColor, int midColor, int maxColor, int minType, const wchar_t* minValue, int midType, const wchar_t* midValue, int maxType, const wchar_t* maxValue, int stopIfTrue);

#ifdef __cplusplus
}
#endif

#endif


