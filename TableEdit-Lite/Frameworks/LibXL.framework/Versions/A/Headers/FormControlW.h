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

#ifndef LIBXL_FORMCONTROLW_H
#define LIBXL_FORMCONTROLW_H

#include "setup.h"
#include "handle.h"

#ifdef __cplusplus
extern "C"
{
#endif

    XLAPI int XLAPIENTRY xlFormControlObjectTypeW(FormControlHandle handle);

    XLAPI int XLAPIENTRY xlFormControlCheckedW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetCheckedW(FormControlHandle handle, int checked);

    XLAPI const wchar_t* XLAPIENTRY xlFormControlFmlaGroupW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetFmlaGroupW(FormControlHandle handle, const wchar_t* group);

    XLAPI const wchar_t* XLAPIENTRY xlFormControlFmlaLinkW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetFmlaLinkW(FormControlHandle handle, const wchar_t* link);

    XLAPI const wchar_t* XLAPIENTRY xlFormControlFmlaRangeW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetFmlaRangeW(FormControlHandle handle, const wchar_t* range);

    XLAPI const wchar_t* XLAPIENTRY xlFormControlFmlaTxbxW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetFmlaTxbxW(FormControlHandle handle, const wchar_t* txbx);

    XLAPI const wchar_t* XLAPIENTRY xlFormControlNameW(FormControlHandle handle);
    XLAPI const wchar_t* XLAPIENTRY xlFormControlLinkedCellW(FormControlHandle handle);
    XLAPI const wchar_t* XLAPIENTRY xlFormControlListFillRangeW(FormControlHandle handle);
    XLAPI const wchar_t* XLAPIENTRY xlFormControlMacroW(FormControlHandle handle);
    XLAPI const wchar_t* XLAPIENTRY xlFormControlAltTextW(FormControlHandle handle);

    XLAPI int XLAPIENTRY xlFormControlLockedW(FormControlHandle handle);
    XLAPI int XLAPIENTRY xlFormControlDefaultSizeW(FormControlHandle handle);
    XLAPI int XLAPIENTRY xlFormControlPrintW(FormControlHandle handle);
    XLAPI int XLAPIENTRY xlFormControlDisabledW(FormControlHandle handle);

    XLAPI const wchar_t* XLAPIENTRY xlFormControlItemW(FormControlHandle handle, int index);
    XLAPI int XLAPIENTRY xlFormControlItemSizeW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlAddItemW(FormControlHandle handle, const wchar_t* value);
    XLAPI void XLAPIENTRY xlFormControlInsertItemW(FormControlHandle handle, int index, const wchar_t* value);
    XLAPI void XLAPIENTRY xlFormControlClearItemsW(FormControlHandle handle);

    XLAPI int XLAPIENTRY xlFormControlDropLinesW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetDropLinesW(FormControlHandle handle, int lines);

    XLAPI int XLAPIENTRY xlFormControlDxW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetDxW(FormControlHandle handle, int dx);

    XLAPI int XLAPIENTRY xlFormControlFirstButtonW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetFirstButtonW(FormControlHandle handle, int firstButton);

    XLAPI int XLAPIENTRY xlFormControlHorizW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetHorizW(FormControlHandle handle, int horiz);

    XLAPI int XLAPIENTRY xlFormControlIncW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetIncW(FormControlHandle handle, int inc);

    XLAPI int XLAPIENTRY xlFormControlGetMaxW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetMaxW(FormControlHandle handle, int max);

    XLAPI int XLAPIENTRY xlFormControlGetMinW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetMinW(FormControlHandle handle, int min);

    XLAPI const wchar_t* XLAPIENTRY xlFormControlMultiSelW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetMultiSelW(FormControlHandle handle, const wchar_t* value);

    XLAPI int XLAPIENTRY xlFormControlSelW(FormControlHandle handle);
    XLAPI void XLAPIENTRY xlFormControlSetSelW(FormControlHandle handle, int sel);

    XLAPI int XLAPIENTRY xlFormControlFromAnchorW(FormControlHandle handle, int* col, int* colOff, int* row, int* rowOff);
    XLAPI int XLAPIENTRY xlFormControlToAnchorW(FormControlHandle handle, int* col, int* colOff, int* row, int* rowOff);


#ifdef __cplusplus
}
#endif


#endif
