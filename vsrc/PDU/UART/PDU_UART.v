/*
UART registers:
UART_BASE               0x00004400
UART_RX_DATA_READY      +0x00           Read-only, 1 if RX is ready to read, 0 if acked
UART_RX_DATA            +0x04           Read-only, byte received in RX
UART_RX_ACK             +0x08           Read-write, set to 1 to ack, 0 if ack received
UART_TX_ACK             +0x10           Read-only, set to 1 to ack, 0 if ack received
UART_TX_DATA            +0x14           Read-write, byte to transmit
UART_TX_DATA_READY      +0x18           Read-write, 1 if data is ready to transmit, 0 if acked
*/

module PDU_UART (
    input                   [ 0 : 0]            sys_clk             ,
    input                   [ 0 : 0]            sys_rst             ,

    input                   [31 : 0]            interface_addr      ,
    output          reg     [31 : 0]            interface_rdata     ,
    input                   [31 : 0]            interface_wdata     ,
    input                   [ 0 : 0]            interface_we        ,

    input                   [ 0 : 0]            uart_rxd            ,
    output                  [ 0 : 0]            uart_txd
);

    localparam UART_BASE = 32'h00008000;
    localparam UART_RX_DATA_READY = UART_BASE + 32'h00;
    localparam UART_RX_DATA = UART_BASE + 32'h04;
    localparam UART_RX_ACK = UART_BASE + 32'h08;
    localparam UART_TX_ACK = UART_BASE + 32'h10;
    localparam UART_TX_DATA = UART_BASE + 32'h14;
    localparam UART_TX_DATA_READY = UART_BASE + 32'h18;

    localparam UART_RX_QUEUE_DEPTH = 10;
    localparam UART_TX_QUEUE_DEPTH = 10;

    reg	 [31 : 0]   tx_data;
    wire [31 : 0]   rx_data;

    wire [ 0 : 0]   rx_enqueue_raw, rx_dequeue_raw;
    wire [ 0 : 0]   rx_enqueue, rx_dequeue, rx_queue_empty, rx_queue_full;
    wire [ 7 : 0]   rx_queue_head;
    wire [ 7 : 0]   rx_enqueue_data;

    wire [ 0 : 0]   tx_enqueue_raw, tx_dequeue_raw;
    wire [ 0 : 0]   tx_enqueue, tx_dequeue, tx_queue_empty, tx_queue_full;
    wire [ 7 : 0]   tx_queue_head;
    wire [ 7 : 0]   tx_enqueue_data;

    reg  [ 0 : 0]   uart_rx_data_ready;
    reg  [ 0 : 0]   uart_rx_ack;

    reg  [ 0 : 0]   uart_tx_data_ready;
    reg  [ 0 : 0]   uart_tx_ack;

/* -------------------------------- read data ------------------------------- */

    assign rx_data = {24'h0, rx_queue_head};

    always @(*) begin
        case (interface_addr)
            UART_RX_DATA_READY :
                interface_rdata = {31'B0, uart_rx_data_ready};
            UART_RX_DATA :
                interface_rdata = rx_data;
            UART_RX_ACK :
                interface_rdata = {31'B0, uart_rx_ack};
            UART_TX_ACK :
                interface_rdata = {31'B0, uart_tx_ack};
            UART_TX_DATA :
                interface_rdata = tx_data;
            UART_TX_DATA_READY :
                interface_rdata = {31'B0, uart_tx_data_ready};
            default :
                interface_rdata = 32'h0;
        endcase
    end

/* ------------------------------ rx handshake ------------------------------ */

    always @(*) begin
        if (uart_rx_ack) begin
            uart_rx_data_ready = 1'h0;
        end
        else begin
            uart_rx_data_ready = !rx_queue_empty;
        end
    end

    always @(posedge sys_clk) begin
        if (sys_rst) begin
            uart_rx_ack <= 1'h0;
        end
        else begin
            if (interface_we) begin
                if (interface_addr == UART_RX_ACK) begin
                    uart_rx_ack <= interface_wdata[0];
                end
            end
        end
    end

/* ----------------------------- rx queue logic ----------------------------- */

    POSEDGE_GEN rx_dequeue_gen(
        .clk                (sys_clk            ),
        .signal             (uart_rx_ack        ),
        .signal_posedge     (rx_dequeue         )
    );

/* ------------------------------ tx handshake ------------------------------ */

    always @(*) begin
        if (uart_tx_data_ready) begin
            uart_tx_ack = !tx_queue_full;
        end
        else begin
            uart_tx_ack = 1'h0;
        end
    end

    always @(posedge sys_clk) begin
        if (sys_rst) begin
            uart_tx_data_ready <= 1'h0;
        end
        else begin
            if (interface_we) begin
                if (interface_addr == UART_TX_DATA_READY) begin
                    uart_tx_data_ready <= interface_wdata[0];
                end
            end
        end
    end

/* ----------------------------- tx queue logic ----------------------------- */

    always @(posedge sys_clk) begin
        if (sys_rst) begin
            tx_data <= 32'h0;
        end
        else begin
            if (interface_we) begin
                if (interface_addr == UART_TX_DATA && !tx_queue_full) begin
                    tx_data <= interface_wdata;
                end
            end
        end
    end

    POSEDGE_GEN tx_enqueue_gen(
        .clk                (sys_clk            ),
        .signal             (uart_tx_data_ready ),
        .signal_posedge     (tx_enqueue         )
    );
    
    assign tx_enqueue_data = tx_data[7 : 0];

/* -------------------------- module instantiation -------------------------- */

    UART_RX uart_rx (
        .clk                (sys_clk            ),
        .rst                (sys_rst            ),
        .en                 (1'B1               ),
        .uart_rxd           (uart_rxd           ),
        .ready              (rx_enqueue_raw     ),
        .data               (rx_enqueue_data    )
    );

    QUEUE #(.DEPTH(UART_RX_QUEUE_DEPTH)) rx_queue (
        .clk                (sys_clk            ),
        .rst                (sys_rst            ),
        .en                 (1'B1               ),
        .enqueue            (rx_enqueue         ),
        .dequeue            (rx_dequeue         ),
        .enqueue_data       (rx_enqueue_data    ),
        .queue_head_data    (rx_queue_head      ),
        .empty              (rx_queue_empty     ),
        .full               (rx_queue_full      )
    );

    POSEDGE_GEN rx_enqueue_gen (
        .clk                (sys_clk            ),
        .signal             (rx_enqueue_raw     ),
        .signal_posedge     (rx_enqueue         )
    );

	UART_TX uart_tx (
		.clk				(sys_clk            ),
		.rst				(sys_rst            ),
		.en					(1'B1               ),
		.data				(tx_queue_head      ),
		.ready				(!tx_queue_empty    ),
		.transmitted		(tx_dequeue_raw     ),
		.uart_txd			(uart_txd           )
	);

    QUEUE #(.DEPTH(UART_TX_QUEUE_DEPTH)) tx_queue (
        .clk                (sys_clk            ),
        .rst                (sys_rst            ),
        .en                 (1'B1               ),
        .enqueue            (tx_enqueue         ),
        .dequeue            (tx_dequeue         ),
        .enqueue_data       (tx_enqueue_data    ),
        .queue_head_data    (tx_queue_head      ),
        .empty              (tx_queue_empty     ),
        .full               (tx_queue_full      )
    );

    POSEDGE_GEN tx_dequeue_gen (
        .clk                (sys_clk            ),
        .signal             (tx_dequeue_raw     ),
        .signal_posedge     (tx_dequeue         )
    );

endmodule