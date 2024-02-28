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

#ifndef LIBXL_CONDITIONALFORMATA_H
#define LIBXL_CONDITIONALFORMATA_H

#include "setup.h"
#include "handle.h"
#include "enum.h"

#ifdef __cplusplus
extern "C"
{
#endif

    XLAPI FontHandle XLAPIENTRY xlConditionalFormatFontA(ConditionalFormatHandle handle);

    XLAPI int XLAPIENTRY xlConditionalFormatNumFormatA(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetNumFormatA(ConditionalFormatHandle handle, int numFormat);

    XLAPI const char* XLAPIENTRY xlConditionalFormatCustomNumFormatA(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetCustomNumFormatA(ConditionalFormatHandle handle, const char* customNumFormat);

    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderA(ConditionalFormatHandle handle, int style);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderColorA(ConditionalFormatHandle handle, int color);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderLeftA(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderLeftA(ConditionalFormatHandle handle, int style);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderRightA(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderRightA(ConditionalFormatHandle handle, int style);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderTopA(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderTopA(ConditionalFormatHandle handle, int style);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderBottomA(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderBottomA(ConditionalFormatHandle handle, int style);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderLeftColorA(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderLeftColorA(ConditionalFormatHandle handle, int color);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderRightColorA(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderRightColorA(ConditionalFormatHandle handle, int color);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderTopColorA(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderTopColorA(ConditionalFormatHandle handle, int color);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderBottomColorA(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderBottomColorA(ConditionalFormatHandle handle, int color);

    XLAPI int XLAPIENTRY xlConditionalFormatFillPatternA(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetFillPatternA(ConditionalFormatHandle handle, int pattern);

    XLAPI int XLAPIENTRY xlConditionalFormatPatternForegroundColorA(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetPatternForegroundColorA(ConditionalFormatHandle handle, int color);

    XLAPI int XLAPIENTRY xlConditionalFormatPatternBackgroundColorA(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetPatternBackgroundColorA(ConditionalFormatHandle handle, int color);

#ifdef __cplusplus
}
#endif

#endif
