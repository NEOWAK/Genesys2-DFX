#include <stdio.h>
#include <string.h>

#include "platform.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "microblaze_sleep.h"
#include "xhwicap.h"
#include "xhwicap_l.h"

#include "bitstream/pass_partial.h"
#include "bitstream/inv_partial.h"


//-------------------------------------------------
//--------------	 DEFINES 	-------------------

#define LEDS_BASEADDR              			XPAR_DYNAMIC_0_PASS_0_S00_AXI_BASEADDR

#define GPIO_BTN_DEVICE_ID                  XPAR_AXI_GPIO_0_DEVICE_ID
#define HWICAP_DEVICE_ID					XPAR_AXI_HWICAP_0_DEVICE_ID

#define GPIO_BTN_CHANEL_CTRL                1


#define MEM1		XPAR_MIG_7SERIES_0_BASEADDR + 0x02000000
#define MEM2		XPAR_MIG_7SERIES_0_BASEADDR + 0x03000000

// Offsets des registres slaves
#define SLV_REG0_OFFSET         0x00
#define SLV_REG1_OFFSET         0x04
#define SLV_REG2_OFFSET         0x08
#define SLV_REG3_OFFSET         0x0C

// Contrôle boutons
#define BTNC_MASK               0x01
#define BTNU_MASK               0x02
#define BTNL_MASK               0x04
#define BTNR_MASK               0x08
#define BTND_MASK               0x10


#define CONTROL_OFFSET						SLV_REG0_OFFSET
#define TRIGGER_OFFSET                      SLV_REG1_OFFSET


#define DEBOUNCE_DELAY          250


XGpio gpio_btn ;
XHwIcap hwicap;

int init_hwicap(void) ;
int load_partial_bitstream( u32* bitstream_data, u32 bitstream_len ) ;


int main()
{
	int status = 0 ;

	init_platform() ;

    status = XGpio_Initialize( &gpio_btn, GPIO_BTN_DEVICE_ID ) ;
	if ( status != XST_SUCCESS ) {
		xil_printf("Erreur: Impossible d'initialiser le GPIO_BTN\n\r");
		return XST_FAILURE;
    }

	else
		xil_printf("GPIO_BTN initialisé avec succès\n\r");

	status = init_hwicap();
	if (status != XST_SUCCESS) {
		xil_printf("Erreur: Impossible d'initialiser le HWICAP\n\r");
		return XST_FAILURE;
	}

	else
		xil_printf("HWICAP initialisé avec succès\n\r");


	memcpy( pass_partial_bin, MEM1, pass_partial_bin_len ) ;
	memcpy( inv_partial_bin, MEM2, inv_partial_bin_len ) ;



	Xil_Out32( LEDS_BASEADDR + CONTROL_OFFSET, 0xF0);
	Xil_Out32( LEDS_BASEADDR + TRIGGER_OFFSET, 0x00000001);
	xil_printf("LEFT enabled\n\r");
	//Xil_Out32( LEDS_BASEADDR + CONTROL_OFFSET, 0xF0);


	xil_printf("INIT OK\n\r") ;


	while(1){
		while( !(XGpio_DiscreteRead(&gpio_btn, GPIO_BTN_CHANEL_CTRL) & BTNC_MASK)  ) ;

		Xil_Out32( LEDS_BASEADDR + CONTROL_OFFSET, 0x00000000);
		Xil_Out32( LEDS_BASEADDR + TRIGGER_OFFSET, 0x00000000);
        xil_printf("LEFT disabled\n\r");

        status = load_partial_bitstream( (u32*)MEM2,inv_partial_bin_len ) ;
		if( status == XST_SUCCESS )
			xil_printf( "RIGHT dynamically config:\tSUCCESS\n\r" ) ;

		else {
			xil_printf( "RIGHT dynamically config:\tFAILLURE\n\r" ) ;
			return 1 ;
		}

		Xil_Out32( LEDS_BASEADDR + CONTROL_OFFSET, 0xF0);
		Xil_Out32( LEDS_BASEADDR + TRIGGER_OFFSET, 0x00000001);
		xil_printf("RIGHT enabled\n\r");

		// Attendre 250 ms
        MB_Sleep(DEBOUNCE_DELAY) ;


        //######################################


        while( !(XGpio_DiscreteRead(&gpio_btn, GPIO_BTN_CHANEL_CTRL) & BTNC_MASK)  ) ;

        Xil_Out32( LEDS_BASEADDR + CONTROL_OFFSET, 0x00000000);
		Xil_Out32( LEDS_BASEADDR + TRIGGER_OFFSET, 0x00000000);
		xil_printf("RIGHT disabled\n\r");

		status = load_partial_bitstream( (u32*)MEM1,pass_partial_bin_len ) ;
		if( status == XST_SUCCESS )
			xil_printf( "LEFT dynamically config:\tSUCCESS\n\r" ) ;

		else {
			xil_printf( "LEFT dynamically config:\tFAILLURE\n\r" ) ;
			return 1 ;
		}

		Xil_Out32( LEDS_BASEADDR + CONTROL_OFFSET, 0xF0);
		Xil_Out32( LEDS_BASEADDR + TRIGGER_OFFSET, 0x00000001);
		xil_printf("LEFT enabled\n\r");

		// Attendre 250 ms
		MB_Sleep(DEBOUNCE_DELAY) ;
	}

	cleanup_platform() ;

    return 0;
}


int init_hwicap(void)
{
    int status;
    XHwIcap_Config *config_ptr;

    // Obtenir la configuration du HWICAP
    config_ptr = XHwIcap_LookupConfig(HWICAP_DEVICE_ID);
    if (config_ptr == NULL) {
        xil_printf("Erreur: Configuration HWICAP introuvable\n\r");
        return XST_FAILURE;
    }

    // Initialiser le HWICAP
    status = XHwIcap_CfgInitialize(&hwicap, config_ptr, config_ptr->BaseAddress);
    if (status != XST_SUCCESS) {
        xil_printf("Erreur: Initialisation HWICAP échouée\n\r");
        return XST_FAILURE;
    }

    // Effectuer un auto-test
    status = XHwIcap_SelfTest(&hwicap);
    if (status != XST_SUCCESS) {
        xil_printf("Erreur: Auto-test HWICAP échoué\n\r");
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}



int load_partial_bitstream( u32* bitstream_data, u32 bitstream_len )
{
	int status = 0 ;

	if( !(XHwIcap_GetStatusReg(&hwicap) & XHI_SR_DONE_MASK) ) {
		xil_printf( "HWICAP not ready\n\r" ) ;
		while( !(XHwIcap_GetStatusReg(&hwicap) & XHI_SR_DONE_MASK) ) ;
		xil_printf( "HWICAP ready\n\r" ) ;
	}

	status = XHwIcap_DeviceWrite(&hwicap, bitstream_data, bitstream_len/4 );
	if (status != XST_SUCCESS) {
		xil_printf("Erreur: Écriture du bitstream échouée\n\r");
		return XST_FAILURE;
	}

	for( status=0 ; status < 3000  &&  !(XHwIcap_GetStatusReg(&hwicap) & XHI_SR_DONE_MASK) ; status++ )
		MB_Sleep(100) ;

	if ( XHwIcap_GetStatusReg(&hwicap) & XHI_SR_CFGERR_N_MASK) {
	    xil_printf("Erreur CRC détectée:\t%d\n\r", XHwIcap_GetStatusReg(&hwicap) );
	    return XST_FAILURE;
	}

	xil_printf("status register:\t%d\n\r", XHwIcap_GetStatusReg(&hwicap) );

	if( status >= 3000 ){
		xil_printf("Erreur: Timeout lors de la reconfiguration\n\r");
		return XST_FAILURE;
	}

	return XST_SUCCESS ;
}
