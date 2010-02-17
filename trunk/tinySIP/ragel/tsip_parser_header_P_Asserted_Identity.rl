/*
* Copyright (C) 2009 Mamadou Diop.
*
* Contact: Mamadou Diop <diopmamadou@yahoo.fr>
*	
* This file is part of Open Source Doubango Framework.
*
* DOUBANGO is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*	
* DOUBANGO is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*	
* You should have received a copy of the GNU General Public License
* along with DOUBANGO.
*
*/

/**@file tsip_header_P_Asserted_Identity.c
 * @brief SIP P-Asserted-Identity header as per RFC 3325.
 *
 * @author Mamadou Diop <diopmamadou(at)yahoo.fr>
 *
 * @date Created: Sat Nov 8 16:54:58 2009 mdiop
 */
#include "tinysip/headers/tsip_header_P_Asserted_Identity.h"

#include "tinysip/parsers/tsip_parser_uri.h"

#include "tsk_debug.h"
#include "tsk_memory.h"
#include "tsk_time.h"

#include <string.h>

/**@defgroup tsip_header_P_Asserted_Identity_group SIP P_Asserted_Identity header.
*/

/***********************************
*	Ragel state machine.
*/
%%{
	machine tsip_machine_parser_header_P_Asserted_Identity;

	# Includes
	include tsip_machine_utils "./tsip_machine_utils.rl";
	
	action tag
	{
		tag_start = p;
	}
	
	action create_p_asserted_identity
	{
		if(!curr_p_asserted_identity)
		{
			curr_p_asserted_identity = TSIP_HEADER_P_ASSERTED_IDENTITY_CREATE();
		}
	}

	action parse_display_name
	{
		if(curr_p_asserted_identity)
		{
			TSK_PARSER_SET_STRING(curr_p_asserted_identity->display_name);
		}
	}

	action parse_uri
	{
		if(curr_p_asserted_identity && !curr_p_asserted_identity->uri)
		{
			int len = (int)(p  - tag_start);
			curr_p_asserted_identity->uri = tsip_uri_parse(tag_start, (size_t)len);
		}
	}

	action add_p_asserted_identity
	{
		if(curr_p_asserted_identity)
		{
			tsk_list_push_back_data(hdr_p_asserted_identities, ((void**) &curr_p_asserted_identity));
		}
	}

	action eob
	{
	}

	
	URI = (scheme HCOLON any+)>tag %parse_uri;
	display_name = (( token LWS )+ | quoted_string)>tag %parse_display_name;
	my_name_addr = display_name? :>LAQUOT<: URI :>RAQUOT;
	
	PAssertedID_value = (my_name_addr | URI) >create_p_asserted_identity %add_p_asserted_identity;
	PAssertedID = "P-Asserted-Identity"i HCOLON PAssertedID_value ( COMMA PAssertedID_value )*;
	P_Asserted_Identity = PAssertedID;

	# Entry point
	main := P_Asserted_Identity :>CRLF @eob;

}%%

int tsip_header_P_Asserted_Identity_tostring(const void* header, tsk_buffer_t* output)
{
	if(header)
	{
		const tsip_header_P_Asserted_Identity_t *P_Asserted_Identity = header;
		int ret = 0;
		
		if(P_Asserted_Identity->display_name){ /* Display Name */
			tsk_buffer_appendEx(output, "\"%s\"", P_Asserted_Identity->display_name);
		}

		if(ret=tsip_uri_serialize(P_Asserted_Identity->uri, 1, 1, output)){ /* P_Asserted_Identity */
			return ret;
		}
		
		return ret;
	}

	return -1;
}

tsip_header_P_Asserted_Identities_L_t *tsip_header_P_Asserted_Identity_parse(const char *data, size_t size)
{
	int cs = 0;
	const char *p = data;
	const char *pe = p + size;
	const char *eof = pe;
	tsip_header_P_Asserted_Identities_L_t *hdr_p_asserted_identities = TSK_LIST_CREATE();
	
	const char *tag_start;
	tsip_header_P_Asserted_Identity_t *curr_p_asserted_identity = 0;

	%%write data;
	%%write init;
	%%write exec;
	
	if( cs < %%{ write first_final; }%% )
	{
		TSK_OBJECT_SAFE_FREE(curr_p_asserted_identity);
		TSK_OBJECT_SAFE_FREE(hdr_p_asserted_identities);
	}
	
	return hdr_p_asserted_identities;
}





//========================================================
//	P_Asserted_Identity header object definition
//

/**@ingroup tsip_header_P_Asserted_Identity_group
*/
static void* tsip_header_P_Asserted_Identity_create(void *self, va_list * app)
{
	tsip_header_P_Asserted_Identity_t *P_Asserted_Identity = self;
	if(P_Asserted_Identity)
	{
		TSIP_HEADER(P_Asserted_Identity)->type = tsip_htype_P_Asserted_Identity;
		TSIP_HEADER(P_Asserted_Identity)->tostring = tsip_header_P_Asserted_Identity_tostring;
	}
	else
	{
		TSK_DEBUG_ERROR("Failed to create new P_Asserted_Identity header.");
	}
	return self;
}

/**@ingroup tsip_header_P_Asserted_Identity_group
*/
static void* tsip_header_P_Asserted_Identity_destroy(void *self)
{
	tsip_header_P_Asserted_Identity_t *P_Asserted_Identity = self;
	if(P_Asserted_Identity)
	{
		TSK_FREE(P_Asserted_Identity->display_name);
		TSK_OBJECT_SAFE_FREE(P_Asserted_Identity->uri);

		TSK_OBJECT_SAFE_FREE(TSIP_HEADER_PARAMS(P_Asserted_Identity));
	}
	else TSK_DEBUG_ERROR("Null P_Asserted_Identity header.");

	return self;
}

static const tsk_object_def_t tsip_header_P_Asserted_Identity_def_s = 
{
	sizeof(tsip_header_P_Asserted_Identity_t),
	tsip_header_P_Asserted_Identity_create,
	tsip_header_P_Asserted_Identity_destroy,
	0
};
const void *tsip_header_P_Asserted_Identity_def_t = &tsip_header_P_Asserted_Identity_def_s;