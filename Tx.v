module UART_Tx(rst, clk, flag, data_out, available, data_in, d_num, s_num, par ,CLKstretch);
  
                               /*******inputs*******/ 
  input [7:0] data_in;
  input clk; 
  //INPUT CLOCK FROM BAUDRATE GEN
  input rst;
  //active low reset.
  input d_num; 
  //High for 8 bits of data.
  //Low for 7 bits of data.
  input s_num;
  //High for 1 stop-bit.
  //Low for 2 stop-bits.
  input [1:0] par;
  //00BIN  for no parity used. 
  //01BIN  for odd parity used.
  //10BIN  for even parity used outputs.
  //11BIN  for no parity used.
   input flag ; //start sending data flag.
  //0BIN no data sending
  //1BIN start sending data
  
                             ////////////////////////////////////                             
                               /******wires & registers*******/
                               
 reg [3:0] state ; //FSM.
 reg [7:0] data ; 
                            ////////////////////////////////////
                                   /******outputs******/
  output reg CLKstretch;                                 
  output reg data_out ;
  output reg available; // High at line availability. 
  
                           ////////////////////////////////////
                                       /*Block one*/
  
  
  
  //sending data    
 always @(posedge clk)
 begin //block1
     if (rst == 1'b0 )
     begin //reset = 0 
        data_out  <= 1'b1 ;
        data       <= 8'd0;
        state       <= 4'b0000 ;
        available    <= 1'b0;
        CLKstretch    <= 1'b1;
     end //reset = 0 
     else 
     begin //reset = 1
        case (state) 
        4'b0000 : begin  //idle //2nd stop bit 
                     available    <= 1 ;                
                     if (flag) 
                        begin ///flag = 1                          
                          state <= 4'b0001 ; 
                        end ///
                     else
                       begin ////flag = 0 
                       state <= 4'b0000 ;
                       data_out     <= 1'b1;
                       CLKstretch   <= 1'b1;
                       end //// 
                  end  //  
                                    
        4'b0001 : begin  //start
                  CLKstretch   <= 1'b0;
                  data_out <= 1'b0 ;
                  data <= data_in ;
                  available <= 0 ; 
                  state <= 4'b0010;
                  end //
                  
        4'b0010 : begin  //D7
                  data_out <= data[0] ;
                  state <= 4'b0011 ;
                  end //
                  
        4'b0011 : begin  //D6
                  data_out <= data[1] ;
                  state <= 4'b0100 ;
                  end //
                  
        4'b0100 : begin  //D5
                  data_out <= data[2] ;
                  state <= 4'b0101 ;
                  end //
                  
        4'b0101 : begin  //D4
                  data_out <= data[3] ;
                  state <= 4'b0110 ;
                  end //
                  
        4'b0110 : begin  //D3
                  data_out <= data[4] ;
                  state <= 4'b0111 ;
                  end //
                  
        4'b0111 : begin  //D2
                  data_out <= data[5] ;
                  state <= 4'b1000 ;
                  end //
                  
        4'b1000 : begin  //D1
                  data_out <= data[6] ;
                  if (d_num)
                     begin ///d_num = 1 .. 8 data bit 
                        state <= 4'b1001 ;
                     end ///
                  else if (par ==  2'b00 || par == 2'b11)
                            begin ////d_num = 0 .. 7 data bit
                              state <= 4'b1011;
                            end ////
                       else  
                            begin
                              state <= 4'b1010 ;
                            end 
                     
                  end //
                  
        4'b1001 : begin  //D0
                     data_out <= data[7] ;
                     if (par == 2'b00 || par == 2'b11) //8bit no parity
                       begin 
                         state <= 4'b1011;
                       end 
                     else 
                       begin 
                         state <= 4'b1010 ;
                       end                  
                  end //
                  
        4'b1010 : begin  //parity
                   if (par == 2'b01 )
                     begin ////odd parity
                     data_out <= parity(data,d_num) ; 
                     state <= 4'b1011 ; 
                     end ////
                  else
                     begin /////even parity
                     data_out <= ~parity(data,d_num) ; 
                     state <= 4'b1011 ; 
                     end /////
                  end //
                  
        4'b1011 : begin  //stop1
                  data_out <= 1'b1 ;
                 // state    <= 4'b0000 ; 
                    if (s_num) 
                     begin 
                     if (flag) begin///flag = 1   and 1 stop bit
                          state <= 4'b0001 ; 
                          available <= 1 ;
                        end else begin state <= 4'b0000 ; end                        
                    end else begin // 2 stop bits
                       available <= 1 ;
                       state <= 4'b1100 ; 
                       end //// 
                  end //
        4'b1100 : begin  //idle //2nd stop bit 
                     data_out <= 1'b1 ;     
                     available <= 1 ;                
                     if (flag) 
                        begin ///flag = 1  
                          state <= 4'b0001 ;                        
                        end ///
                     else
                       begin ////flag = 0 
                       state <= 4'b0000 ;
                       end //// 
                  end  //  
        default : data_out <= 1 ; 
       
        endcase
         
     end  //reset
 end//block1
 
function parity ;
      
   input [7:0] a;
   input dnum;
   
   begin //function  
   if (dnum == 1'b1 )
   begin  //8bit data
   parity = a[0] ^ a[1] ^ a[2] ^ a[3] ^ a[4] ^ a[5] ^ a[6] ^ a[7]; 
   // parity = 1 when NO.ones is odd
   end //8bit data
   else
   begin //7bit data
   parity = a[0] ^ a[1] ^ a[2] ^ a[3] ^ a[4] ^ a[5] ^ a[6];
   end //7bit data
   end //function
   endfunction 

  
endmodule


