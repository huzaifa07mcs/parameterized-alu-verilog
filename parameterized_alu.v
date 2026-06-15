// PARAMETERIZED N-BIT STRUCTURAL ALU WITH FLAGS

module full_adder(
    input a, b, cin,
    output sum, cout
);
wire x1, a1, a2;
xor(x1, a, b);
xor(sum, x1, cin);
and(a1, a, b);
and(a2, x1, cin);
or(cout, a1, a2);
endmodule

module ripple_adder #(parameter N = 8)(
    input  [N-1:0] A,
    input  [N-1:0] B,
    input  Cin,
    output [N-1:0] Sum,
    output Cout
);

wire [N:0] carry;
assign carry[0] = Cin;
assign Cout = carry[N];

genvar i;

generate
    for(i = 0; i < N; i = i + 1) begin : FA_LOOP
        full_adder FA(
            .a(A[i]),
            .b(B[i]),
            .cin(carry[i]),
            .sum(Sum[i]),
            .cout(carry[i+1])
        );
    end
endgenerate

endmodule


module mux8to1 #(parameter N = 8)(
    input  [N-1:0] d0,d1,d2,d3,d4,d5,d6,d7,
    input  [2:0] sel,
    output reg [N-1:0] y
);

always @(*) begin
    case(sel)
        3'b000: y = d0;
        3'b001: y = d1;
        3'b010: y = d2;
        3'b011: y = d3;
        3'b100: y = d4;
        3'b101: y = d5;
        3'b110: y = d6;
        3'b111: y = d7;
        default: y = {N{1'b0}};
    endcase
end
endmodule

module parameterized_alu #(parameter N = 8)(
    input  [N-1:0] A,
    input  [N-1:0] B,
    input  [2:0] S,
    output [N-1:0] Y,
    output Carry,
    output Overflow,
    output Parity,
    output Zero,
    output Sign
);

wire [N-1:0] nand_out;
wire [N-1:0] xor_out;
wire [N-1:0] not_out;
wire [N-1:0] left_shift_out;
wire [N-1:0] right_shift_out;
wire [N-1:0] comp_out;
wire [N-1:0] add_out;
wire [N-1:0] sub_out;
wire [N-1:0] b_not;

wire add_cout, sub_cout, comp_cout;

genvar i;

// LOGIC OPERATIONS
generate
    for(i = 0; i < N; i = i + 1) begin : LOGIC_LOOP
        nand(nand_out[i], A[i], B[i]);
        xor(xor_out[i], A[i], B[i]);
        not(not_out[i], A[i]);
        not(b_not[i], B[i]);
    end
endgenerate
// ADD 
ripple_adder #(N) ADDER(
    .A(A),
    .B(B),
    .Cin(1'b0),
    .Sum(add_out),
    .Cout(add_cout)
);


// SUBTRACT 
ripple_adder #(N) SUBTRACTOR(
    .A(A),
    .B(b_not),
    .Cin(1'b1),
    .Sum(sub_out),
    .Cout(sub_cout)
);


// 2'S COMPLEMENT 
ripple_adder #(N) TWOS_COMP(
    .A(not_out),
    .B({N{1'b0}}),
    .Cin(1'b1),
    .Sum(comp_out),
    .Cout(comp_cout)
);

// SHIFT 
assign left_shift_out  = {A[N-2:0], 1'b0};
assign right_shift_out = {1'b0, A[N-1:1]};


// FINAL MUX
mux8to1 #(N) FINAL_MUX(
    .d0(nand_out),
    .d1(xor_out),
    .d2(add_out),
    .d3(not_out),
    .d4(left_shift_out),
    .d5(right_shift_out),
    .d6(comp_out),
    .d7(sub_out),
    .sel(S),
    .y(Y)
);

assign Carry = (S == 3'b010) ? add_cout :
               (S == 3'b111) ? ~sub_cout :
               1'b0;

assign Overflow = (S == 3'b010) ?
                  ((A[N-1] == B[N-1]) && (Y[N-1] != A[N-1])) :
                  (S == 3'b111) ?
                  ((A[N-1] != B[N-1]) && (Y[N-1] != A[N-1])) :
                  1'b0;

assign Parity = ~^Y;       
assign Zero   = (Y == {N{1'b0}});
assign Sign   = Y[N-1];

endmodule