module POSEDGE_GEN (
    input           [ 0 : 0]        clk,

    input           [ 0 : 0]        signal,
    output          [ 0 : 0]        signal_posedge
);

    reg signal_delay1, signal_delay2;

    initial begin
        signal_delay1 = 0;
        signal_delay2 = 0;
    end

    always @(posedge clk) begin
        signal_delay1 <= signal;
        signal_delay2 <= signal_delay1;
    end

    assign signal_posedge = signal_delay1 & ~signal_delay2;

endmodule
