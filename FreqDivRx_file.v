
module RX_div (clk,rst,bd_rate,clk_out);
input clk,rst;
input [1:0 ]bd_rate;
output clk_out;
 
 
 
reg [10:0] RQ1200; //Counter
reg  [9:0] RQ2400; //Counter
reg  [8:0] RQ4800; //Counter
reg  [7:0] RQ9600; //Counter

    reg R9600;      //9600 baud rate
    reg R2400;     //2400 baud rate
    reg R4800;    //4800 baud rate
    reg R1200;    //1200 baud rate
   assign clk_out = (!rst) ? clk //resetting bypass
                   :(bd_rate == 2'b00)? R1200
                   :(bd_rate == 2'b01)? R2400
                   :(bd_rate == 2'b10)? R4800
                   : R9600 ;
//9600
always @ (posedge(clk))   // trig of reset event handeler 
begin
    if ((rst == 1'b0) || (bd_rate != 2'b11)) begin // resetting counter
        RQ9600  <= 8'b0; 
        R9600 <= 1'b1;
    end
    else begin
     if (RQ9600 == 8'd162) begin
     RQ9600  <= 8'b0; 
     R9600 <= ~R9600; 
        end 
        else begin
       RQ9600 <= RQ9600 + 8'd1;
        end
    end
end


//2400
always @ (posedge(clk))   // trig of reset event handeler 
begin
    if ((rst == 1'b0) || (bd_rate != 2'b01)) begin // resetting counter
        RQ2400  <= 10'b0; 
        R2400 <= 1'b1;
    end
    else begin
     if (RQ2400 == 10'd650) begin
     RQ2400  <= 10'b0; 
     R2400 <= ~R2400; 
        end 
        else begin
       RQ2400 <= RQ2400 + 10'd1;
        end
    end
end


//4800
always @ (posedge(clk))   // trig of reset event handeler 
begin
    if ((rst == 1'b0) || (bd_rate != 2'b10)) begin // resetting counter
        RQ4800  <= 9'b0; 
        R4800 <= 1'b1;
    end
    else begin
     if (RQ4800 == 9'd325) begin
     RQ4800  <= 9'b0; 
     R4800 <= ~R4800; 
        end 
        else begin
       RQ4800 <= RQ4800 + 9'd1;
        end
    end
end

//1200
always @ (posedge(clk))   // trig of reset event handeler 
begin
    if ((rst == 1'b0) || (bd_rate != 2'b00)) begin // resetting counter
        RQ1200  <= 11'b0; 
        R1200 <= 1'b1;
    end
    else begin
     if (RQ1200 == 11'd1301) begin
     RQ1200  <= 11'b0; 
     R1200 <= ~R1200; 
        end 
        else begin
       RQ1200 <= RQ1200 + 11'd1;
        end
    end
end

endmodule