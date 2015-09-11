#ifndef AudioReaderSDK_EMVPrivateTags_h
#define AudioReaderSDK_EMVPrivateTags_h

#define TAG_D3_TRACK1_MASKED 0xD3
#define TAG_D4_TRACK2_MASKED 0xD4



    /*
	 * Format: b
	 * Length: 2
	 */
	#define TAG_C1_PROCESSING_RESULT 0xC1

/*
 * Format: b
 * Length: 2
 */
#define TAG_CB_TRANSACTION_RESULT 0xCB

	/*
	 * Format: ans
	 * Length: 1 - 16
	 */
	#define TAG_C2_APPLICATION_LABEL_DEFAULT 0xC2
    
	/*
	 * Format: b
	 * Length: 2
	 */
	#define TAG_C3_EMV_LIB_RESULT 0xC3
	
	/*
	 * Format: b
	 * Length: 4
	 */
	#define TAG_C4_INITIATE_PROCESSING_FLAGS 0xC4
	
	/*
	 * Format: b
	 * Length: 1
	 */
	#define TAG_C5_SELECTED_INDEX 0xC5
	
	/*
	 * Format: b
	 * Length: 1
	 */
	#define TAG_C6_READER_STATE 0xC6
	
	/*
	 * Format: b
	 * Length: 2
	 */
	#define TAG_C7_ONLINE_AUTHORIZATION_PROCESSING_RESULT 0xC7
	
	/*
	 * Format: b
	 * Length: var
	 */
	#define TAG_C8_ISSUER_SCRIPT_RESULTS 0xC8
    
	/*
	 * Format: ?
	 * Length: ?
	 */
	#define TAG_C9_RFU 0xC9
	
	/*
	 * Format: b
	 * Length: 1
	 */
	#define TAG_CA_SERVICE_IDENTIFIER 0xCA
	
	/*
	 * Format: b
	 * Length: 1
	 */
	#define TAG_C1_TRANSACTION_RESULT 0xC1
	
	/*
	 * Format: b
	 * Length: 1
	 */
	#define TAG_CC_PAN_BASED_PROCESSING 0xCC
	
	/*
	 * Format: ?
	 * Length: ?
	 */
	#define TAG_CD_RFU 0xCD
	
	/*
	 * Format: ?
	 * Length: ?
	 */
	#define TAG_CE_RFU 0xCE
	
	/*
	 * Format: ?
	 * Length: ?
	 */
	#define TAG_CF_RFU 0xCF
	
	/*
	 * Format: b
	 * Length: 1
	 */
	#define TAG_DF10_CONFIGURATION_DATA_SET_VERSION_NUMBER 0xDF10
	
	/*
	 * Format: b
	 * Length: 2
	 */
	#define TAG_DF11_MAX_CONFIGURATION_MESSAGE_SIZE 0xDF11
	
	
	/*
	 * Format: b
	 * Length: var
	 */
	#define TAG_E1_LIST_OF_CANDIDATES 0xE1
	
	/*
	 * Format: b
	 * Length: var
	 */
	#define TAG_E2_BLOCKED_LIST 0xE2
	
	/*
	 * Format: b
	 * Length: var
	 */
	#define TAG_E3_ISSUER_SCRIPTS 0xE3
	
	/*
	 * Format: b
	 * Length: var
	 */
	#define TAG_E4_LIST_OF_CANDIDATES_ENTRY 0xE4
	


#endif
