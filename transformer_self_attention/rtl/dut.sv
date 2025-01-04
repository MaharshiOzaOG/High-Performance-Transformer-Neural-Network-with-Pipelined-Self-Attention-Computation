//---------------------------------------------------------------------------
// DUT - Mini project 
//---------------------------------------------------------------------------
`include "common.vh"

module MyDesign(
//---------------------------------------------------------------------------
//System signals
  input wire reset_n                      ,  
  input wire clk                          ,

//---------------------------------------------------------------------------
//Control signals
  input wire dut_valid                    , 
  output wire dut_ready                   ,

//---------------------------------------------------------------------------
//input SRAM interface
  output wire                           dut__tb__sram_input_write_enable  ,
  output wire [`SRAM_ADDR_RANGE     ]   dut__tb__sram_input_write_address ,
  output wire [`SRAM_DATA_RANGE     ]   dut__tb__sram_input_write_data    ,
  output wire [`SRAM_ADDR_RANGE     ]   dut__tb__sram_input_read_address  , 
  input  wire [`SRAM_DATA_RANGE     ]   tb__dut__sram_input_read_data     ,     

//weight SRAM interface
  output wire                           dut__tb__sram_weight_write_enable  ,
  output wire [`SRAM_ADDR_RANGE     ]   dut__tb__sram_weight_write_address ,
  output wire [`SRAM_DATA_RANGE     ]   dut__tb__sram_weight_write_data    ,
  output wire [`SRAM_ADDR_RANGE     ]   dut__tb__sram_weight_read_address  , 
  input  wire [`SRAM_DATA_RANGE     ]   tb__dut__sram_weight_read_data     ,     

//result SRAM interface
  output wire                           dut__tb__sram_result_write_enable  ,
  output wire [`SRAM_ADDR_RANGE     ]   dut__tb__sram_result_write_address ,
  output wire [`SRAM_DATA_RANGE     ]   dut__tb__sram_result_write_data    ,
  output wire [`SRAM_ADDR_RANGE     ]   dut__tb__sram_result_read_address  , 
  input  wire [`SRAM_DATA_RANGE     ]   tb__dut__sram_result_read_data     ,
  
  //result SRAM interface
  output wire                           dut__tb__sram_scratchpad_write_enable  ,
  output wire [`SRAM_ADDR_RANGE     ]   dut__tb__sram_scratchpad_write_address ,
  output wire [`SRAM_DATA_RANGE     ]   dut__tb__sram_scratchpad_write_data    ,
  output wire [`SRAM_ADDR_RANGE     ]   dut__tb__sram_scratchpad_read_address  , 
  input  wire [`SRAM_DATA_RANGE     ]   tb__dut__sram_scratchpad_read_data          

);

//##############################################################################

//q_state_output SRAM interface (A)
  reg                           dut__tb__sram_input_write_enable_R  ;
  reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_input_write_address_R ;
  reg [`SRAM_DATA_RANGE     ]   dut__tb__sram_input_write_data_R    ;
  reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_input_read_address_R  ; 
																	;
  reg [`SRAM_DATA_RANGE     ]   tb__dut__sram_input_read_data_R  	; 		//data_in_A
  wire [`SRAM_DATA_RANGE     ]   accum_result  	; 		//data_in_A
  wire [`SRAM_DATA_RANGE     ]   MATRIX_MUL  	; 		//data_in_A
  reg [`SRAM_DATA_RANGE     ]   mac_result_z  	; 		//data_in_A
  //wire [`SRAM_ADDR_RANGE     ]   tb__dut__sram_input_read_data_wire  	; 		//data_in_A
   
   wire [15:0] V_start_addr_wire;
   reg [15:0] V_start_addr_R;
   
  //This is the temp wire ihave created for A and B. Capturing input data frm S-RAM after 1 flop. 
  wire [`SRAM_DATA_RANGE     ]	temp_tb__dut__sram_input_read_data ;
  wire [`SRAM_DATA_RANGE     ]	temp_tb__dut__sram_weight_read_data;
  wire [`SRAM_DATA_RANGE     ]	temp_tb__dut__sram_result_read_data;
  wire [`SRAM_DATA_RANGE     ]	temp_tb__dut__sram_scratchpad_read_data;

//weight SRAM interface (B)
  reg                           dut__tb__sram_weight_write_enable_R  ;
  reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_weight_write_address_R ;
  reg [`SRAM_DATA_RANGE     ]   dut__tb__sram_weight_write_data_R    ;
  reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_weight_read_address_R  ; 
  
  reg [`SRAM_DATA_RANGE     ]   tb__dut__sram_weight_read_data_R	 ; 		//data_in_B
   

//result SRAM interface (RESULT)
  reg                           dut__tb__sram_result_write_enable_R  ;
  reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_result_write_address_R ;
  reg [`SRAM_DATA_RANGE     ]   dut__tb__sram_result_write_data_R    ;
  reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_result_read_address_R  ; 
  
  reg [`SRAM_DATA_RANGE     ]   tb__dut__sram_result_read_data_R	 ; 		//data_in_result
  reg compute_complete;


//result SRAM interface (SCRATCH)
  reg                           dut__tb__sram_scratchpad_write_enable_R  ;
  reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_scratchpad_write_address_R ;
  reg [`SRAM_DATA_RANGE     ]   dut__tb__sram_scratchpad_write_data_R    ;
  reg [`SRAM_ADDR_RANGE     ]   dut__tb__sram_scratchpad_read_address_R  ; 
											 
  reg [`SRAM_DATA_RANGE     ]   tb__dut__sram_scratchpad_read_data_R	 ; 		//data_in_scratch
  
// Local data path variables 
  reg [/* `SRAM_DATA_WIDTH-1 */15:0]      SRAM_A_ROW_size              ;
  reg [/* `SRAM_DATA_WIDTH-1 */15:0]      SRAM_A_COL_size              ;
  reg [/* `SRAM_DATA_WIDTH-1 */15:0]      SRAM_B_ROW_size              ;
  reg [/* `SRAM_DATA_WIDTH-1 */15:0]      SRAM_B_COL_size              ;
  
  reg [`SRAM_DATA_WIDTH-1:0]      A_row_count              ;
  //wire [`SRAM_DATA_WIDTH-1:0]      A_row_count_R              ;
  //reg [`SRAM_DATA_WIDTH-1:0]      A_col_size              ;
  reg [15:0]      B_row_count              ;
  wire [15:0]      B_row_count_wire              ;
  reg [`SRAM_DATA_WIDTH-1:0]      B_col_count              ;
  
  reg [5:0] SYS_count_R;
  wire [5:0] SYS_count;

 /*  reg [`SRAM_ADDR_RANGE]	SRAM_A_row_sel		;	
  reg [`SRAM_ADDR_RANGE]	SRAM_A_col_sel		;	
  reg [`SRAM_ADDR_RANGE]	SRAM_B_row_sel		;	
  reg [`SRAM_ADDR_RANGE]	SRAM_B_col_sel		;	 */
	
  
  
  
  
  
  
  

// This is test sub for the DW_fp_add, do not change any of the inputs to the
// param list for the DW_fp_add, you will only need one DW_fp_add

// synopsys translate_off
  shortreal test_val;
  assign test_val = $bitstoshortreal(sum_r); 
  // This is a helper val for seeing the 32bit flaot value, you can repicate 
  // this for any signal, but keep it between the translate_off and
  // translate_on 
// synopsys translate_on

  wire  [31:0] sum_w;   // Result from FP_add
  reg   [31:0] sum_r;   // Input A of the FP_add 
  reg   [31:0] in;      // Input B of the FP_add
  wire  [7:0] status;   // Status register of the FP_add module is IGNORED

  //wire []accum_result;

// Local control path variables
/*   reg                           set_dut_ready             ;
  reg                           get_array_size            ;
  reg [1:0]                     read_addr_sel             ;
  reg                           all_element_read_completed;
  reg                           compute_accumulation      ;
  reg                           save_array_size           ; */
  
  reg							 set_dut_ready			  ;
  reg							 input_write_enable_sel	  ;
  reg							 weight_write_enable_sel  ;
  
  reg  [3:0]                     read_A_addr_sel          ;	//()
  reg  [2:0]                     read_B_addr_sel          ;	//()
  reg  [3:0]                     read_RESULT_addr_sel          ;	//()
  reg  [2:0]                     read_SCRATCH_addr_sel          ;	//()
  //reg                         	 accum_result_sel         ;	//()
  reg  [2:0]                     convol_result_sel        ;	//()
 (* keep = "true" *) reg  [2:0]                     write_RESULT_enable_sel       ;	//(CWES)
  reg  [2:0]                     write_RESULT_addr_sel         ;	//()
  (* keep = "true" *) reg  [2:0]                     write_RESULT_data_sel         ;	//()
  
  reg  [1:0]                     write_SCRATCH_enable_sel       ;	//(CWES)		//from 3 to 2 latch
  reg  [3:0]                     write_SCRATCH_addr_sel         ;	//()
  reg  [3:0]                     write_SCRATCH_data_sel         ;	//()
  
  reg  [2:0]                     A_row_count_sel          ;	// A_row = C_row
  reg  [2:0]                     B_row_count_sel          ;	// B_row = A_col
  reg  [2:0]                     B_col_count_sel          ;	// B_col = C_col
  
  reg  [`SRAM_DATA_RANGE     ]                     convol_result          ;	// B_col = C_col
  //wire [:0]						wire_convol_result_2_C_write_data_sel;
  reg  [1:0]                     SRAM_A_row_sel;
  reg  [1:0]                     SRAM_A_col_sel;
  reg  [1:0]                     SRAM_B_row_sel;
  reg  [1:0]                     SRAM_B_col_sel;
  reg  [2:0]					SYS_count_sel;
  reg  [2:0]					read_A_MUX_sel;
  reg  [2:0]					read_B_MUX_sel;
  reg  [2:0]					V_start_addr_sel;
								
//---------------------------------------------------------------------------
//FSM registers for q_input_state
parameter [5:0]
/* IDLE		=	6'b00000,				  //State - -1
S0			=	6'b10000,                 //State - 0	(A_B sel = 0 )
S1			=	6'b00001,                 //State - 1 (sending addr_0 to SRAM, will get data {SRAM_data_A_B_0} in the nxt cycle) 
S2			=	6'b00010,                 //State - 2 (SRAM_data_A_B_0 arrived to DUT in this cycle -> for processing will happen this cycle)
S3			=	6'b00011,                 //State - 3 (SRAM_data_A_B_1 arrived to DUT in this cycle -> for processing will happen this cycle)
S4			=	6'b00100,                 //State - 4 (convolv)
S5			=	6'b00101,
S6			=	6'b00110,
S7			=	6'b00111,
S8			=	6'b01000,
S9			=	6'b01001,
S10			=	6'b01010,
S11			=	6'b01011,
S12			=	6'b01100,
S7_str		=	6'b11011,
S8_str		=	6'b11100,
S10_str		=	6'b11110,
S5_str		=	6'b11001,
MATRIX_DONE_write_the_last_value		=	5'b11111; */
IDLE						= 6'd0		,
S0_Q                        = 6'd1      ,
S1_Q                        = 6'd2      ,
S2_Q                        = 6'd3      ,
S3_Q                        = 6'd4      ,
S4_Q                        = 6'd5      ,
S5_Q                        = 6'd6      ,
S5_str_Q                    = 6'd7      ,
S6_Q                        = 6'd8      ,
S7_Q                        = 6'd9      ,
S8_Q                        = 6'd10     ,
S9_Q                        = 6'd11     ,
S8_str_Q                    = 6'd12     ,
S10_Q                       = 6'd13     ,
S10_str_Q                   = 6'd14     ,
S11_Q                       = 6'd15     ,
S7_str_Q                    = 6'd16     ,
//---------                 
//K                           
S7_K                        = 6'd17,
S8_K                        = 6'd18,
S9_K                        = 6'd19,
S8_str_K                    = 6'd20,
S10_K                       = 6'd21,
S10_str_K                   = 6'd22,
S11_K                       = 6'd23,
S7_str_K                    = 6'd24,
//---------                 
//V                           
S7_V                        = 6'd25,
S8_V                        = 6'd26,
S9_V                        = 6'd27,
S8_str_V                    = 6'd28,
S10_V                       = 6'd29,
S10_str_V                   = 6'd30,
S11_V                       = 6'd31,
S7_str_V                    = 6'd32,
//---------                 
//S                           
S7_S                        = 6'd33,
S8_S                        = 6'd34,
S9_S                        = 6'd35,
S8_str_S                    = 6'd36,
S10_S                       = 6'd37,
S10_str_S                   = 6'd38,
S11_S                       = 6'd39,
S7_str_S                    = 6'd40,
//----------                
//T                           
S8_T                        = 6'd41,
SX                          = 6'd42,
SA                          = 6'd43,
SBB                         = 6'd44,
SY                          = 6'd45,
SC                          = 6'd46,
SD                          = 6'd47,
S_transpose_over            = 6'd48,
//---------                 
//Z                           
S7_Z                        = 6'd49,
S8_Z                        = 6'd50,
S9_Z                        = 6'd51,
S8_str_Z                    = 6'd52,
S10_Z                       = 6'd53,
S10_str_Z                   = 6'd54,
S11_Z                       = 6'd55,
S7_str_Z                    = 6'd56,
MATRIX_DONE_write_the_last_value		=	6'd60;
//---------

reg [5:0] current_state, next_state;


// -------------------- Control path ------------------------
always @(posedge clk) begin 
  if(!reset_n) begin // Synchronous reset
    current_state <= IDLE;
  end else begin
    current_state <= next_state;
  end
end

always @(*) begin
  casex (current_state)

    IDLE                    : begin
								set_dut_ready           = 		1'b1;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd0;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd0;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd0;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd0;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd0;
								B_row_count_sel                     =	3'd0;
								B_col_count_sel                     =	3'd0;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
							
								/* input_write_enable_sel	=	1'bx;
								weight_write_enable_sel =	1'bx;
								
								A_row_count_sel   		=		2'b00;
								B_row_count_sel   		=		2'b00;
								B_col_count_sel   		=		2'b00;
								
									read_A_addr_sel   		=		2'b00;
									read_B_addr_sel   		=		2'b00;
									//accum_result_sel  		=		1'b0 ;
									convol_result_sel 		=		2'b00;
									write_C_enable_sel		=		2'b00;
									write_C_addr_sel  		=       2'b00;
									write_C_data_sel  		=       2'b00;
								
								//set_dut_ready           = 		1'b1;
								
								
								SRAM_A_row_sel			=		2'bxx;
								SRAM_A_col_sel          =		2'bxx;
								SRAM_B_row_sel          =		2'bxx;
								SRAM_B_col_sel          =		2'bxx; */
								
								if (dut_valid) 	begin
									next_state = S0_Q;
									set_dut_ready = 1'b0;
								end
								else begin
									set_dut_ready = 1'b1;
									next_state = IDLE;
								end
							  end

    S0_Q                    : begin
								/* input_write_enable_sel	=	1'b0;
								weight_write_enable_sel =	1'b0;
								
								A_row_count_sel   		=		2'bxx;
								B_row_count_sel   		=		2'bxx;
								B_col_count_sel   		=		2'bxx;
								
								read_A_addr_sel   		=		2'b00;
								read_B_addr_sel   		=		2'b00;
								//accum_result_sel  		=		1'bx ;
								convol_result_sel 		=		2'bxx;
								write_C_enable_sel		=		2'bxx;
								write_C_addr_sel  		=       2'b00;
								write_C_data_sel  		=       2'b00;
																										
								set_dut_ready           = 		1'b0;
								SRAM_A_row_sel			=		2'b01;
								SRAM_A_col_sel          =		2'b01;
								SRAM_B_row_sel          =		2'b01;
								SRAM_B_col_sel          =		2'b01; */
								
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd0;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd0;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd0;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd1;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'dx;
								
								
								SRAM_A_row_sel			=		2'b01;
                                SRAM_A_col_sel          =		2'b01;
                                SRAM_B_row_sel          =		2'b01;
                                SRAM_B_col_sel          =		2'b01;
								next_state = S1_Q;
							end
								
	S1_Q                    : begin
								//input_write_enable_sel	=	1'b0;
								//weight_write_enable_sel =	1'b0;
								//
								//A_row_count_sel   		=		2'b00;
								//B_row_count_sel   		=		2'b00;
								//B_col_count_sel   		=		2'b00;
								//
								//read_A_addr_sel   		=		2'b01;
								//read_B_addr_sel   		=		2'b01;
								////accum_result_sel  		=		1'bx ;
								//convol_result_sel 		=		2'bxx;
								//write_C_enable_sel		=		2'b00;
								//write_C_addr_sel  		=       2'bxx;
								//write_C_data_sel  		=       2'bxx;
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd1;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd1;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd0;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd0;
								B_row_count_sel                     =	3'd0;
								B_col_count_sel                     =	3'd0;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
																																		
								SRAM_A_row_sel			=		2'b01;
                                SRAM_A_col_sel          =		2'b01;
                                SRAM_B_row_sel          =		2'b01;
								SRAM_B_col_sel          =		2'b01;
								
								next_state = S2_Q;
							end
							
	S2_Q                    : begin
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd1;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd1;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
								
								SRAM_A_row_sel			=		2'b01;
                                SRAM_A_col_sel          =		2'b01;
                                SRAM_B_row_sel          =		2'b01;
                                SRAM_B_col_sel          =		2'b01;

								next_state = S3_Q;
							end
							
	S3_Q                    : begin
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								if((SRAM_A_COL_size <= 2) && (B_row_count <= 2))	begin
									read_A_addr_sel           		=	3'd2;
									read_B_addr_sel          		=	3'd2;
									B_row_count_sel                 =	3'd2;
									B_col_count_sel                 =	3'd2;
								
								end
								else begin
									read_A_addr_sel            		=	3'd1;
									read_B_addr_sel           		=	3'd1;
									B_row_count_sel                	=	3'd1;
									B_col_count_sel                	=	3'd1;
								end
								
								read_RESULT_addr_sel                =	3'd0; //or X
								//read_A_addr_sel                     =	1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								//read_B_addr_sel                     =	1;
								read_SCRATCH_addr_sel               =	3'd0; //or X
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								//B_row_count_sel                     =	1;
								//B_col_count_sel                     =	1;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
								
								
								set_dut_ready           = 		1'b0;
								SRAM_A_row_sel			=		2'b01;
                                SRAM_A_col_sel          =		2'b01;
                                SRAM_B_row_sel          =		2'b01;
                                SRAM_B_col_sel          =		2'b01;
								
								if		((SRAM_A_COL_size == 3) && (B_row_count == 3))	next_state = S5_Q;
								else if ((SRAM_A_COL_size == 2) && (B_row_count == 2))	next_state = S5_str_Q;
								else if ((SRAM_A_COL_size == 1) && (B_row_count == 1))	next_state = S6_Q;
								else 													next_state = S4_Q;
							end
								
													
	S4_Q                    : begin
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd1;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								/* 
								if	(SRAM_A_COL_size == 2'b11))	B_row_count_sel   	=	2'b10;		//Multiplication Corner-case size = 3
								else							B_row_count_sel   	=	2'b01; */
								
								B_row_count_sel                     =	3'd1;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd1;
								
								
								set_dut_ready           = 		1'b0;
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								
								if(B_row_count_wire == (SRAM_A_COL_size - 1'd1)) begin
									next_state = S5_Q;
								end
								else	next_state = S4_Q;		//for latch 1.1 NS
								
								
							end
							
	S5_Q                    : begin
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd1;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								next_state 				=		S5_str_Q;
							end
							
							
	S5_str_Q                 : begin
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd1;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;						
								
								next_state = S6_Q;
							end
							
							
					
							
							
							
	S6_Q                    : begin
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;							
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd1;
								write_RESULT_addr_sel          =	3'd0;
								write_RESULT_data_sel          =	3'd1;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
								SRAM_A_row_sel			=		2'b00;
									SRAM_A_col_sel          =		2'b00;
									SRAM_B_row_sel          =		2'b00;
									SRAM_B_col_sel          =		2'b00;
								
								next_state = S7_Q;
							end
								
	S8_Q                  : begin
								 if(A_row_count == (SRAM_A_ROW_size + 1) &&  (SYS_count == 1)) 	begin
									set_dut_ready           = 		1'b0;
								
									input_write_enable_sel	=	1'b0;// Change the name input
									weight_write_enable_sel =	1'b0;// Change the name weight
								
									SYS_count_sel						=	3'd1;
									write_SCRATCH_enable_sel       =	2'd0;
									write_SCRATCH_addr_sel         =	3'd0;
									write_SCRATCH_data_sel         =	3'd0;
																				
									read_RESULT_addr_sel                =	3'd0;
									read_A_addr_sel                     =	3'd4;
									read_A_MUX_sel                      =	3'd0;
																				
									read_B_MUX_sel                      =	3'd0;
									read_B_addr_sel                     =	3'd1;
									read_SCRATCH_addr_sel               =	3'd0;
																			
									write_RESULT_enable_sel        =	3'd0;
									write_RESULT_addr_sel          =	3'd2;
									write_RESULT_data_sel          =	3'd0;
																			
									A_row_count_sel                     =	3'd0;
									B_row_count_sel                     =	3'd2;
									B_col_count_sel                     =	3'd2;
																		
									V_start_addr_sel                    =	3'd3;
																		
									convol_result_sel                   =	3'd0;
								
								
									SRAM_A_row_sel			=		2'b00;
									SRAM_A_col_sel          =		2'b00;
									SRAM_B_row_sel          =		2'b00;
									SRAM_B_col_sel          =		2'b00;
						
									next_state = S8_K; // Meaning start with 'V' computation NEXT.
									//next_state = MATRIX_DONE_write_the_last_value;
								end
								else begin
								
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd1;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd1;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								next_state	= S9_Q;
								end
							end								
									
S9_Q                    : begin
																																			
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								if((SRAM_A_COL_size <= 2) && (B_row_count <= 2))	begin
									read_A_addr_sel           		=	3'd2;
									read_B_addr_sel          		=	3'd2;
									B_row_count_sel                 =	3'd2;
									B_col_count_sel                 =	3'd2;
								
								end
								else begin
									read_A_addr_sel            		=	3'd1;
									read_B_addr_sel           		=	3'd1;
									B_row_count_sel                	=	3'd1;
									B_col_count_sel                	=	3'd1;
								end
								
								read_RESULT_addr_sel                =	3'd0; //or X
								//read_A_addr_sel                     =	1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								//read_B_addr_sel                     =	1;
								read_SCRATCH_addr_sel               =	3'd0; //or X
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								//B_row_count_sel                     =	1;
								//B_col_count_sel                     =	1;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
								
								
								set_dut_ready           = 		1'b0;
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								if		((SRAM_A_COL_size == 3) && (B_row_count == 3))	next_state = S10_Q;
								else if ((SRAM_A_COL_size == 2) && (B_row_count == 2))	next_state = S10_str_Q;
								else if ((SRAM_A_COL_size == 1) && (B_row_count == 1))	next_state = S11_Q;
								else 													next_state = S8_str_Q;
							end
									
	S8_str_Q                : begin
								
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd1;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								/* 
								if	(SRAM_A_COL_size == 2'b11))	B_row_count_sel   	=	2'b10;		//Multiplication Corner-case size = 3
								else							B_row_count_sel   	=	2'b01; */
								
								B_row_count_sel                     =	3'd1;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd1;
								
								
								set_dut_ready           = 		1'b0;
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								
								/* if	(SRAM_A_COL_size == 2'b11))		
									begin
										if((B_row_count == (SRAM_A_COL_size ))
											begin
												next_state = S16_str;
											end
									end
								else begin	 */
									if		(B_row_count < (SRAM_A_COL_size - 1'b1))	next_state = S8_str_K;				//I think i made a mistake here
									else if (B_row_count == (SRAM_A_COL_size - 1'b1))	next_state = S10_Q;
									else 												next_state = S8_str_Q;				//latch 1.2 NS
								//end
								
							end
								
													
	S10_Q                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd1;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S10_str_Q;
							end								
									
									
									
	S10_str_Q                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd1;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S11_Q;	//need to adopt S11_str
							end																	
									
									
									
									
	S11_Q               : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;							
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd1;
								write_RESULT_addr_sel          =	3'd1;
								write_RESULT_data_sel          =	3'd1;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								if (B_col_count < (SRAM_B_COL_size * SRAM_A_COL_size) && (B_row_count == SRAM_A_COL_size) &&  (A_row_count < (SRAM_A_ROW_size + 1)))			next_state = S7_Q;
								else if (B_col_count == (SRAM_B_COL_size * SRAM_A_COL_size) && (B_row_count == SRAM_A_COL_size) && (A_row_count < (SRAM_A_ROW_size + 1)))		next_state = S7_str_Q;		//latch 1.3 NS	(changed from if to else if)
								else 																																			next_state = S11_Q;			//latch 1.4 NS	(else)
							end										
									
									
	S7_Q                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd3;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd1;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd3;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S8_Q;
							end																	
									
									
		S7_str_Q                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
					if (A_row_count == SRAM_A_ROW_size)	read_B_addr_sel     =	3'd2;
								else	read_B_addr_sel                     =	3'd3; //or if it is the last case then it should be 2
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd1;
								B_row_count_sel                     =	3'd3;
								B_col_count_sel                     =	3'd3;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S8_Q;
							end		
//----------------------------------------Q-OVER---------------------------------------------------------------------------					
//--------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------					
//-----------------------------------------K-START---------------------------------------------------------------------------------


S8_K                  : 	begin
								 if(A_row_count == (SRAM_A_ROW_size + 1) &&  (SYS_count == 2)) 	begin
									set_dut_ready           = 		1'b0;
								
									input_write_enable_sel	=	1'b0;// Change the name input
									weight_write_enable_sel =	1'b0;// Change the name weight
								
									SYS_count_sel						=	3'd1;
									write_SCRATCH_enable_sel       =	2'd0;
									write_SCRATCH_addr_sel         =	3'd0;
									write_SCRATCH_data_sel         =	3'd0;
																				
									read_RESULT_addr_sel                =	3'd0;
									read_A_addr_sel                     =	3'd4;
									read_A_MUX_sel                      =	3'd0;
																				
									read_B_MUX_sel                      =	3'd0;
									read_B_addr_sel                     =	3'd1;
									read_SCRATCH_addr_sel               =	3'd0;
																			
									write_RESULT_enable_sel        =	3'd0;
									write_RESULT_addr_sel          =	3'd2;
									write_RESULT_data_sel          =	3'd0;
																			
									A_row_count_sel                     =	3'd0;
									B_row_count_sel                     =	3'd2;
									B_col_count_sel                     =	3'd2;
																		
									V_start_addr_sel                    =	3'd3;
																		
									convol_result_sel                   =	3'd0;
								
								
									SRAM_A_row_sel			=		2'b00;
									SRAM_A_col_sel          =		2'b00;
									SRAM_B_row_sel          =		2'b00;
									SRAM_B_col_sel          =		2'b00;
						
									next_state = S8_V; // Meaning start with 'V' computation NEXT.
									//next_state = MATRIX_DONE_write_the_last_value;
								end
								else begin
								
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd1;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd1;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								next_state	= S9_K;
								end
							end								
									
S9_K                    : begin
																																			
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								if((SRAM_A_COL_size <= 2) && (B_row_count <= 2))	begin
									read_A_addr_sel           		=	3'd2;
									read_B_addr_sel          		=	3'd2;
									B_row_count_sel                 =	3'd2;
									B_col_count_sel                 =	3'd2;
								
								end
								else begin
									read_A_addr_sel            		=	3'd1;
									read_B_addr_sel           		=	3'd1;
									B_row_count_sel                	=	3'd1;
									B_col_count_sel                	=	3'd1;
								end
								
								read_RESULT_addr_sel                =	3'd0; //or X
								//read_A_addr_sel                     =	1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								//read_B_addr_sel                     =	1;
								read_SCRATCH_addr_sel               =	3'd0; //or X
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								//B_row_count_sel                     =	1;
								//B_col_count_sel                     =	1;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
								
								
								set_dut_ready           = 		1'b0;
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								if		((SRAM_A_COL_size == 3) && (B_row_count == 3))	next_state = S10_K;
								else if ((SRAM_A_COL_size == 2) && (B_row_count == 2))	next_state = S10_str_K;
								else if ((SRAM_A_COL_size == 1) && (B_row_count == 1))	next_state = S11_K;
								else 													next_state = S8_str_K;		//latch 1.5 (else)
							end
									
	S8_str_K                : begin
								
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd1;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								/* 
								if	(SRAM_A_COL_size == 2'b11))	B_row_count_sel   	=	2'b10;		//Multiplication Corner-case size = 3
								else							B_row_count_sel   	=	2'b01; */
								
								B_row_count_sel                     =	3'd1;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd1;
								
								
								set_dut_ready           = 		1'b0;
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								
								/* if	(SRAM_A_COL_size == 2'b11))		
									begin
										if((B_row_count == (SRAM_A_COL_size ))
											begin
												next_state = S16_str;
											end
									end
								else begin	 */
									if		(B_row_count < (SRAM_A_COL_size - 1'b1))	next_state = S8_str_K;
									else if (B_row_count == (SRAM_A_COL_size - 1'b1))	next_state = S10_K;
									else 												next_state = S8_str_K;	//latch 1.6 (else)
								//end
								
							end
								
													
	S10_K                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd1;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S10_str_K;
							end								
									
									
									
	S10_str_K                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd1;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S11_K;	//need to adopt S11_str
							end																	
									
									
									
									
	S11_K               : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd1;
								if((A_row_count == 1) && (B_col_count == SRAM_A_COL_size))	write_SCRATCH_addr_sel         =	3'd0; 
								else														write_SCRATCH_addr_sel         =	3'd1; //firsttime = 0 rest of the time ==1
								 
								
								write_SCRATCH_data_sel         =	3'd1;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd1;
								write_RESULT_addr_sel          =	3'd1;
								write_RESULT_data_sel          =	3'd1;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								if (B_col_count < (SRAM_B_COL_size * SRAM_A_COL_size) && (B_row_count == SRAM_A_COL_size) &&  (A_row_count < (SRAM_A_ROW_size + 1)))			next_state = S7_K;
								else if (B_col_count == (SRAM_B_COL_size * SRAM_A_COL_size) && (B_row_count == SRAM_A_COL_size) && (A_row_count < (SRAM_A_ROW_size + 1)))		next_state = S7_str_K;		//if if
								else 																																			next_state = S11_K;			//latch 1.6 (else)
								
							end										
									
									
	S7_K                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd3;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd1;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd3;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S8_K;
							end																	
									
									
		S7_str_K                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd2;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
					if (A_row_count == SRAM_A_ROW_size)	read_B_addr_sel     =	3'd2;
								else	read_B_addr_sel                     =	3'd3; //or if it is the last case then it should be 2
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd1;
								B_row_count_sel                     =	3'd3;
								B_col_count_sel                     =	3'd3;
																		
								V_start_addr_sel                    =	3'd0;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S8_K;
							end	
							
							
//----------------------------------------K-OVER---------------------------------------------------------------------------					
//--------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------					
//-----------------------------------------V-START---------------------------------------------------------------------------------


S8_V                  : begin
								 if(A_row_count == (SRAM_A_ROW_size + 1) &&  (SYS_count == 3)) 	
								begin
									set_dut_ready           = 		1'b0;
								
									input_write_enable_sel	=	1'b0;// Change the name input
									weight_write_enable_sel =	1'b0;// Change the name weight
								
									SYS_count_sel						=	3'd1;
									write_SCRATCH_enable_sel       =	2'd0;
									write_SCRATCH_addr_sel         =	3'd0;
									write_SCRATCH_data_sel         =	3'd0;
																				
									read_RESULT_addr_sel                =	3'd0;
									read_A_addr_sel                     =	3'd4;
									read_A_MUX_sel                      =	3'd0;
																				
									read_B_MUX_sel                      =	3'd0;
									read_B_addr_sel                     =	3'd1;
									read_SCRATCH_addr_sel               =	3'd0;
																			
									write_RESULT_enable_sel        =	3'd0;
									write_RESULT_addr_sel          =	3'd2;
									write_RESULT_data_sel          =	3'd0;
																			
									A_row_count_sel                     =	3'd0;
									B_row_count_sel                     =	3'd2;
									B_col_count_sel                     =	3'd2;
																		
									V_start_addr_sel                    =	3'd2;
																		
									convol_result_sel                   =	3'd0;
								
								
									SRAM_A_row_sel			=		2'b00;
									SRAM_A_col_sel          =		2'b00;
									SRAM_B_row_sel          =		2'b00;
									SRAM_B_col_sel          =		2'b00;
						
									next_state = S8_S; // Meaning start with 'V' computation NEXT.
									//next_state = MATRIX_DONE_write_the_last_value;
								end
								else begin
								
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd1;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd1;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd0;
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								next_state	= S9_V;
								end
							end
							
							
							
S9_V                    : begin
																																			
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;//before 2
								write_SCRATCH_data_sel         =	3'd0;
								
								if((SRAM_A_COL_size <= 2) && (B_row_count <= 2))	begin
									read_A_addr_sel           		=	3'd2;
									read_B_addr_sel          		=	3'd2;
									B_row_count_sel                 =	3'd2;
									B_col_count_sel                 =	3'd2;
								
								end
								else begin
									read_A_addr_sel            		=	3'd1;
									read_B_addr_sel           		=	3'd1;
									B_row_count_sel                	=	3'd1;
									B_col_count_sel                	=	3'd1;
								end
								
								read_RESULT_addr_sel                =	3'd0; //or X
								//read_A_addr_sel                     =	1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								//read_B_addr_sel                     =	1;
								read_SCRATCH_addr_sel               =	3'd0; //or X
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								//B_row_count_sel                     =	1;
								//B_col_count_sel                     =	1;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								if		((SRAM_A_COL_size == 3) && (B_row_count == 3))	next_state = S10_V;
								else if ((SRAM_A_COL_size == 2) && (B_row_count == 2))	next_state = S10_str_V;
								else if ((SRAM_A_COL_size == 1) && (B_row_count == 1))	next_state = S11_V;
								else 													next_state = S8_str_V;
							end
									
	S8_str_V                : begin
								
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd1;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								
								//if	(SRAM_A_COL_size == 2'b11))	B_row_count_sel   	=	2'b10;		//Multiplication Corner-case size = 3
								//else							
								B_row_count_sel   					=	2'b01;
								
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd1;
								
								
								set_dut_ready           = 		1'b0;
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								
								/* if	(SRAM_A_COL_size == 2'b11))		
									begin
										if((B_row_count == (SRAM_A_COL_size ))
											begin
												next_state = S16_str;
											end
									end
								else begin	 */
									if		(B_row_count < (SRAM_A_COL_size - 1'b1))	next_state = S8_str_V;
									else if	(B_row_count == (SRAM_A_COL_size - 1'b1))	next_state = S10_V;			//latch change from else if to else
									else												next_state = S8_str_V;																//latch NS
								//end
								
							end
								
													
	S10_V                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd1;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S10_str_V;
							end								
									
									
									
	S10_str_V                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd1;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S11_V;	//need to adopt S11_str
							end																	
									
									
									
									
	S11_V               : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								
								write_SCRATCH_addr_sel         =	3'd0;
								
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd1;
								write_RESULT_addr_sel          =	3'd1;
								write_RESULT_data_sel          =	3'd1;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								if (B_col_count < (SRAM_B_COL_size * SRAM_A_COL_size) && (B_row_count == SRAM_A_COL_size) &&  (A_row_count < (SRAM_A_ROW_size + 1)))			next_state = S7_V;
								else if (B_col_count == (SRAM_B_COL_size * SRAM_A_COL_size) && (B_row_count == SRAM_A_COL_size) && (A_row_count < (SRAM_A_ROW_size + 1)))		next_state = S7_str_V;
								else 																																			next_state = S11_V;
								
							end										
									
									
	S7_V                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd3;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
								read_B_addr_sel                     =	3'd1;
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd3;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S8_V;
							end																	
									
									
	S7_str_V                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd0;
								read_A_addr_sel                     =	3'd1;
								read_A_MUX_sel                      =	3'd0;
																		
								read_B_MUX_sel                      =	3'd0;
if (A_row_count == SRAM_A_ROW_size)	read_B_addr_sel                     =	3'd2;
else								read_B_addr_sel                     =	3'd3; //or if it is the last case then it should be 2 --> Cause S8_up will increment to 1.
								read_SCRATCH_addr_sel               =	3'd0;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd1;
								B_row_count_sel                     =	3'd3;
								B_col_count_sel                     =	3'd3;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S8_V;
							end	
							
														
//----------------------------------------V-OVER---------------------------------------------------------------------------					
//--------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------					
//-----------------------------------------S-START---------------------------------------------------------------------------------


S8_S                  : begin
								 if(A_row_count == (SRAM_A_ROW_size + 1) &&  (SYS_count == 4)) 	
								begin
									set_dut_ready           = 		1'b0;
								
									input_write_enable_sel	=	1'b0;// Change the name input
									weight_write_enable_sel =	1'b0;// Change the name weight
								
									SYS_count_sel						=	3'd1;
									write_SCRATCH_enable_sel       =	2'd0;
									write_SCRATCH_addr_sel         =	3'd0;
									write_SCRATCH_data_sel         =	3'd0;
																				
									read_RESULT_addr_sel                =	3'd0;
									read_A_addr_sel                     =	3'd2;	//note 4 for FSM-> V
									read_A_MUX_sel                      =	3'd1;
																				
									read_B_MUX_sel                      =	3'd1;
									read_B_addr_sel                     =	3'd2;
									read_SCRATCH_addr_sel               =	3'd2;
																				
									write_RESULT_enable_sel        =	3'd0;
									write_RESULT_addr_sel          =	3'd2;
									write_RESULT_data_sel          =	3'd0;
																				
									A_row_count_sel                     =	3'd0;
									B_row_count_sel                     =	3'd2;
									B_col_count_sel                     =	3'd2;
																		
									V_start_addr_sel                    =	3'd1;
																		
									convol_result_sel                   =	3'd0;
								
								
									SRAM_A_row_sel			=		2'b00;
									SRAM_A_col_sel          =		2'b00;
									SRAM_B_row_sel          =		2'b00;
									SRAM_B_col_sel          =		2'b00;
						
									next_state = S8_T; // Meaning start with 'V' computation NEXT.
									//next_state = MATRIX_DONE_write_the_last_value;
								end
								else begin
								
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																			
								read_RESULT_addr_sel                =	3'd1;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd1;
																			
								read_B_MUX_sel                      =	3'd1;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd1;
																			
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																			
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd1;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd0;
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								next_state	= S9_S;
								end
							end
							
							
							
									
									
S9_S                    : begin
																																			
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;//before 2
								write_SCRATCH_data_sel         =	3'd0;
																		
								if((SRAM_B_COL_size <= 2) && (B_row_count <= 2))	begin
									read_RESULT_addr_sel            =	3'd2;
									read_SCRATCH_addr_sel           =	2;
									B_row_count_sel                 =	2;
									B_col_count_sel                 =	2;
								
								end
								else begin
									read_RESULT_addr_sel            =	3'd1;
									read_SCRATCH_addr_sel           =	1;
									B_row_count_sel                	=	1;
									B_col_count_sel                	=	1;
								end
								//read_RESULT_addr_sel                =	1;
								read_A_addr_sel                     =	2;
								read_A_MUX_sel                      =	3'd1;
																		 
								read_B_MUX_sel                      =	1;
								read_B_addr_sel                     =	2;
								//read_SCRATCH_addr_sel               =	1;
																		
								write_RESULT_enable_sel        =	0;
								write_RESULT_addr_sel          =	2;
								write_RESULT_data_sel          =	0;
																		
								A_row_count_sel                     =	3'd2;
								//B_row_count_sel                     =	1;
								//B_col_count_sel                     =	1;
																		
								V_start_addr_sel                    =	2;
																		
								convol_result_sel                   =	0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								if		((SRAM_B_COL_size == 3) && (B_row_count == 3))	next_state = S10_S;
								else if ((SRAM_B_COL_size == 2) && (B_row_count == 2))	next_state = S10_str_S;
								else if ((SRAM_B_COL_size == 1) && (B_row_count == 1))	next_state = S11_S;
								else 													next_state = S8_str_S;//S8_str;
								
							end
									
S8_str_S                : begin
								
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd1;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd1;
																		 
								read_B_MUX_sel                      =	3'd1;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd1;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								
								/* if	(SRAM_A_COL_size == 2'b11))	B_row_count_sel   	=	2'b10;		//Multiplication Corner-case size = 3
								else				 */			
								B_row_count_sel   					=	3'b01;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd1;
								
								
								set_dut_ready           = 		1'b0;
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								
								/* if	(SRAM_A_COL_size == 2'b11))		
									begin
										if((B_row_count == (SRAM_A_COL_size ))
											begin
												next_state = S16_str;
											end
									end */
								//else begin	change from A_COL
									if		(B_row_count <  (SRAM_B_COL_size - 1'b1))	next_state = S8_str_S;
									else if (B_row_count == (SRAM_B_COL_size - 1'b1))	next_state = S10_S;											//latch change from else if to else
									else												next_state = S8_str_S;																//latch NS
								//end
								
							end
								
													
S10_S                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd2;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd1;
																		
								read_B_MUX_sel                      =	3'd1;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd2;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd1;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S10_str_S;
							end							
									
									
									
	S10_str_S                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd2;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd1;
																		
								read_B_MUX_sel                      =	3'd1;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd2;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd1;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S11_S;	//need to adopt S11_str
							end																	
									
									
									
									
S11_S               : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								
								write_SCRATCH_addr_sel         =	3'd0;
								
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd2;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd1;
																		
								read_B_MUX_sel                      =	3'd1;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd2;
																		
								write_RESULT_enable_sel        =	3'd1;
								write_RESULT_addr_sel          =	3'd1;
								write_RESULT_data_sel          =	3'd1;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								if (B_col_count <  (SRAM_B_COL_size * SRAM_A_ROW_size) && (B_row_count == SRAM_B_COL_size) &&  (A_row_count < (SRAM_A_ROW_size + 1)))			next_state = S7_S;
								else if (B_col_count == (SRAM_B_COL_size * SRAM_A_ROW_size) && (B_row_count == SRAM_B_COL_size) && (A_row_count < (SRAM_A_ROW_size + 1)))		next_state = S7_str_S;
								else																																			next_state = S11_S;	//latch NS
								
							end										
									
									
	S7_S                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd7;//Important case adapted here.
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd1;
																	
								read_B_MUX_sel                      =	3'd1;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd1;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd5;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S8_S;
							end																	
									
									
			S7_str_S                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd1;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd1;
																		
								read_B_MUX_sel                      =	3'd1;
if (A_row_count == SRAM_A_ROW_size)	read_B_addr_sel                     =	3'd2;
else						read_B_addr_sel                     =	3'd3;//3; //or if it is the last case then it should be 2 --> Cause S8_up will increment to 1.
								read_SCRATCH_addr_sel               =	3'd4;	//I have created '4' for S addr (Scratchfile calculation.)
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd1;
								B_row_count_sel                     =	3'd5;
								B_col_count_sel                     =	3'd5;// Imp insted of 3 it is 5
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S8_S;
							end	
							
//----------------------------------------S-OVER---------------------------------------------------------------------------					
//--------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------					
//-----------------------------------------V-T-START---------------------------------------------------------------------------------
						
S8_T                  : 	begin
									set_dut_ready           = 		1'b0;
								
									input_write_enable_sel	=	1'b0;// Change the name input
									weight_write_enable_sel =	1'b0;// Change the name weight
								
									SYS_count_sel						=	3'd2;
									write_SCRATCH_enable_sel       =	2'd0;
									write_SCRATCH_addr_sel         =	3'd0;
									write_SCRATCH_data_sel         =	3'd0;
																			
									read_RESULT_addr_sel                =	3'd5;
									read_A_addr_sel                     =	3'd2;
									read_A_MUX_sel                      =	3'd1;
																			
									read_B_MUX_sel                      =	3'd1;
									read_B_addr_sel                     =	3'd2;
									read_SCRATCH_addr_sel               =	3'd0;
																			
									write_RESULT_enable_sel        =	3'd0;
									write_RESULT_addr_sel          =	3'd2;
									write_RESULT_data_sel          =	3'd0;
																			
									A_row_count_sel                     =	3'd2;
									B_row_count_sel                     =	3'd0;//X Dontcare.
									B_col_count_sel                     =	3'd2;
																			
									V_start_addr_sel                    =	3'd2;
																			
									convol_result_sel                   =	3'd0;
								
								
									SRAM_A_row_sel			=		2'b00;
									SRAM_A_col_sel          =		2'b00;
									SRAM_B_row_sel          =		2'b00;
									SRAM_B_col_sel          =		2'b00;
						
									next_state = SX; 
								end
						
						
						
						SX                  : 
								begin
									set_dut_ready           = 		1'b0;
								
									input_write_enable_sel	=	1'b0;// Change the name input
									weight_write_enable_sel =	1'b0;// Change the name weight
								
									SYS_count_sel						=	3'd2;
									write_SCRATCH_enable_sel       =	2'd0;
									write_SCRATCH_addr_sel         =	3'd2;
									write_SCRATCH_data_sel         =	3'd0;
																			
									read_RESULT_addr_sel                =	3'd2;
									read_A_addr_sel                     =	3'd2;
									read_A_MUX_sel                      =	3'd1;
																			
									read_B_MUX_sel                      =	3'd1;
									read_B_addr_sel                     =	3'd2;
									read_SCRATCH_addr_sel               =	3'd0;
																			
									write_RESULT_enable_sel        =	3'd0;
									write_RESULT_addr_sel          =	3'd2;
									write_RESULT_data_sel          =	3'd0;
																			
									A_row_count_sel                     =	3'd2;
									B_row_count_sel                     =	3'd0;//X Dontcare.
									B_col_count_sel                     =	3'd2;
																			
									V_start_addr_sel                    =	3'd1;
																			
									convol_result_sel                   =	3'd0;
								
								
									SRAM_A_row_sel			=		2'b00;
									SRAM_A_col_sel          =		2'b00;
									SRAM_B_row_sel          =		2'b00;
									SRAM_B_col_sel          =		2'b00;
						
									next_state = SA; 
								end
								
								
						SA                  : 
								begin
									set_dut_ready           = 		1'b0;
								
									input_write_enable_sel	=	1'b0;// Change the name input
									weight_write_enable_sel =	1'b0;// Change the name weight
								
									SYS_count_sel						=	3'd2;
									write_SCRATCH_enable_sel       =	2'd0;
									write_SCRATCH_addr_sel         =	3'd2;
									write_SCRATCH_data_sel         =	3'd0;
																			
									read_RESULT_addr_sel                =	3'd2;
									read_A_addr_sel                     =	3'd2;
									read_A_MUX_sel                      =	3'd1;
																			
									read_B_MUX_sel                      =	3'd1;
									read_B_addr_sel                     =	3'd2;
									read_SCRATCH_addr_sel               =	3'd0;
																			
									write_RESULT_enable_sel        =	3'd0;
									write_RESULT_addr_sel          =	3'd2;
									write_RESULT_data_sel          =	3'd0;
																			
									A_row_count_sel                     =	3'd2;
									B_row_count_sel                     =	3'd0;//X Dontcare.
									B_col_count_sel                     =	3'd2;
																		
									V_start_addr_sel                    =	3'd2;
																			
									convol_result_sel                   =	3'd0;
								
								
									SRAM_A_row_sel			=		2'b00;
									SRAM_A_col_sel          =		2'b00;
									SRAM_B_row_sel          =		2'b00;
									SRAM_B_col_sel          =		2'b00;
						
									next_state = SBB; 
								end
								
								
						SBB                 : 
								begin
									set_dut_ready           = 		1'b0;
								
									input_write_enable_sel	=	1'b0;// Change the name input
									weight_write_enable_sel =	1'b0;// Change the name weight
								
									SYS_count_sel						=	3'd2;
									write_SCRATCH_enable_sel       =	2'd1;
									if(B_col_count == 1)	write_SCRATCH_addr_sel         =	3'd0;
									else					write_SCRATCH_addr_sel         =	3'd1;
									write_SCRATCH_data_sel         =	3'd3;
																				
									read_RESULT_addr_sel                =	3'd4;
									read_A_addr_sel                     =	3'd2;
									read_A_MUX_sel                      =	3'd1;
																		
									read_B_MUX_sel                      =	3'd1;
									read_B_addr_sel                     =	3'd2;
									read_SCRATCH_addr_sel               =	3'd0;
																		
									write_RESULT_enable_sel        =	3'd0;
									write_RESULT_addr_sel          =	3'd2;
									write_RESULT_data_sel          =	3'd0;
																
									A_row_count_sel                     =	3'd1;
									B_row_count_sel                     =	3'd0;//X Dontcare.
									B_col_count_sel                     =	3'd2;
																		
									V_start_addr_sel                    =	3'd2;
																		
									convol_result_sel                   =	3'd0;
								
								
									SRAM_A_row_sel			=		2'b00;
									SRAM_A_col_sel          =		2'b00;
									SRAM_B_row_sel          =		2'b00;
									SRAM_B_col_sel          =		2'b00;
						
						
									if(SRAM_A_ROW_size == 1) begin
										if(/* ((SRAM_B_COL_size == 1) && (B_col_count == 1)) || */ (B_col_count == SRAM_B_COL_size)) begin 
											read_RESULT_addr_sel = 3'd1;
											next_state = S_transpose_over;
										end
										else if (B_col_count < SRAM_B_COL_size) begin 
											B_col_count_sel		= 	3'd1;
											read_RESULT_addr_sel = 3'd5;
											next_state = SX;
										end
										else	next_state = SBB;																//latch NS
									end
									
									else if (A_row_count < SRAM_A_ROW_size) begin
									next_state = SY;
									end	

									else	next_state = SBB;																//latch NS									
								end
								
					
					
					
					
						SY                  : 
								begin
									set_dut_ready           = 		1'b0;
								
									input_write_enable_sel	=	1'b0;// Change the name input
									weight_write_enable_sel =	1'b0;// Change the name weight
								
									SYS_count_sel						=	3'd2;
									write_SCRATCH_enable_sel       =	2'd0;
									write_SCRATCH_addr_sel         =	3'd2;
									write_SCRATCH_data_sel         =	3'd0;
																			
									read_RESULT_addr_sel                =	3'd2;
									read_A_addr_sel                     =	3'd2;
									read_A_MUX_sel                      =	3'd1;
																			
									read_B_MUX_sel                      =	3'd1;
									read_B_addr_sel                     =	3'd2;
									read_SCRATCH_addr_sel               =	3'd0;
																				
									write_RESULT_enable_sel        =	3'd0;
									write_RESULT_addr_sel          =	3'd2;
									write_RESULT_data_sel          =	3'd0;
																			
									A_row_count_sel                     =	3'd2;
									B_row_count_sel                     =	3'd0;//X Dontcare.
									B_col_count_sel                     =	3'd2;
																			
									V_start_addr_sel                    =	3'd2;
																			
									convol_result_sel                   =	3'd0;
								
								
									SRAM_A_row_sel			=		2'b00;
									SRAM_A_col_sel          =		2'b00;
									SRAM_B_row_sel          =		2'b00;
									SRAM_B_col_sel          =		2'b00;
						
									next_state = SC; 
								end
								
								
								
								
								
						SC              : 
								begin
									set_dut_ready           = 		1'b0;
								
									input_write_enable_sel	=	1'b0;// Change the name input
									weight_write_enable_sel =	1'b0;// Change the name weight
								
									SYS_count_sel						=	3'd2;
									write_SCRATCH_enable_sel       =	2'd0;
									write_SCRATCH_addr_sel         =	3'd2;
									write_SCRATCH_data_sel         =	3'd0;
																		
									read_RESULT_addr_sel                =	3'd2;
									read_A_addr_sel                     =	3'd2;
									read_A_MUX_sel                      =	3'd1;
																			
									read_B_MUX_sel                      =	3'd1;
									read_B_addr_sel                     =	3'd2;
									read_SCRATCH_addr_sel               =	3'd0;
																			
									write_RESULT_enable_sel        =	3'd0;
									write_RESULT_addr_sel          =	3'd2;
									write_RESULT_data_sel          =	3'd0;
																			
									A_row_count_sel                     =	3'd2;
									B_row_count_sel                     =	3'd0;//X Dontcare.
									B_col_count_sel                     =	3'd2;
																			
									V_start_addr_sel                    =	3'd2;
																			
									convol_result_sel                   =	3'd0;
								
								
									SRAM_A_row_sel			=		2'b00;
									SRAM_A_col_sel          =		2'b00;
									SRAM_B_row_sel          =		2'b00;
									SRAM_B_col_sel          =		2'b00;
						
									next_state = SD; 
								end
								
								
						SD                 : 
								begin
									set_dut_ready           = 		1'b0;
								
									input_write_enable_sel	=	1'b0;// Change the name input
									weight_write_enable_sel =	1'b0;// Change the name weight
								
									SYS_count_sel						=	3'd2;
									write_SCRATCH_enable_sel       =	2'd1;
									write_SCRATCH_addr_sel         =	3'd1;
									write_SCRATCH_data_sel         =	3'd3;
																			
									if((A_row_count == SRAM_A_ROW_size)&&(B_col_count == SRAM_B_COL_size))	read_RESULT_addr_sel    =	3'd1;
									else if((A_row_count < SRAM_A_ROW_size)&&(B_col_count <= SRAM_B_COL_size))	read_RESULT_addr_sel    =	3'd4;
									else	read_RESULT_addr_sel        =	3'd5;
									read_A_addr_sel                     =	3'd2;
									read_A_MUX_sel                      =	3'd1;
																			
									read_B_MUX_sel                      =	3'd1;
									read_B_addr_sel                     =	3'd2;
									read_SCRATCH_addr_sel               =	3'd0;
																			
									write_RESULT_enable_sel        =	3'd0;
									write_RESULT_addr_sel          =	3'd2;
									write_RESULT_data_sel          =	3'd0;
																				
									
									if(A_row_count == SRAM_A_ROW_size)	A_row_count_sel                     =	3'd0;
									else 								A_row_count_sel                     =	3'd1;
									
									B_row_count_sel                     =	0;//X Dontcare.
									if(A_row_count == SRAM_A_ROW_size)		B_col_count_sel                     =	3'd1;
									else									B_col_count_sel                     =	3'd2;
																		
									V_start_addr_sel                    =	3'd2;
																		
									convol_result_sel                   =	3'd0;
								
								
									SRAM_A_row_sel			=		2'b00;
									SRAM_A_col_sel          =		2'b00;
									SRAM_B_row_sel          =		2'b00;
									SRAM_B_col_sel          =		2'b00;
						
						
									if((SRAM_B_COL_size == 1) || (B_col_count == SRAM_B_COL_size)) begin
										if(A_row_count < SRAM_A_ROW_size) begin
										next_state = SY;
										end
										else if(A_row_count == SRAM_A_ROW_size) begin
										
										next_state = S_transpose_over;
										end
										else	next_state = SD;																//latch NS
									end
									
									else if (B_col_count < SRAM_B_COL_size) begin
										if(A_row_count == SRAM_A_ROW_size) begin
										
											next_state = SX;
										end
										else if(A_row_count < SRAM_A_ROW_size) begin											//if if - if else
											next_state = SY;
										end
										else	next_state = SD;																//latch NS
									end		
									else	next_state = SD;																//latch NS									
								end
								
								
					S_transpose_over                  : 
								begin
									set_dut_ready           = 		1'b0;
								
									input_write_enable_sel	=	1'b0;// Change the name input
									weight_write_enable_sel =	1'b0;// Change the name weight
								
									SYS_count_sel						=	3'd1;
									write_SCRATCH_enable_sel       =	2'd0;
									write_SCRATCH_addr_sel         =	3'd0;
									write_SCRATCH_data_sel         =	3'd0;
																				
									read_RESULT_addr_sel                =	3'd2;
									read_A_addr_sel                     =	3'd2;
									read_A_MUX_sel                      =	3'd1;
																				
									read_B_MUX_sel                      =	3'd1;
									read_B_addr_sel                     =	3'd2;
									read_SCRATCH_addr_sel               =	3'd0;
																				
									write_RESULT_enable_sel        =	3'd0;
									write_RESULT_addr_sel          =	3'd2;
									write_RESULT_data_sel          =	3'd0;
																				
									A_row_count_sel                     =	3'd0;
									B_row_count_sel                     =	3'd0;//X Dontcare.
									B_col_count_sel                     =	3'd0;
																		
									V_start_addr_sel                    =	3'd1;
																		
									convol_result_sel                   =	3'd0;
								
								
									SRAM_A_row_sel			=		2'b00;
									SRAM_A_col_sel          =		2'b00;
									SRAM_B_row_sel          =		2'b00;
									SRAM_B_col_sel          =		2'b00;
						
									next_state = S8_Z; 
								end
								
								
//----------------------------------------V-T-OVER---------------------------------------------------------------------------					
//--------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------					
//-----------------------------------------Z-START---------------------------------------------------------------------------------


 S8_Z                  : begin
								if(A_row_count == (SRAM_A_ROW_size + 1) &&  (SYS_count == 6)) 	begin
								set_dut_ready           = 		1'b0;
								input_write_enable_sel	=	1'b0;											//for latch 2.1	input WE
								weight_write_enable_sel	=	1'b0;											//for latch 2.1 weight WE
								SYS_count_sel						=	3'd2;
								
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
								
								read_RESULT_addr_sel                =	3'd2;
								read_SCRATCH_addr_sel               =	3'd2;
								
								read_A_addr_sel                     =	3'd2;
								read_B_addr_sel                     =	3'd2;
								
								read_A_MUX_sel                      =	3'd1;
								read_B_MUX_sel                      =	3'd1;
								
								write_RESULT_enable_sel        =	0;
								write_RESULT_addr_sel          =	2;
								
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	1;
								B_col_count_sel                     =	1;
								
								write_RESULT_data_sel          =	0;
								V_start_addr_sel                    =	2;
								
								convol_result_sel					= 0;
								
								SRAM_A_row_sel			=		2'b00;
								SRAM_A_col_sel          =		2'b00;
								SRAM_B_row_sel          =		2'b00;
								SRAM_B_col_sel          =		2'b00;
								next_state = MATRIX_DONE_write_the_last_value;
								end
								else begin
								
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd1;
								read_A_addr_sel                     =	2;
								read_A_MUX_sel                      =	3'd1;
																		
								read_B_MUX_sel                      =	1;
								read_B_addr_sel                     =	2;
								read_SCRATCH_addr_sel               =	1;
																		
								write_RESULT_enable_sel        =	0;
								write_RESULT_addr_sel          =	2;
								write_RESULT_data_sel          =	0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	1;
								B_col_count_sel                     =	1;
																		
								V_start_addr_sel                    =	2;
																		
								convol_result_sel                   =	0;
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								if ((SRAM_A_ROW_size == 1) && (B_row_count == 1))	begin
									read_RESULT_addr_sel                 =	3'd2;
									read_SCRATCH_addr_sel                =	2;
									B_row_count_sel               		 =	2;
									B_col_count_sel                      =	2;
									//next_state = S11_Z;
								end

								/* else */		next_state	= S9_Z;
							end
						end
							
							
							
									
									
S9_Z                    : begin				//s9
																																			
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;//before 2
								write_SCRATCH_data_sel         =	3'd0;
								//Acol ==> A_ROW.										
								if((SRAM_A_ROW_size <= 2) && (B_row_count <= 2))	begin
									read_RESULT_addr_sel            =	3'd2;
									read_SCRATCH_addr_sel           =	2;
									B_row_count_sel                 =	2;
									B_col_count_sel                 =	2;
								
								end
								else begin
									read_RESULT_addr_sel            =	3'd1;
									read_SCRATCH_addr_sel           =	1;
									B_row_count_sel                	=	1;
									B_col_count_sel                	=	1;
								end
								//read_RESULT_addr_sel                =	1;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd1;
																		 
								read_B_MUX_sel                      =	1;
								read_B_addr_sel                     =	2;
								//read_SCRATCH_addr_sel               =	1;
																		
								write_RESULT_enable_sel        =	0;
								write_RESULT_addr_sel          =	2;
								write_RESULT_data_sel          =	0;
																		
								A_row_count_sel                     =	3'd2;
								//B_row_count_sel                     =	1;
								//B_col_count_sel                     =	1;
																		
								V_start_addr_sel                    =	2;
																		
								convol_result_sel                   =	0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								if		((SRAM_A_ROW_size == 3) && (B_row_count == 3))	next_state = S10_Z;
								else if ((SRAM_A_ROW_size == 2) && (B_row_count == 2))	next_state = S10_str_Z;
								else if ((SRAM_A_ROW_size == 1) && (B_row_count == 1))	next_state = S11_Z;
								else 													next_state = S8_str_Z;
							end
									
	S8_str_Z                : begin
								
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd1;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd1;
																		
								read_B_MUX_sel                      =	3'd1;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd1;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								
								//if	(SRAM_A_COL_size == 2'b11))	B_row_count_sel   	=	2'b10;		//Multiplication Corner-case size = 3
								//else							
								B_row_count_sel   					=	3'b01;
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd1;
								
								
								set_dut_ready           = 		1'b0;
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
								
								
								/* if	(SRAM_A_COL_size == 2'b11))		
									begin
										if((B_row_count == (SRAM_A_COL_size ))
											begin
												next_state = S16_str/S10_str;
											end
									end */
								//else begin	changed alt.
									if		(B_row_count <  (SRAM_A_ROW_size - 1'b1))	next_state = S8_str_Z;
									else if (B_row_count == (SRAM_A_ROW_size - 1'b1))	next_state = S10_Z;
									else												next_state = S8_str_Z;																//latch NS
								//end
								
							end
								
													
		S10_Z                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd2;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd1;
																		
								read_B_MUX_sel                      =	3'd1;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd2;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd1;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S10_str_Z;
							end								
									
									
									
	S10_str_Z                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd2;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd1;
																		
								read_B_MUX_sel                      =	3'd1;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd2;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd1;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S11_Z;	//need to adopt S11_str
							end																	
									
									
									
									
		S11_Z               : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								
								write_SCRATCH_addr_sel         =	3'd0;
								
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd2;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd1;
																		
								read_B_MUX_sel                      =	3'd1;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd2;
																		
								write_RESULT_enable_sel        =	3'd1;
								write_RESULT_addr_sel          =	3'd1;
								write_RESULT_data_sel          =	3'd1;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd2;
								B_col_count_sel                     =	3'd2;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								if (B_col_count <  (SRAM_B_COL_size * SRAM_A_ROW_size) && (B_row_count == SRAM_A_ROW_size) &&  (A_row_count < (SRAM_A_ROW_size + 1)))			next_state = S7_Z;
								else if (B_col_count == (SRAM_B_COL_size * SRAM_A_ROW_size) && (B_row_count == SRAM_A_ROW_size) && (A_row_count <  (SRAM_A_ROW_size + 1)))		next_state = S7_str_Z;		//if if - if  else
								else																																			next_state = S11_Z;					//latch NS
								
							end										
									
									
	S7_Z                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd6;// cause size change for S
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd1;
																	
								read_B_MUX_sel                      =	3'd1;
								read_B_addr_sel                     =	3'd2;
								read_SCRATCH_addr_sel               =	3'd1;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																		
								A_row_count_sel                     =	3'd2;
								B_row_count_sel                     =	3'd4;//Imp Cause Siz of Z is different.
								B_col_count_sel                     =	3'd1;
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'd0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S8_Z;
							end																	
									
									
		S7_str_Z                : begin
	
	
								set_dut_ready           = 		1'b0;
								
								input_write_enable_sel	=	1'b0;// Change the name input
								weight_write_enable_sel =	1'b0;// Change the name weight
								
								SYS_count_sel						=	3'd2;
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
																		
								read_RESULT_addr_sel                =	3'd1;
								read_A_addr_sel                     =	3'd2;
								read_A_MUX_sel                      =	3'd1;
																		
								read_B_MUX_sel                      =	3'd1;
if (A_row_count == SRAM_A_ROW_size)	read_B_addr_sel             =    3'd2;
else						read_B_addr_sel                     =	3'd3;//3; //or if it is the last case then it should be 2 --> Cause S8_up will increment to 1.
								read_SCRATCH_addr_sel               =	3'd4;
																		
								write_RESULT_enable_sel        =	3'd0;
								write_RESULT_addr_sel          =	3'd2;
								write_RESULT_data_sel          =	3'd0;
																	
								A_row_count_sel                     =	3'd1;
								B_row_count_sel                     =	3'd4;//Imp Cause Siz of Z is different.
								B_col_count_sel                     =	3'd5;// Imp insted of 3 it is 5
																		
								V_start_addr_sel                    =	3'd2;
																		
								convol_result_sel                   =	3'b0;
								
								
								
								SRAM_A_row_sel			=		2'b00;
                                SRAM_A_col_sel          =		2'b00;
                                SRAM_B_row_sel          =		2'b00;
                                SRAM_B_col_sel          =		2'b00;
	
								next_state = S8_Z;
							end									
									
									
									
	MATRIX_DONE_write_the_last_value	: begin
												SYS_count_sel						=	3'd2;		//Latch
												input_write_enable_sel	=	1'b0;
												weight_write_enable_sel =	1'b0;
								
								
												write_SCRATCH_enable_sel       =	2'd0;
												write_SCRATCH_addr_sel         =	3'd0;
												write_SCRATCH_data_sel         =	3'd0;
												
												
												read_RESULT_addr_sel                =	3'd2;
												read_SCRATCH_addr_sel               =	3'd2;
												
												A_row_count_sel   		=		3'b00;
												B_row_count_sel   		=		2'b00;
												B_col_count_sel   		=		2'b00;
																				
												read_A_addr_sel   		=		2'b00;
												read_A_MUX_sel                      =	3'd1;
												
												read_B_addr_sel   		=		2'b00;
												read_B_MUX_sel                      =	3'd1;
												
												convol_result_sel 		=		2'b00;
												write_RESULT_enable_sel		=		2'b00;
												write_RESULT_addr_sel  		=       2'b00;
												write_RESULT_data_sel  		=       2'b00;
												
												V_start_addr_sel                    =	3'd2;
												
												SRAM_A_row_sel			=		2'b00;
												SRAM_A_col_sel          =		2'b00;
												SRAM_B_row_sel          =		2'b00;
												SRAM_B_col_sel          =		2'b00;	
												
												set_dut_ready         	= 		1'b1;
												next_state = IDLE;
											end
	
	
	default	:					 begin
								SYS_count_sel						=	3'd2;				//Latch
								input_write_enable_sel	=	1'b0;
								weight_write_enable_sel =	1'b0;
								
								write_SCRATCH_enable_sel       =	2'd0;
								write_SCRATCH_addr_sel         =	3'd0;
								write_SCRATCH_data_sel         =	3'd0;
								
								read_RESULT_addr_sel                =	3'd2;
								read_SCRATCH_addr_sel               =	3'd2;
												A_row_count_sel   		=		3'b00;
												B_row_count_sel   		=		2'b00;
												B_col_count_sel   		=		2'b00;
																				
												read_A_addr_sel   		=		2'b00;
												read_A_MUX_sel                      =	3'd0;
												read_B_MUX_sel                      =	3'd0;
												read_B_addr_sel   		=		2'b00;
												
												convol_result_sel 		=		2'b00;
												write_RESULT_enable_sel		=		2'b00;
												write_RESULT_addr_sel  		=       2'b00;
												write_RESULT_data_sel  		=       2'b00;
												
												V_start_addr_sel                    =	3'd2;
												
												SRAM_A_row_sel			=		2'b00;
												SRAM_A_col_sel          =		2'b00;
												SRAM_B_row_sel          =		2'b00;
												SRAM_B_col_sel          =		2'b00;	
												
												set_dut_ready         	= 		1'b1;
												next_state = IDLE;
											end
								
								
						
								
	endcase
end


always @(posedge clk) begin 
  if(!reset_n) begin
    SYS_count_R <= 0;
    end
    else begin
		   if (SYS_count_sel == 2'b00)        SYS_count_R <= 0;//`SRAM_ADDR_WIDTH'b0;
      else if (SYS_count_sel == 2'b01)        SYS_count_R <= SYS_count_R + 1'b1;
      else if (SYS_count_sel == 2'b10)        SYS_count_R <= SYS_count_R;
      else 	  							      SYS_count_R <= SYS_count_R;
    end
end

assign SYS_count = SYS_count_R;


 always @(posedge clk) begin 
  if(!reset_n) begin
    compute_complete <= 1;			// make this reg
  end else begin
    compute_complete <= (set_dut_ready) ? 1'b1 : 1'b0;
  end
end
	
assign dut_ready = compute_complete;	//compute_complete; 

// always @(posedge clk) begin 
	// if(!reset_n) begin
		// compute_complete <= 1;
	// end
	// else begin
		// if(dut_valid)	compute_complete <= 0;			//doubt in this
		// else if(set_dut)	compute_complete <= 0;			//doubt in this
	// end
// end

// dut_ready = compute_complete;	
	


//-> dut__tb__sram_input_read_address
 
always @(posedge clk) begin 
  if(!reset_n) begin
    dut__tb__sram_input_read_address_R <= 16'bx;
    end
    else begin
		   if (read_A_addr_sel == 3'b000)        dut__tb__sram_input_read_address_R <= 0;		//`SRAM_ADDR_WIDTH'b0;
      else if (read_A_addr_sel == 3'b001)        dut__tb__sram_input_read_address_R <= dut__tb__sram_input_read_address_R + `SRAM_ADDR_WIDTH'b1;
      else if (read_A_addr_sel == 3'b010)        dut__tb__sram_input_read_address_R <= dut__tb__sram_input_read_address_R;
      else if (read_A_addr_sel == 3'b011)        dut__tb__sram_input_read_address_R <= dut__tb__sram_input_read_address_R - (/* SRAM_B_ROW_size */ SRAM_A_COL_size - 1);
	  else if (read_A_addr_sel== 3'b100)		dut__tb__sram_input_read_address_R <= 1;
	  else 										dut__tb__sram_input_read_address_R <= dut__tb__sram_input_read_address_R;
    end
end

assign dut__tb__sram_input_read_address = dut__tb__sram_input_read_address_R;



//-> dut__tb__sram_weights_read_address// actual size 2bit.
 
always @(posedge clk) begin 
  if(!reset_n) begin
    dut__tb__sram_weight_read_address_R <= 16'bx;
    end
    else begin
		   if (read_B_addr_sel == 3'b000)        dut__tb__sram_weight_read_address_R <= 0;//`SRAM_ADDR_WIDTH'b0;
      else if (read_B_addr_sel == 3'b001)        dut__tb__sram_weight_read_address_R <= dut__tb__sram_weight_read_address_R + `SRAM_ADDR_WIDTH'b1;
      else if (read_B_addr_sel == 3'b010)        dut__tb__sram_weight_read_address_R <= dut__tb__sram_weight_read_address_R;
      else if (read_B_addr_sel == 3'b011)        dut__tb__sram_weight_read_address_R <=  (dut__tb__sram_weight_read_address_R + 1) - (B_col_count/* SRAM_A_COL_size * SRAM_B_COL_size */);	//reduce cal
      else										dut__tb__sram_weight_read_address_R <= dut__tb__sram_weight_read_address_R;
	end
end

assign dut__tb__sram_weight_read_address = dut__tb__sram_weight_read_address_R;


//-> dut__tb__sram_result_read_address
 
always @(posedge clk) begin 
  if(!reset_n) begin
    dut__tb__sram_result_read_address_R <= 16'bx;
    end
    else begin
		   if (read_RESULT_addr_sel == 3'b00)        dut__tb__sram_result_read_address_R <= 0;		//`SRAM_ADDR_WIDTH'b0;
      else if (read_RESULT_addr_sel == 3'b01)        dut__tb__sram_result_read_address_R <= dut__tb__sram_result_read_address_R + `SRAM_ADDR_WIDTH'b1;
      else if (read_RESULT_addr_sel == 3'b10)        dut__tb__sram_result_read_address_R <= dut__tb__sram_result_read_address_R;
      else if (read_RESULT_addr_sel == 3'b11)        dut__tb__sram_result_read_address_R <= dut__tb__sram_result_read_address_R - (/* SRAM_B_ROW_size */ SRAM_A_COL_size - 1);
      else if (read_RESULT_addr_sel == 3'd6)        dut__tb__sram_result_read_address_R <= dut__tb__sram_result_read_address_R - (/* SRAM_B_ROW_size */ SRAM_A_ROW_size - 1);
      else if (read_RESULT_addr_sel == 3'd7)        dut__tb__sram_result_read_address_R <= dut__tb__sram_result_read_address_R - (/* SRAM_B_ROW_size */ SRAM_B_COL_size - 1);
	  else if (read_RESULT_addr_sel == 3'd4)		 dut__tb__sram_result_read_address_R <= dut__tb__sram_result_read_address_R + (SRAM_B_COL_size);
	  else if (read_RESULT_addr_sel == 3'd5)		 dut__tb__sram_result_read_address_R <= V_start_addr_wire;
	  else											dut__tb__sram_result_read_address_R <= dut__tb__sram_result_read_address_R;
	  //elseif== 3'b100							dut__tb__sram_input_read_address_R <= 1;
    end
end

assign dut__tb__sram_result_read_address = dut__tb__sram_result_read_address_R;


//-> dut__tb__sram_weights_read_address
 
always @(posedge clk) begin 
  if(!reset_n) begin
    dut__tb__sram_scratchpad_read_address_R <= 16'bx;
    end
    else begin
		   if (read_SCRATCH_addr_sel == 3'b000)        dut__tb__sram_scratchpad_read_address_R <= 0;//`SRAM_ADDR_WIDTH'b0;
      else if (read_SCRATCH_addr_sel == 3'b001)        dut__tb__sram_scratchpad_read_address_R <= dut__tb__sram_scratchpad_read_address_R + `SRAM_ADDR_WIDTH'b1;
      else if (read_SCRATCH_addr_sel == 3'b010)        dut__tb__sram_scratchpad_read_address_R <= dut__tb__sram_scratchpad_read_address_R;
      else if (read_SCRATCH_addr_sel == 3'b011)        dut__tb__sram_scratchpad_read_address_R <= (/* SRAM_A_COL_size * SRAM_B_COL_size */B_col_count) - dut__tb__sram_scratchpad_read_address_R + 1;
      else if (read_SCRATCH_addr_sel == 3'd4)        dut__tb__sram_scratchpad_read_address_R <= (/* SRAM_A_ROW_size * SRAM_B_COL_size */B_col_count) - (dut__tb__sram_scratchpad_read_address_R + 1);	//Note this is only for S Calculation
	  else 												dut__tb__sram_scratchpad_read_address_R <= dut__tb__sram_scratchpad_read_address_R;
	end
end

assign dut__tb__sram_scratchpad_read_address = dut__tb__sram_scratchpad_read_address_R;


always @(posedge clk) begin 
  if(!reset_n) begin
  V_start_addr_R <= 0;
  end
  else begin
	if 		(V_start_addr_sel == 3'd0)		V_start_addr_R <= 0;
	else if (V_start_addr_sel == 3'd1)		V_start_addr_R <= V_start_addr_R + 1;
	else if (V_start_addr_sel == 3'd2)		V_start_addr_R <= V_start_addr_R;
	else if (V_start_addr_sel == 3'd3)		V_start_addr_R <= dut__tb__sram_result_write_address;
	else									V_start_addr_R <= V_start_addr_R;
   end
end

assign V_start_addr_wire = V_start_addr_R;


// Sending A, B to DesignWare Logic.
always @(posedge clk) begin
	if(!reset_n) begin
	tb__dut__sram_input_read_data_R <= 32'bx;//data_in_A <= 0;
	tb__dut__sram_weight_read_data_R <= 32'bx;//data_in_B <= 0;
	
	tb__dut__sram_result_read_data_R  <= 32'bx;
	tb__dut__sram_scratchpad_read_data_R <= 32'bx;
	end
	else begin
		if(read_A_MUX_sel == 3'd0)	tb__dut__sram_input_read_data_R  <= tb__dut__sram_input_read_data;	//SRAM_data_A;
		else //(read_A_MUX_sel == 1)
			tb__dut__sram_input_read_data_R  <= tb__dut__sram_result_read_data ;	//SRAM_data_A;
			
		if (read_B_MUX_sel == 0)		tb__dut__sram_weight_read_data_R <= tb__dut__sram_weight_read_data;	//SRAM_data_B;
		else							tb__dut__sram_weight_read_data_R <= tb__dut__sram_scratchpad_read_data;	//SRAM_data_B;
	end
end

assign temp_tb__dut__sram_input_read_data  = tb__dut__sram_input_read_data_R;
assign temp_tb__dut__sram_weight_read_data = tb__dut__sram_weight_read_data_R;
//assign temp_tb__dut__sram_result_read_data = tb__dut__sram_result_read_data_R;
//assign temp_tb__dut__sram_scratchpad_read_data = tb__dut__sram_scratchpad_read_data_R;


//Convolve data receive Logic
 always @(posedge clk) begin
	if(!reset_n) begin
	convol_result <= 0;
	end
	else begin
			 if (convol_result_sel == 3'b000)		convol_result <= 0;//`SRAM_DATA_WIDTH'b0;
		else if (convol_result_sel == 3'b001)		convol_result <= MATRIX_MUL;//((temp_tb__dut__sram_input_read_data * temp_tb__dut__sram_input_read_data) + convol_result)//mac_result_z;
		else if (convol_result_sel == 3'b010)		convol_result <= convol_result;
		else 										convol_result <= convol_result;
	end
end

//assign wire_convol_result_2_C_write_data_sel = convol_result;				
assign accum_result = convol_result;				
								
assign MATRIX_MUL = ((temp_tb__dut__sram_input_read_data * temp_tb__dut__sram_weight_read_data) + convol_result);						
	


//C_Write_enable_Logic	
always @(posedge clk) begin
	if(!reset_n)
	dut__tb__sram_result_write_enable_R <= 0;//0;		//can i put unknown here
	else begin
		if	   (write_RESULT_enable_sel == 3'b000)		dut__tb__sram_result_write_enable_R <= 0;
		else if(write_RESULT_enable_sel == 3'b001)		dut__tb__sram_result_write_enable_R <= 1;
		else if(write_RESULT_enable_sel == 3'b010)		dut__tb__sram_result_write_enable_R <= dut__tb__sram_result_write_enable_R;
		else 											dut__tb__sram_result_write_enable_R <= dut__tb__sram_result_write_enable_R;
	end
end
assign dut__tb__sram_result_write_enable = dut__tb__sram_result_write_enable_R;



//C_Write_Address_Logic	
always @(posedge clk) begin
	if(!reset_n)
	dut__tb__sram_result_write_address_R <= 0;	//can i put unknown here
	else begin
			 if(write_RESULT_addr_sel == 3'b000)		dut__tb__sram_result_write_address_R <= 0;
		else if(write_RESULT_addr_sel == 3'b001)		dut__tb__sram_result_write_address_R <= dut__tb__sram_result_write_address_R + `SRAM_ADDR_WIDTH'b1;
		else if(write_RESULT_addr_sel == 3'b010)		dut__tb__sram_result_write_address_R <= dut__tb__sram_result_write_address_R;
		else 										dut__tb__sram_result_write_address_R <= dut__tb__sram_result_write_address_R;
	end
end
assign dut__tb__sram_result_write_address = dut__tb__sram_result_write_address_R;
	
	
//C_Write_DATA_Logic	
always @(posedge clk) begin
	if(!reset_n)
	dut__tb__sram_result_write_data_R <= 0;	//can i put unknown here
	else begin
			 if(write_RESULT_data_sel == 3'b000)		dut__tb__sram_result_write_data_R <= 0;
		else if(write_RESULT_data_sel == 3'b001)		dut__tb__sram_result_write_data_R <= MATRIX_MUL;//mac_result_z;//convol_result;//mac_result_z;
		else if(write_RESULT_data_sel == 3'b010)		dut__tb__sram_result_write_data_R <= dut__tb__sram_result_write_data_R;
		else 											dut__tb__sram_result_write_data_R <= dut__tb__sram_result_write_data_R;
	end
end
assign dut__tb__sram_result_write_data = dut__tb__sram_result_write_data_R;

//------------------------SCRATCHPAD-LOGIC-----------------------------
//SCRATCHPAD_Write_enable_Logic	
always @(posedge clk) begin
	if(!reset_n)
	dut__tb__sram_scratchpad_write_enable_R <= 0;		//can i put unknown here
	else begin
		if(write_SCRATCH_enable_sel == 2'b00)		dut__tb__sram_scratchpad_write_enable_R <= 0;												//latch from 2 to 3
		else if(write_SCRATCH_enable_sel == 2'b01)		dut__tb__sram_scratchpad_write_enable_R <= 1;
		else if(write_SCRATCH_enable_sel == 2'b10)		dut__tb__sram_scratchpad_write_enable_R <= dut__tb__sram_scratchpad_write_enable_R;
		else 											dut__tb__sram_scratchpad_write_enable_R <= dut__tb__sram_scratchpad_write_enable_R;
	end
end
assign dut__tb__sram_scratchpad_write_enable = dut__tb__sram_scratchpad_write_enable_R;



//SCRATCHPAD_Write_Address_Logic	
always @(posedge clk) begin
	if(!reset_n)
	dut__tb__sram_scratchpad_write_address_R <= 0;	//can i put unknown here
	else begin
			 if(write_SCRATCH_addr_sel == 2'b00)		dut__tb__sram_scratchpad_write_address_R <= 0;
		else if(write_SCRATCH_addr_sel == 2'b01)		dut__tb__sram_scratchpad_write_address_R <= dut__tb__sram_scratchpad_write_address_R + `SRAM_ADDR_WIDTH'b1;
		else if(write_SCRATCH_addr_sel == 2'b10)		dut__tb__sram_scratchpad_write_address_R <= dut__tb__sram_scratchpad_write_address_R;
	end
end
assign dut__tb__sram_scratchpad_write_address = dut__tb__sram_scratchpad_write_address_R;
	
	
//SCRATCHPAD_Write_DATA_Logic	
always @(posedge clk) begin
	if(!reset_n)
	dut__tb__sram_scratchpad_write_data_R <= 0;	//can i put unknown here
	else begin
			 if(write_SCRATCH_data_sel == 2'b00)		dut__tb__sram_scratchpad_write_data_R <= 0;
		else if(write_SCRATCH_data_sel == 2'b01)		dut__tb__sram_scratchpad_write_data_R <= MATRIX_MUL;//mac_result_z;//convol_result;//mac_result_z;
		else if(write_SCRATCH_data_sel == 2'b10)		dut__tb__sram_scratchpad_write_data_R <= dut__tb__sram_scratchpad_write_data_R;
		else if(write_SCRATCH_data_sel == 2'b11)		dut__tb__sram_scratchpad_write_data_R <= tb__dut__sram_result_read_data;
		else 											dut__tb__sram_scratchpad_write_data_R <= tb__dut__sram_result_read_data;
	end
end
assign dut__tb__sram_scratchpad_write_data = dut__tb__sram_scratchpad_write_data_R;



//------------------------SCRATCHPAD-LOGIC-OVER-----------------------------





//A_ROW_COUNT Logic
always @(posedge clk) begin
	if(!reset_n)
	A_row_count <= 0;	//can i put unknown here
	else begin
			 if(A_row_count_sel == 3'd0)		A_row_count <= 1;//SRAM_A_ROW_size - 2'b10;
			 //if(A_row_count_sel == 2'b11)		A_row_count <= SRAM_A_ROW_size - 1'd1;
		else if(A_row_count_sel == 3'd1)		A_row_count <= A_row_count + 1'd1;				//`SRAM_ADDR_WIDTH'b1;
		else if(A_row_count_sel == 3'd2)		A_row_count <= A_row_count;
		else if(A_row_count_sel == 3'd3)		A_row_count <= A_row_count;
		else if(A_row_count_sel == 3'd4)		A_row_count <= A_row_count;
		else									A_row_count <= A_row_count;
		
	end
end

/* always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        A_row_count <= 0; // Reset to a known state
    end else begin
        case (A_row_count_sel)
            2'b00: A_row_count <= 1; // Assign desired value
            2'b01: A_row_count <= A_row_count + 1; // Increment
            2'b10: A_row_count <= A_row_count; // Hold value
            default: A_row_count <= 0; // Default case to handle undefined `A_row_count_sel`
        endcase
    end
end */

//A_COL_COUNT_Logic	== B_ROW
always @(posedge clk) begin
	if(!reset_n)
	B_row_count <= 16'd0;	//can i put unknown here
	else begin
			 if(B_row_count_sel == 3'b000)		B_row_count <= 16'd1;							//SRAM_B_ROW_size - 2'b10;
		else if(B_row_count_sel == 3'b011)		B_row_count <= /* SRAM_B_ROW_size */ SRAM_A_COL_size - (B_row_count - 1);
		else if(B_row_count_sel == 3'd4)		B_row_count <= /* SRAM_B_ROW_size */ SRAM_A_ROW_size - (B_row_count - 1);	//Cause BROW ==> A_ROW
		else if(B_row_count_sel == 3'd5)		B_row_count <= /* SRAM_B_ROW_size */ SRAM_B_COL_size - (B_row_count - 1);	//Cause BROW ==> B_COL for Scase
		else if(B_row_count_sel == 3'b001)		B_row_count <= B_row_count + 1'd1;			//`SRAM_ADDR_WIDTH'b1;
		else if(B_row_count_sel == 3'b010)		B_row_count <= B_row_count;
		else									B_row_count <= B_row_count;
	end
end
assign B_row_count_wire = B_row_count;
//assign dut__tb__sram_result_write_address = dut__tb__sram_result_write_address_R;
	
	
//B_COL_COUNT_Logic	== C_COL
always @(posedge clk) begin
	if(!reset_n)
	B_col_count <= 0;	//can i put unknown here
	else begin
			 if(B_col_count_sel == 2'b00)		B_col_count <= 1;							//(SRAM_B_ROW_size * SRAM_B_COL_size) - 2'b10;
		else if(B_col_count_sel == 2'b01)		B_col_count <= B_col_count + 1;				//(SRAM_B_ROW_size * SRAM_B_COL_size) - 1'b1;//`SRAM_ADDR_WIDTH'b1;
		else if(B_col_count_sel == 2'b10)		B_col_count <= B_col_count;
		else if(B_col_count_sel == 2'b11)		B_col_count <= (SRAM_B_COL_size * SRAM_A_COL_size) - (B_col_count - 1);
		else if(B_col_count_sel == 3'd5)		B_col_count <= (SRAM_A_ROW_size * SRAM_B_COL_size) - (B_col_count - 1);
	end
end	

//SRAM_A_ROW_size
always @(posedge clk) begin
	if(!reset_n)
	SRAM_A_ROW_size <= 0;	//can i put unknown here
	else begin
			  if (SRAM_A_row_sel == 2'b01)		SRAM_A_ROW_size <= temp_tb__dut__sram_input_read_data[31:16];//tb__dut__sram_weight_read_data[SRAM_DATA_MSB-1:SRAM_ADDR_WIDTH];		//[16:0]					//(SRAM_B_ROW_size * SRAM_B_COL_size) - 2'b10;
			else if (SRAM_A_row_sel == 2'b00)		SRAM_A_ROW_size <= SRAM_A_ROW_size;				//(SRAM_B_ROW_size * SRAM_B_COL_size) - 1'b1;//`SRAM_ADDR_WIDTH'b1;
			else 									SRAM_A_ROW_size <= SRAM_A_ROW_size;
		
	end
end	

//SRAM_A_COL_size
always @(posedge clk) begin
	if(!reset_n)
	SRAM_A_COL_size <= 0;	//can i put unknown here
	else begin
			 if  (SRAM_A_col_sel == 2'b01)		SRAM_A_COL_size <= temp_tb__dut__sram_input_read_data[15:0];//tb__dut__sram_weight_read_data[SRAM_ADDR_MSB-1:0];		//[31:16]						//(SRAM_B_ROW_size * SRAM_B_COL_size) - 2'b10;
			else if (SRAM_A_col_sel == 2'b00)		SRAM_A_COL_size <= SRAM_A_COL_size;				//(SRAM_B_ROW_size * SRAM_B_COL_size) - 1'b1;//`SRAM_ADDR_WIDTH'b1;
			else 									SRAM_A_COL_size <= SRAM_A_COL_size;
	end
end	



//SRAM_B_ROW_size
always @(posedge clk) begin
	if(!reset_n)
	SRAM_B_ROW_size <= 0;	//can i put unknown here
	else begin
			 if  (SRAM_B_row_sel == 2'b01)		SRAM_B_ROW_size <= temp_tb__dut__sram_weight_read_data[31:16];//tb__dut__sram_weight_read_data[SRAM_DATA_MSB-1:SRAM_ADDR_WIDTH];		//[16:0]					//(SRAM_B_ROW_size * SRAM_B_COL_size) - 2'b10;
			else if (SRAM_B_row_sel == 2'b00)		SRAM_B_ROW_size <= SRAM_B_ROW_size;				//(SRAM_B_ROW_size * SRAM_B_COL_size) - 1'b1;//`SRAM_ADDR_WIDTH'b1;
			else									SRAM_B_ROW_size <= SRAM_B_ROW_size;
		
	end
end	

//SRAM_B_COL_size
always @(posedge clk) begin
	if(!reset_n)
	SRAM_B_COL_size <= 0;	//can i put unknown here
	else begin
			 if  (SRAM_B_col_sel == 2'b01)		SRAM_B_COL_size <= temp_tb__dut__sram_weight_read_data[15:0];//tb__dut__sram_weight_read_data[SRAM_ADDR_MSB-1:0];		//[31:16]						//(SRAM_B_ROW_size * SRAM_B_COL_size) - 2'b10;
			else if(SRAM_B_col_sel == 2'b00)		SRAM_B_COL_size <= SRAM_B_COL_size;				//(SRAM_B_ROW_size * SRAM_B_COL_size) - 1'b1;//`SRAM_ADDR_WIDTH'b1;
			else									SRAM_B_COL_size <= SRAM_B_COL_size;
	end
end	
						

//A_input_write enable.
always @(posedge clk) begin
	if(!reset_n)
	dut__tb__sram_input_write_enable_R <= 1'b0;	//can i put unknown here
	else begin
			 if  (input_write_enable_sel == 1'b0)			dut__tb__sram_input_write_enable_R <= 0;
			else if(input_write_enable_sel == 1'b1)			dut__tb__sram_input_write_enable_R <= 1;
			else 											dut__tb__sram_input_write_enable_R <= dut__tb__sram_input_write_enable_R;
	end
end
//B_input_write enable.
always @(posedge clk) begin
	if(!reset_n)
	dut__tb__sram_weight_write_enable_R <= 1'b0;	//can i put unknown here
	else begin
			 if  (weight_write_enable_sel == 1'b0)				dut__tb__sram_weight_write_enable_R <= 0;
			else if(weight_write_enable_sel == 1'b1)			dut__tb__sram_weight_write_enable_R <= 1;
			else 											dut__tb__sram_weight_write_enable_R <= dut__tb__sram_weight_write_enable_R;
	end
end


assign dut__tb__sram_input_write_enable  = dut__tb__sram_input_write_enable_R;							
assign dut__tb__sram_weight_write_enable = dut__tb__sram_weight_write_enable_R;							
								


//##############################################################################

/* DW_fp_mac_inst 
  FP_MAC ( 
  .inst_a(temp_tb__dut__sram_input_read_data),//tb__dut__sram_input_read_data),
  .inst_b(temp_tb__dut__sram_weight_read_data),//tb__dut__sram_weight_read_data),
  .inst_c(accum_result),
  .inst_rnd(3'b000),//inst_rnd),
  .z_inst(mac_result_z),
  .status_inst() */
//);


endmodule

/* module DW_fp_mac_inst #(
  parameter inst_sig_width = 23,
  parameter inst_exp_width = 8,
  parameter inst_ieee_compliance = 0 // These need to be fixed to decrease error
) ( 
  input wire [inst_sig_width+inst_exp_width : 0] inst_a,
  input wire [inst_sig_width+inst_exp_width : 0] inst_b,
  input wire [inst_sig_width+inst_exp_width : 0] inst_c,
  input wire [2 : 0] inst_rnd,
  output wire [inst_sig_width+inst_exp_width : 0] z_inst,
  output wire [7 : 0] status_inst
);

  // Instance of DW_fp_mac
  DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U1 (
    .a(inst_a),
    .b(inst_b),
    .c(inst_c),
    .rnd(inst_rnd),
    .z(z_inst),
    .status(status_inst) 
  );

endmodule: DW_fp_mac_inst */