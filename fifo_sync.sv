`timescale 1ns / 1ps

module fifo_sync #( parameter int DEPTH=256,
                    parameter int WIDTH=8
                    )(input logic clk,
                     input logic reset,
                     input logic write_en,
                     input logic read_en,
                     input logic [WIDTH-1:0] data_in,
                     output logic [WIDTH-1:0] data_out,
                     output logic full,
                     output logic empty
                     );
localparam int width_addr = $clog2(DEPTH) ;                   
logic [WIDTH-1:0] mem [DEPTH-1:0];  
logic [width_addr:0] w_ptr, r_ptr;

logic [width_addr-1:0] w_addr, r_addr;
assign w_addr = w_ptr [width_addr-1:0];
assign r_addr = r_ptr [width_addr-1:0];

logic w_wrap, r_wrap;
assign w_wrap = w_ptr [width_addr];
assign r_wrap = r_ptr [width_addr];


assign empty = (w_ptr == r_ptr);                         
assign full = ((w_addr == r_addr) && (w_wrap != r_wrap));

logic do_write, do_read;
assign do_write = (write_en && ! full);
assign do_read = (read_en && !empty);

always_ff @(posedge clk) begin 
if (reset) begin 
data_out <= '0;
w_ptr <= '0;
r_ptr <= '0;
end else begin
if (do_write) begin 
mem [w_addr]<=data_in;
w_ptr <= w_ptr +1;
end
if (do_read) begin 
data_out <= mem[r_addr];
r_ptr <= r_ptr +1;
end

end

end //always_ff
     
                  
endmodule
