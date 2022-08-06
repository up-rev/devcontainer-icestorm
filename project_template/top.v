module top(
    input clk,              // 100MHz clock
    output [7:0] led,       // 8 user controllable LEDs
    );
    
    wire rst ;
    wire clk_div;
    
    
    
    counter counter(.out(led),.clk(clk_div),.reset(rst));
    
    
endmodule