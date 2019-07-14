
module TX_div (clk,rst,bd_rate,clk_out,SYS_clk_call);
input clk,rst,SYS_clk_call;
input [1:0 ]bd_rate;
output clk_out;
 
 
    reg T9600;      //9600 baud rate
    reg T2400;     //2400 baud rate
    reg T4800;    //4800 baud rate
    reg T1200;   //1200 baud rate
    
    
    reg [11:0] TQ9600; //Counter
    reg [13:0] TQ2400; //Counter
    reg [12:0] TQ4800; //Counter

assign clk_out =    (!rst || SYS_clk_call) ? clk   //resetting bypass
                   :(bd_rate == 2'b00)? T1200
                   :(bd_rate == 2'b01)? T2400
                   :(bd_rate == 2'b10)? T4800
                   : T9600 ;

//9600
always @ (posedge(clk))   // trig of reset event handeler 
begin
    if ((rst == 1'b0) || (SYS_clk_call) || (bd_rate != 2'b11)) begin // resetting counter
        TQ9600  <= 12'b0; 
        T9600 <= 1'b1;
    end
    else begin
     if (TQ9600 == 12'd2603) begin
     TQ9600  <= 12'b0; 
     T9600 <= ~T9600; 
        end 
        else begin
       TQ9600 <= TQ9600 + 12'd1;
        end
    end
end


//2400 //1200
always @ (posedge(clk))   // trig of reset event handeler 
begin
    if ((rst == 1'b0) || (SYS_clk_call) || (bd_rate[1] == 1'b1)) begin // resetting counter
        TQ2400  <= 14'b0; 
        T2400 <= 1'b1;
        
        T1200 <= 1'b1;
    end
    else begin
     if (TQ2400 == 14'd10416) begin
     TQ2400  <= 14'b0; 
     T2400 <= ~T2400;
     
     if (bd_rate == 2'b00) begin
       T1200 <= T2400 ? ~T1200 : T1200;
     end
        end 
        else begin
       TQ2400 <= TQ2400 + 14'd1;
        end
    end
end


//4800
always @ (posedge(clk))   // trig of reset event handeler 
begin
    if ((rst == 1'b0) || (SYS_clk_call) || (bd_rate != 2'b10)) begin // resetting counter
        TQ4800  <= 13'b0; 
        T4800 <= 1'b1;
    end
    else begin
     if (TQ4800 == 13'd5207) begin
     TQ4800  <= 13'b0; 
     T4800 <= ~T4800; 
        end 
        else begin
       TQ4800 <= TQ4800 + 13'd1;
        end
    end
end



endmodule