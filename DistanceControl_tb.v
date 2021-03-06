`include "DistanceControl.v"
`timescale 1us/1ns

module DistanceControl_tb();

reg clk;
reg echo;
// wires                                               
reg qtiL;
reg qtiR;
wire motorL;
wire motorR;



// assign statements (if any)                          
DistanceControl UUT (
// port map - connection between master ports and signals/registers   
	.clk(clock),
	.echo(echo),
	.distance(distance),
	.qtiL(qtiL),
	.qtiR(qtiR),
	.motorL(motorL),
	.motorR(motorR)
);
 

initial                                                
begin
qtiL = 1'd0;
qtiR= 1'd0;
echo = 1'b0;
#1500
echo = 1'b1;
$display("length ~= 400 cm");
#2403800
echo = 1'b0;
$display("length ~= 19.22 cm");
#12000
echo = 1'b1;
#11600
echo = 1'b0;
#5000
$stop;
$display("Running testbench");
end                                                  
always begin                                                  
#25 clk = ~clk;
end

        
                                             
endmodule

