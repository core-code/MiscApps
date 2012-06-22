/*
 * Copyright (C) 2003 CoreCode
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
 * USA
 */

#include <dvdread/dvd_reader.h>
#include <dvdread/ifo_types.h>
#include <dvdread/ifo_read.h>

#include <stdio.h>

int main (int argc, const char *argv[])
{
    dvd_reader_t *dvd;
    ifo_handle_t *ifohandle;
    tt_srpt_t *tt_srpt;    
    int number, i;
    
    if( argc != 2 )
	{
        fprintf( stderr, "Usage: %s <dvd path>\n", argv[ 0 ] );
        return -1;
    }
    
    dvd = DVDOpen(argv[1]);
    
    if( !dvd )
		return 0;
		
	ifohandle = ifoOpen(dvd, 0);
	number = ifohandle->vmgi_mat->vmg_nr_of_title_sets;
    tt_srpt = ifohandle->tt_srpt;
	
	for( i = 0; i < tt_srpt->nr_of_srpts; ++i )
	{
    	ifo_handle_t *ifo2;
			
		ifo2 = ifoOpen(dvd, tt_srpt->title[ i ].title_set_nr);
		if(!ifo2)
			return 0;

		printf("%02x:%02x:%02x\n",
			   ifo2->vts_pgcit->pgci_srp->pgc->playback_time.hour,
			   ifo2->vts_pgcit->pgci_srp->pgc->playback_time.minute,
			   ifo2->vts_pgcit->pgci_srp->pgc->playback_time.second);
		
		ifoClose(ifo2);		
	}
	ifoClose(ifohandle);
    DVDClose(dvd);
}