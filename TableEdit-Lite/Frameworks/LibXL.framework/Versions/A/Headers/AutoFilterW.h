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

#ifndef LIBXL_AUTOFILTERW_H
#define LIBXL_AUTOFILTERW_H

#include "setup.h"
#include "handle.h"

#ifdef __cplusplus
extern "C"
{
#endif

    XLAPI                int XLAPIENTRY xlAutoFilterGetRefW(AutoFilterHandle handle, int* rowFirst, int* rowLast, int* colFirst, int* colLast);
    XLAPI               void XLAPIENTRY xlAutoFilterSetRefW(AutoFilterHandle handle, int rowFirst, int rowLast, int colFirst, int colLast);

    XLAPI FilterColumnHandle XLAPIENTRY xlAutoFilterColumnW(AutoFilterHandle handle, int colId);

    XLAPI                int XLAPIENTRY xlAutoFilterColumnSizeW(AutoFilterHandle handle);
    XLAPI FilterColumnHandle XLAPIENTRY xlAutoFilterColumnByIndexW(AutoFilterHandle handle, int index);

    XLAPI                int XLAPIENTRY xlAutoFilterGetSortRangeW(AutoFilterHandle handle, int* rowFirst, int* rowLast, int* colFirst, int* colLast);

    XLAPI                int XLAPIENTRY xlAutoFilterGetSortW(AutoFilterHandle handle, int* columnIndex, int* descending);
    XLAPI                int XLAPIENTRY xlAutoFilterSetSortW(AutoFilterHandle handle, int columnIndex, int descending);
    XLAPI                int XLAPIENTRY xlAutoFilterAddSortW(AutoFilterHandle handle, int columnIndex, int descending);


#ifdef __cplusplus
}
#endif

#endif
