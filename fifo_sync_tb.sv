`timescale 1ns / 1ps

module fifo_sync_tb;
localparam int WIDTH=8, DEPTH=256;

logic clk=0;
logic reset;
logic write_en;
logic read_en;
logic [WIDTH-1:0] data_in;
logic [WIDTH-1:0] data_out;
logic full;
logic empty;

fifo_sync #(.DEPTH(DEPTH), .WIDTH(WIDTH)) dut(
  .clk(clk),     
  .reset (reset),     
  .write_en (write_en),
  .read_en (read_en),
  .data_in (data_in),
  .data_out (data_out),
  .full(full),  
  .empty (empty)
);

always  #5 clk = ~clk;
int write_done=0;
int read_count=0;
logic [WIDTH-1:0] expected=0;

initial begin 
write_en = 0;
read_en = 0;

reset=1;
repeat(2) @(posedge clk);
reset=0;
@(posedge clk);

$display ("==START CHECK THE FIFO==");
assert (full==0)
else $fatal ("ERROR: After reset release (reset=%b) : full=%b empty=%b ", reset, full, empty );
assert (empty==1)
else $fatal("ERROR: After reset release (reset=%b): empty=%b full=%b", reset, empty, full);


$display ("RESET TEST PASSED : full=%b empty=%b", full, empty);

data_in=8'h57;
write_en = 1;
@(posedge clk);
write_en=0;
@ (posedge clk);

assert (!empty)
else $fatal ("ERROR: write_en was 1 and fifo still empty empty=%b data_in=%h", empty, data_in);

read_en=1;
@ (posedge clk);
read_en=0;

#1; assert (data_out == 8'h57)
else $fatal("ERROR: data out incorrect. data_out=%h " , data_out);

assert(empty)
else $fatal ("ERROR: FIFO not empty after read ");

$display ("WRITE+READ TEST PASSED");

data_in=8'h11; write_en = 1; @(posedge clk); write_en = 0; #1;
assert (!empty) else $fatal ("FIFO should NOT be empty after write");
data_in=8'h22; write_en = 1; @(posedge clk); write_en = 0;#1;
data_in=8'h33; write_en = 1; @(posedge clk); write_en = 0;
assert (!full) else $fatal ("FIFO should NOT be full after only 3 writes");

read_en=1; @(posedge clk); read_en=0; #1; 
assert (data_out == 8'h11)
else $fatal ("Expected 11 got %h ", data_out);

read_en=1; @(posedge clk); read_en=0;#1;
assert (data_out == 8'h22)
else $fatal ("Expected 22 got %h ", data_out);

read_en=1; @(posedge clk); read_en=0;#1;
assert (data_out == 8'h33)
else $fatal ("Expected 33 got %h ", data_out);

assert (empty) else $fatal("FIFO should be empty after 3 writes and 3 reads");

$display ("The order of the FIFO is maintained");

$display("\n=== FILL FIFO TEST START ===");
write_done=0;
for (int i=0; i<260 ; i++)  begin
if (!full) begin 
data_in=i;
write_en=1;
@(posedge clk);
write_en=0;
#1;
write_done++;
end else begin
$display ("FIFO became full at %0d writes (next i=%0d)",write_done, i);
break;
end
end

#1; 
assert (full) else $fatal ("The FIFO should be full after 256 writes");
assert (!empty) else $fatal("The FIFO should not be empty when full");
$display("FLAG TEST PASSED: full=%0b empty=%0b", full, empty);

$display("\n=== DRAIN FIFO TEST START ===");
read_count=0;
expected=0;
while (empty == 1'b0) begin 
read_en=1;
@(posedge clk);
read_en=0;
#1;

assert (data_out == expected )
else $fatal("DATA MISMATCH: expected=%0h got=%0h", expected, data_out);
read_count++;
expected++;
if (read_count % 50 == 0)
  $display("Draining... read_count=%0d", read_count);
end

#1;
assert(read_count == DEPTH)
else $fatal("Expected 256 reads got=%0d", read_count);
assert(empty)
else $fatal("The FIFO should be empty after draining");

$display("DRAIN TEST PASSED: read_count=%0d empty=%0b", read_count, empty);
$display("\n=== ALL FIFO TESTS PASSED SUCCESSFULLY ===");

$finish;

end
endmodule
