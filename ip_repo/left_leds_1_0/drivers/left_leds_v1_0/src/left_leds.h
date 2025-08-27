
#ifndef LEFT_LEDS_H
#define LEFT_LEDS_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"

#define LEFT_LEDS_S00_AXI_SLV_REG0_OFFSET 0
#define LEFT_LEDS_S00_AXI_SLV_REG1_OFFSET 4
#define LEFT_LEDS_S00_AXI_SLV_REG2_OFFSET 8
#define LEFT_LEDS_S00_AXI_SLV_REG3_OFFSET 12


/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a LEFT_LEDS register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the LEFT_LEDSdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void LEFT_LEDS_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define LEFT_LEDS_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a LEFT_LEDS register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the LEFT_LEDS device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 LEFT_LEDS_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define LEFT_LEDS_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the LEFT_LEDS instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus LEFT_LEDS_Reg_SelfTest(void * baseaddr_p);

#endif // LEFT_LEDS_H
