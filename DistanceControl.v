module DistanceControl(
	input clock,
	output trig,
	input echo,
	output wire motorL,
	output wire motorR,
	output reg led1,
	input qtiL,
	input qtiR,
	input reset_regulatora
);
reg [32:0] distance;
reg [32:0] us_counter = 0;
reg ptrig = 1'b0;

reg[15:0] brojac; //Brojač
reg[15:0] impuls; 
reg[15:0] izlaz; 
reg[15:0] outL; 
reg[15:0] outR;

parameter kp=2; 
parameter kd=0; 
parameter ki=0;
parameter k1=kp+ ki + kd; 
parameter k2 = -kp -2*kd;
parameter k3 = kd; 
reg signed [15:0] u_prev; 
reg signed [15:0] e_prev[1:2];

reg signed [31:0] u_out;
reg signed [15:0] e_in;

reg [9:0] one_us_cnt = 0;
wire one_us = (one_us_cnt == 0);

reg [9:0] ten_us_cnt = 0;
wire ten_us = (ten_us_cnt == 0);

reg [21:0] forty_ms_cnt = 0;
wire forty_ms = (forty_ms_cnt == 0);

assign trig = ptrig;

// ULTRASONICNI
always @(posedge clock) begin
	one_us_cnt <= (one_us ? 50 : one_us_cnt) - 1;
	ten_us_cnt <= (ten_us ? 500 : ten_us_cnt) - 1;
	forty_ms_cnt <= (forty_ms ? 2000000 : forty_ms_cnt) - 1;
	
	if (ten_us && ptrig)
		ptrig <= 1'b0;
	
	if (one_us) begin	
		if (echo)
			us_counter <= us_counter + 1;
		else if (us_counter) begin
			distance <= us_counter / 58;
			us_counter <= 0;
		end
	end
	
   if (forty_ms)
		ptrig <= 1'b1;
		
	if(distance <= 32'd5)
		led1 = 1'b1;
	else
		led1 = 1'b0;
end


//PID
 always @ (posedge clock)

 begin
 
 e_in <= 10 - u_prev;
 e_prev[2] <= e_prev[1]; 
 e_prev[1] <= e_in;
 u_prev <= distance; 
 u_out=(u_prev+k1*e_in-k2*e_prev[1]+k3*e_prev[2]) * (-1);
 end 

 // PWM
always@( posedge clock )
begin
if(distance < 16'd14)
impuls<=16'd0;
else if ((u_out)*1000 > 16'd10000)
impuls<=16'd10000;
else
impuls <= (u_out)*1000;

//impuls<=16'd5000; // duty cycle on 0 - 100% -> 0 - 20000  
if( brojac<impuls ) 
begin
izlaz<=16'b1;
brojac<=brojac+16'd1;
end

else if( brojac >= impuls && brojac < 16'd20000 ) //Frekvencija 2.5kHz

begin
brojac<=brojac+16'd1;
izlaz<=16'b0;
end

else //Resetovanje brojača
brojac<=16'd0;

if(qtiL == 1 && qtiR == 1)
		begin
		outL = izlaz;
		outR = izlaz;
		end
else if (qtiL == 0 && qtiR == 1)
		begin
		outL = 16'd0;
		outR = izlaz;
		end	
else if (qtiL == 1 && qtiR == 0)
		begin
		outL = izlaz;
		outR = 16'd0;
		end	
else if (qtiL == 0 && qtiR == 0)
		begin
		outL = 16'd0;
		outR = 16'd0;
		end		
end

assign motorL =outL;
assign motorR =outR;
//Dodjeljivanje vrijednosti na izlazni pin, odnosno na motore
endmodule
