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

#ifndef LIBXL_RICHSTRINGA_H
#define LIBXL_RICHSTRINGA_H

#include "setup.h"
#include "handle.h"


#ifdef __cplusplus
extern "C"
{
#endif

    XLAPI  FontHandle XLAPIENTRY xlRichStringAddFontA(RichStringHandle handle, FontHandle initFont);
    XLAPI        void XLAPIENTRY xlRichStringAddTextA(RichStringHandle handle, const char* text, FontHandle font);
    XLAPI const char* XLAPIENTRY xlRichStringGetTextA(RichStringHandle handle, int index, FontHandle* font);
    XLAPI         int XLAPIENTRY xlRichStringTextSizeA(RichStringHandle handle);

#ifdef __cplusplus
}
#endif

#endif

