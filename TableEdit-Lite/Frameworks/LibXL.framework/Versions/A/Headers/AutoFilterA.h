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

#ifndef LIBXL_AUTOFILTERA_H
#define LIBXL_AUTOFILTERA_H

#include "setup.h"
#include "handle.h"

#ifdef __cplusplus
extern "C"
{
#endif

    XLAPI                int XLAPIENTRY xlAutoFilterGetRefA(AutoFilterHandle handle, int* rowFirst, int* rowLast, int* colFirst, int* colLast);
    XLAPI               void XLAPIENTRY xlAutoFilterSetRefA(AutoFilterHandle handle, int rowFirst, int rowLast, int colFirst, int colLast);

    XLAPI FilterColumnHandle XLAPIENTRY xlAutoFilterColumnA(AutoFilterHandle handle, int colId);

    XLAPI                int XLAPIENTRY xlAutoFilterColumnSizeA(AutoFilterHandle handle);
    XLAPI FilterColumnHandle XLAPIENTRY xlAutoFilterColumnByIndexA(AutoFilterHandle handle, int index);

    XLAPI                int XLAPIENTRY xlAutoFilterGetSortRangeA(AutoFilterHandle handle, int* rowFirst, int* rowLast, int* colFirst, int* colLast);

    XLAPI                int XLAPIENTRY xlAutoFilterGetSortA(AutoFilterHandle handle, int* columnIndex, int* descending);
    XLAPI                int XLAPIENTRY xlAutoFilterSetSortA(AutoFilterHandle handle, int columnIndex, int descending);
    XLAPI                int XLAPIENTRY xlAutoFilterAddSortA(AutoFilterHandle handle, int columnIndex, int descending);


#ifdef __cplusplus
}
#endif

#endif
