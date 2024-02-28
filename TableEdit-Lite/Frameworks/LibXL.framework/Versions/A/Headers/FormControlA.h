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

#ifndef LIBXL_FORMCONTROLA_H
#define LIBXL_FORMCONTROLA_H

#include "setup.h"
#include "handle.h"

#ifdef __cplusplus
extern "C"
{
#endif

    XLAPI int XLAPIENTRY xlFormControlObjectTypeA(FormControlHandle handle);

    XLAPI int XLAPIENTRY xlFormControlCheckedA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetCheckedA(FormControlHandle handle, int checked);

    XLAPI const char* XLAPIENTRY xlFormControlFmlaGroupA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetFmlaGroupA(FormControlHandle handle, const char* group);

    XLAPI const char* XLAPIENTRY xlFormControlFmlaLinkA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetFmlaLinkA(FormControlHandle handle, const char* link);

    XLAPI const char* XLAPIENTRY xlFormControlFmlaRangeA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetFmlaRangeA(FormControlHandle handle, const char* range);

    XLAPI const char* XLAPIENTRY xlFormControlFmlaTxbxA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetFmlaTxbxA(FormControlHandle handle, const char* txbx);

    XLAPI const char* XLAPIENTRY xlFormControlNameA(FormControlHandle handle);
    XLAPI const char* XLAPIENTRY xlFormControlLinkedCellA(FormControlHandle handle);
    XLAPI const char* XLAPIENTRY xlFormControlListFillRangeA(FormControlHandle handle);
    XLAPI const char* XLAPIENTRY xlFormControlMacroA(FormControlHandle handle);
    XLAPI const char* XLAPIENTRY xlFormControlAltTextA(FormControlHandle handle);

    XLAPI int XLAPIENTRY xlFormControlLockedA(FormControlHandle handle);
    XLAPI int XLAPIENTRY xlFormControlDefaultSizeA(FormControlHandle handle);
    XLAPI int XLAPIENTRY xlFormControlPrintA(FormControlHandle handle);
    XLAPI int XLAPIENTRY xlFormControlDisabledA(FormControlHandle handle);

    XLAPI const char* XLAPIENTRY xlFormControlItemA(FormControlHandle handle, int index);
    XLAPI int XLAPIENTRY xlFormControlItemSizeA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlAddItemA(FormControlHandle handle, const char* value);
    XLAPI void XLAPIENTRY xlFormControlInsertItemA(FormControlHandle handle, int index, const char* value);
    XLAPI void XLAPIENTRY xlFormControlClearItemsA(FormControlHandle handle);

    XLAPI int XLAPIENTRY xlFormControlDropLinesA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetDropLinesA(FormControlHandle handle, int lines);

    XLAPI int XLAPIENTRY xlFormControlDxA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetDxA(FormControlHandle handle, int dx);

    XLAPI int XLAPIENTRY xlFormControlFirstButtonA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetFirstButtonA(FormControlHandle handle, int firstButton);

    XLAPI int XLAPIENTRY xlFormControlHorizA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetHorizA(FormControlHandle handle, int horiz);

    XLAPI int XLAPIENTRY xlFormControlIncA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetIncA(FormControlHandle handle, int inc);

    XLAPI int XLAPIENTRY xlFormControlGetMaxA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetMaxA(FormControlHandle handle, int max);

    XLAPI int XLAPIENTRY xlFormControlGetMinA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetMinA(FormControlHandle handle, int min);

    XLAPI const char* XLAPIENTRY xlFormControlMultiSelA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetMultiSelA(FormControlHandle handle, const char* value);

    XLAPI int XLAPIENTRY xlFormControlSelA(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetSelA(FormControlHandle handle, int sel);

    XLAPI int XLAPIENTRY xlFormControlFromAnchorA(FormControlHandle handle, int* col, int* colOff, int* row, int* rowOff);
    XLAPI int XLAPIENTRY xlFormControlToAnchorA(FormControlHandle handle, int* col, int* colOff, int* row, int* rowOff);


#ifdef __cplusplus
}
#endif


#endif


