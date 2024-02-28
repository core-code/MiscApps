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

#ifndef LIBXL_CONDITIONALFORMATW_H
#define LIBXL_CONDITIONALFORMATW_H

#include "setup.h"
#include "handle.h"
#include "enum.h"

#ifdef __cplusplus
extern "C"
{
#endif

    XLAPI FontHandle XLAPIENTRY xlConditionalFormatFontW(ConditionalFormatHandle handle);

    XLAPI int XLAPIENTRY xlConditionalFormatNumFormatW(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetNumFormatW(ConditionalFormatHandle handle, int numFormat);

    XLAPI const wchar_t* XLAPIENTRY xlConditionalFormatCustomNumFormatW(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetCustomNumFormatW(ConditionalFormatHandle handle, const wchar_t* customNumFormat);

    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderW(ConditionalFormatHandle handle, int style);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderColorW(ConditionalFormatHandle handle, int color);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderLeftW(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderLeftW(ConditionalFormatHandle handle, int style);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderRightW(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderRightW(ConditionalFormatHandle handle, int style);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderTopW(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderTopW(ConditionalFormatHandle handle, int style);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderBottomW(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderBottomW(ConditionalFormatHandle handle, int style);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderLeftColorW(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderLeftColorW(ConditionalFormatHandle handle, int color);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderRightColorW(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderRightColorW(ConditionalFormatHandle handle, int color);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderTopColorW(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderTopColorW(ConditionalFormatHandle handle, int color);

    XLAPI int XLAPIENTRY xlConditionalFormatBorderBottomColorW(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetBorderBottomColorW(ConditionalFormatHandle handle, int color);

    XLAPI int XLAPIENTRY xlConditionalFormatFillPatternW(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetFillPatternW(ConditionalFormatHandle handle, int pattern);

    XLAPI int XLAPIENTRY xlConditionalFormatPatternForegroundColorW(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetPatternForegroundColorW(ConditionalFormatHandle handle, int color);

    XLAPI int XLAPIENTRY xlConditionalFormatPatternBackgroundColorW(ConditionalFormatHandle handle);
    XLAPI void XLAPIENTRY xlConditionalFormatSetPatternBackgroundColorW(ConditionalFormatHandle handle, int color);

#ifdef __cplusplus
}
#endif

#endif
