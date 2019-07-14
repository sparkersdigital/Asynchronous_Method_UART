module Atlas_ON_TOP_forSure(RXready,rst,clk,RXready,TXready,Send_flag,error,RX_IN,TX_out);
  wire clk_out_RX,clk_out_TX,CLKstretch;
  wire [7:0]Buffer_out;
  parameter bd_rate = 2'b01;
  parameter d_num = 1'b1;
  parameter s_num = 1'b1;
  parameter par   = 2'b00;
  input rst,clk,Send_flag,RX_IN;          ////////////only physical inputs
  output TX_out;                         ////////////only physical outputs
  wire [7:0] data_in;  //output OUT;
  output RXready,TXready,error;
  
  RX_div RX_div1(clk,rst,bd_rate,clk_out_RX);
  TX_div TX_div1(clk,rst,bd_rate,clk_out_TX,CLKstretch);
  
  UART_RX1 UART_RX11(clk_out_RX,rst,RX_IN,d_num,s_num,par,RXready,Buffer_out,error);
  UART_Tx  UART_Tx1(rst, clk_out_TX,~Send_flag, TX_out, TXready, data_in, d_num, s_num, par,CLKstretch);
  
  assign data_in = Buffer_out + 1;
  
  
endmodule
