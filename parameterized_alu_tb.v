module parameterized_alu_tb;
parameter N = 8;
reg  [N-1:0] A;
reg  [N-1:0] B;
reg  [2:0]   S;
wire [N-1:0] Y;
wire Carry;
wire Overflow;
wire Parity;
wire Zero;
wire Sign;

parameterized_alu #(N) DUT(
    .A(A),
    .B(B),
    .S(S),
    .Y(Y),
    .Carry(Carry),
    .Overflow(Overflow),
    .Parity(Parity),
    .Zero(Zero),
    .Sign(Sign)
);

initial begin

    // NAND
    A = 8'b10101010;
    B = 8'b11001100;
    S = 3'b000;
    #10;
    S = 3'b001;
    #10;

    A = 8'd25;
    B = 8'd15;
    S = 3'b010;
    #10;

    A = 8'b10101010;
    B = 8'b00000000;
    S = 3'b011;
    #10;

    A = 8'b00001111;
    S = 3'b100;
    #10;
    
    A = 8'b11110000;
    S = 3'b101;
    #10;

    // 2'S COMPLEMENT
    A = 8'b00000101;  
    S = 3'b110;
    #10;

    A = 8'd20;
    B = 8'd8;
    S = 3'b111;
    #10;
    
    // ZERO FLAG CHECK
    A = 8'd10;
    B = 8'd10;
    S = 3'b111;        // 10 - 10 = 0
    #10;

    A = 8'd5;
    B = 8'd10;
    S = 3'b111;        // 5 - 10 = negative
    #10;

    // OVERFLOW CHECK ADDITION
    A = 8'b01111111;   // +127
    B = 8'b00000001;   // +1
    S = 3'b010;        // overflow
    #10;

    // OVERFLOW CHECK SUBTRACTION
    A = 8'b10000000;   // -128
    B = 8'b00000001;   // +1
    S = 3'b111;        // overflow
    #10;

    $finish;

end
initial begin
    $monitor("Time=%0t | A=%b | B=%b | S=%b | Y=%b | Carry=%b | Overflow=%b | Parity=%b | Zero=%b | Sign=%b",
              $time, A, B, S, Y, Carry, Overflow, Parity, Zero, Sign);
end

endmodule