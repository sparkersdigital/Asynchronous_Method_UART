/////////////////////////////////////////////////////////////////////
//                          ______                     
//  _________        .---"""      """---.              
// :______.-':      :  .--------------.  :             
// | ______  |      | :                : |             
// |:______B:|      | |   phinx was  : | |             
// |:______B:|      | |     here       | |             
// |:______B:|      | |                | |             
// |         |      | |                | |             
// |:_____:  |      | |                | |             
// |    ==   |      | :                : |             
// |       O |      :  '--------------'  :             
// |       o |      :'---...______...---'              
// |       o |-._.-i___/'             \._              
// |'-.____o_|   '-.   '-...______...-'  `-._          
// :_________:      `.____________________   `-.___.-. 
//                  .'.eeeeeeeeeeeeeeeeee.'.      :___:
//                .'.eeeeeeeeeeeeeeeeeeeeee.'.         
//               :____________________________: 
/////////////////////////////////////////////////////////////////////
module UART_RX1(clk,rst,data_in,d_num,s_num,par,available,Buffer_out,error);
      /**********INPUTS**********/
  input clk;   //Rx clk faster than tx clk 16 time
  input rst;
  //low for reset the system 
  input data_in;   //input serial data
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
        /**********OUTPUTS**********/
  output available;
  //Low while buffering data
  //High ready to catch data from Rx
  output reg [7:0]Buffer_out;
  output reg error;
  //High...parity error detected
  //Low...no parity error detected
  //Don't care...no parity
      /**********REGISTERS**********/
  reg [3:0]  state;
  reg [3:0]  samp_count; //over sampling counter
  reg [15:0] samp_buffer; //over sampling buffer which contain the 8/16 readings 
  reg [7:0]  data_out;
      /**********WIRES**********/
  //wire maj8;  //major of sampling buffer first 8bits indicator
  wire MajorOUT; //major of sampling buffer indicator
     /**********STATE PARAMETERS**********/
     parameter idle   = 4'd0;
     parameter check  = 4'd1;
     parameter start  = 4'd2;
  // state 3=>10 Data
     parameter parity = 4'd11;
     parameter stop1  = 4'd12;
     parameter stop2  = 4'd13;
  /************************************/
  
  //assign maj8  = major8(samp_buffer);
  assign MajorOUT = major(samp_buffer,state);
  /***********COMPININTIALS ASSIGN**************/
 // assign Buffer_out = d_num ? data_out : {1'b0 , data_out[7:1]};
  assign available = (state == idle || (state == stop1 && samp_count != 1'd1) || state == stop2 || state == check)? 1'b1 : 1'b0 ;
//  assign Buffer_out = (available)? data_out : 8'd0;
  /************************************/
  
  always@(posedge clk)
  begin
       if (~rst)
     begin //reset = 0 
        state     <= idle;
        data_out   <= 8'd0;
        samp_count  <=  4'd0;
        samp_buffer  <= 16'd0;
        Buffer_out    <= 8'd0;
        error          <=  1'd0;
     end //reset = 0 
     else 
       begin //reset = 1
       case(state)
       idle : begin
                if(data_in) begin
                  state <= idle;  
                end else begin 
                     Sample;
                     state <= check;
                end //else
              end //idle
      check : begin 
                 
               if(samp_count == 4'd0) begin//sample finish
                 if (MajorOUT) begin
                  state <= idle;
                  end else begin
                  Sample;//anyway
                  state <= start;
                 end
               end else begin //sample finish
                 Sample;//anyway
             end
                 
            end //check
      start : begin 
        
         Sample;//anyway
               if(samp_count == 4'd0) begin//sample finish
                 if (MajorOUT)
                  state <= idle;
                else
                  state <= state + 1; //data state range
               end //sample finish
                 
            end //start      
        //Data sampling start
        4'd3 , 4'd4 ,4'd5 , 4'd6 ,4'd7 , 4'd8 : begin //data state range
          Sample;
           if(samp_count == 4'd0) begin
                 state <= state + 1;
                 DataOutShift; //check out again where data in became 9bits insh'allah
            end
          end//Data sampling
          //the 7th data bit 
       4'd9 : begin 
                  Sample; 
                   if(samp_count == 4'd0)
                   begin
                      DataOutShift; //check out again where data in became 9bits insh'allah
                     if(d_num)
                       begin
                         state     <= 4'd10;
                  //       available <= 1'b1;
                       end else  
                        begin
                          if(par == 2'b00 || par == 2'b11 )
                             begin  //no parity bit
                               state <= stop1;
                               error <= 1'b0; //but there's no error check
                               
                             end
                          else
                              begin
                               state <= parity;
                              end //par
                        end //else(d_num = 0)
                    end //sampling finished
             end //7th data bit state
       4'd10  : begin
                  Sample; 
                   if(samp_count == 4'd0)
                   begin
                      DataOutShift; //check out again where data in became 9bits insh'allah
                        if(par == 2'b00 || par == 2'b11 )
                             begin  //no parity bit
                               state <= stop1;
                               error <= 1'b0; //but there's no error check
                              
                             end
                          else
                              begin
                               state <= parity;
                              end //par
                   end //sampling data
                 end //8th data bit state
                       
       parity :  begin
                  Sample;
                  if (par == 2'b01)
                  begin   
                     if(samp_count == 4'd0) begin
                        if(MajorOUT == parityCheck(data_out,d_num))
                          begin
                            error      <= 1'b0;
                            state      <= stop1;
                          end
                        else
                          begin 
                            error <= 1'b1;
                            state <= stop1;
                          end
                 end //sampling finished
                      end //else(odd parity)    
               else if (par==2'b10)
                      begin    
                   if(samp_count == 4'd0) begin
                        if(MajorOUT == parityCheck(~data_out,d_num))
                          begin
                            error <= 1'b0;
                            state <= stop1;
                          end
                        else
                          begin 
                            error <= 1'b1;
                            state <= stop1;
                          end
                 end //sampling finished
                      end //else(even parity)   
                    end //parity state
                        
        stop1: begin 
               Buffer_out <= d_num ? data_out : {1'b0 , data_out[7:1]};        
               if(s_num) //one stop bit
                begin
                  if(samp_count == 4'd0)
                    begin
                      
                      if(data_in)
                        begin
                          state <= idle;
                        end // data_in = 1
                      else begin
                        Sample;
                        state <= check;
                      end //else(data_in = 0)
                    end //sampling done
                  else begin
                    Sample;
                  end //counting to sample
                end //(one stop bit)
              else //two stop bits
                begin
                  state <= stop2;
                end //else(two stop bits)
              end //stop1 state
        stop2 : begin
                 Sample;
                  if(samp_count == 4'd0)
                    begin
                      if(data_in)
                        begin
                          state <= idle;
                        end // data_in = 1
                      else begin
                        Sample;
                        state <= check;
                      end //else(data_in = 0)
                    end //sampling done
                    else begin
                    Sample;
                  end //counting to sample
                end //stop2 state
         endcase
       end//reset = 1
  end
  
  task DataOutShift;
   // begin data_out <= ( data_out << 1  ) | {7'd0,MajorOUT} ; end
   begin data_out <= ( data_out >> 1  ) | {MajorOUT,7'd0} ; end 
endtask
  
  task Sample;
    begin
      //over sampling counting 
      if ((state == check || state == start) && (samp_count == 4'd7))
        samp_count <= 4'd0;
      else
        samp_count <= samp_count + 1;
      //LA fine
      
      //samp_buffer shift with data_in registing
        samp_buffer <= (samp_buffer << 1) | {15'd0,data_in} ;
    end
  endtask
  
  
function parityCheck ;
      
   input [7:0] a;
   input data_num;
   
   begin //function  
   if (data_num)
   begin  //8bit data
   parityCheck = a[0] ^ a[1] ^ a[2] ^ a[3] ^ a[4] ^ a[5] ^ a[6] ^ a[7]; 
   // parity = 1 when NO.ones is odd
   end //8bit data
   else
   begin //7bit data
   parityCheck = a[0] ^ a[1] ^ a[2] ^ a[3] ^ a[4] ^ a[5] ^ a[6];
   end //7bit data
   end //function
   endfunction 
   

function  major;
input [15:0]a;
input [3:0]stat;
integer count,i;
begin
count = 0 ; i = 0;

  case(stat) 
 4'd0 , 4'd1 : begin
     for (i=0; i<8; i=i+1)
        begin
          if (a[i]) begin count = count + 1;end
        end

  major = count > 3 ? 1 : 0;
end
default: begin
  
     for (i=0; i<16; i=i+1)
        begin
          if (a[i]) begin count = count + 1;end
        end

major = count > 7 ? 1 : 0;
 end
endcase

end
endfunction
   
  
   
endmodule


