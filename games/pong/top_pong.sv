// Project F: FPGA Pong - Pong Game (for the Keks game console)
// (C)2023 Will Green, open source hardware released under the MIT License
// (C)2023 Lone Dynamics Corporation
// Learn more at https://projectf.io/posts/fpga-pong/

`default_nettype none
`timescale 1ns / 1ps

module top_pong (
    input  wire logic CLK_100,      // 100 MHz clock
    input  wire logic RP_INT,
    input  wire logic RP_TX,
    output wire logic DDMI_CK_P, DDMI_D2_P, DDMI_D1_P, DDMI_D0_P,
    output wire logic DDMI_CK_N, DDMI_D2_N, DDMI_D1_N, DDMI_D0_N,
    output wire logic PMOD_A1, PMOD_A2, PMOD_A3, PMOD_A4, PMOD_A7, PMOD_A8, PMOD_A9, PMOD_A10,
    output wire logic PMOD_B1, PMOD_B2, PMOD_B3, PMOD_B4, PMOD_B7, PMOD_B8, PMOD_B9, PMOD_B10,
	input wire logic BTN
    );

    // gameplay parameters
    localparam WIN        =  4;  // score needed to win a game (max 9)
    localparam SPEEDUP    =  5;  // speed up ball after this many shots (max 16)
    localparam BALL_SIZE  =  8;  // ball size in pixels
    localparam BALL_ISPX  =  5;  // initial horizontal ball speed
    localparam BALL_ISPY  =  3;  // initial vertical ball speed
    localparam PAD_HEIGHT = 128;  // paddle height in pixels
    localparam PAD_WIDTH  = 10;  // paddle width in pixels
    localparam PAD_OFFS   = 32;  // paddle distance from edge of screen in pixels
    localparam PAD_SPY    =  10;  // vertical paddle speed

    // keks interface
    logic clk_100mhz = CLK_100;
    logic [119:0] gamepad;

    rpint #() rpint_i (
        .clk(clk_pix),
        .resetn(resetn),
        .ldata(gamepad),
        .sclk(RP_INT),
        .mosi(RP_TX),
    );

    reg [7:0] dir = gamepad[71:64];
    reg [7:0] btns = gamepad[63:56];

	 //always_comb { PMOD_B1, PMOD_B2, PMOD_B3, PMOD_B4, PMOD_B7, PMOD_B8, PMOD_B9, PMOD_B10 } = dir;
	 always_comb { PMOD_A1, PMOD_A2, PMOD_A3, PMOD_A4, PMOD_A7, PMOD_A8, PMOD_A9, PMOD_A10 } = btns;

	logic PMOD_B2 = BTN;

    logic btn_fire = (btns != 4'b0000);
//    logic btn_up   = (dir == 8'h01);
//    logic btn_dn   = (dir == 8'h05);
    logic sig_up   = (dir == 8'h01);
    logic sig_dn   = (dir == 8'h05);

    reg [11:0] resetn_counter = 0;
    wire resetn = &resetn_counter;

    always @(posedge clk_100mhz) begin
       if (!clk_pix_locked)
          resetn_counter <= 0;
       else if (!resetn)
          resetn_counter <= resetn_counter + 1;
    end

    // generate pixel clock
    logic clk_x5;
    logic clk_pix;
    logic clk_pix_locked;
    pll125 pll125_i(clk_100mhz, clk_x5, clk_pix_locked);
    reg [4:0] clk_25mhz = 5'b000_11;
    always_ff @(posedge clk_x5) begin
        clk_25mhz <= {clk_25mhz[0], clk_25mhz[4:1]};
    end
    assign clk_pix = clk_25mhz[0];

    // display sync signals and coordinates
    localparam CORDW = 10;  // screen coordinate width in bits
    logic [CORDW-1:0] sx, sy;
    logic hsync, vsync, de;
    simple_480p display_inst (
        .clk_pix,
        .rst_pix(!clk_pix_locked),  // wait for clock lock
        .sx,
        .sy,
        .hsync,
        .vsync,
        .de
    );

   // hdmi output
   logic [1:0] out_tmds_red;
   logic [1:0] out_tmds_green;
   logic [1:0] out_tmds_blue;
   logic [1:0] out_tmds_clk;

   logic [3:0] dvi_p;
   logic [3:0] dvi_n;

   always_comb { DDMI_CK_P, DDMI_D2_P, DDMI_D1_P, DDMI_D0_P } = dvi_p;
   always_comb { DDMI_CK_N, DDMI_D2_N, DDMI_D1_N, DDMI_D0_N } = dvi_n;

   SB_LVCMOS SB_LVCMOS_RED (.DP(dvi_p[2]), .DN(dvi_n[2]), .clk_x5(clk_x5),
      .tmds_signal(out_tmds_red));
   SB_LVCMOS SB_LVCMOS_GREEN (.DP(dvi_p[1]), .DN(dvi_n[1]), .clk_x5(clk_x5),
      .tmds_signal(out_tmds_green));
   SB_LVCMOS SB_LVCMOS_BLUE (.DP(dvi_p[0]), .DN(dvi_n[0]), .clk_x5(clk_x5),
      .tmds_signal(out_tmds_blue));
   SB_LVCMOS SB_LVCMOS_CLK (.DP(dvi_p[3]), .DN(dvi_n[3]), .clk_x5(clk_x5),
      .tmds_signal(out_tmds_clk));

   hdmi_device #(
      .DDR_ENABLED(1)
   ) hdmi_device_i (
      .pclk(clk_pix),
      .tmds_clk(clk_x5),
      .in_vga_red({ display_r, 4'b0000 }),
      .in_vga_green({ display_g, 4'b0000 }),
      .in_vga_blue({ display_b, 4'b0000 }),
      .in_vga_blank(!de),
      .in_vga_vsync(vsync),
      .in_vga_hsync(hsync),
      .out_tmds_red(out_tmds_red),
      .out_tmds_green(out_tmds_green),
      .out_tmds_blue(out_tmds_blue),
      .out_tmds_clk(out_tmds_clk)
    );

    // screen dimensions (must match display_inst)
    localparam H_RES = 640;  // horizontal screen resolution
    localparam V_RES = 480;  // vertical screen resolution

    logic frame;  // high for one clock tick at the start of vertical blanking
    always_comb frame = (sy == V_RES && sx == 0);

    // scores
    logic [3:0] score_l;  // left-side score
    logic [3:0] score_r;  // right-side score

    // drawing signals
    logic ball, padl, padr;

    // ball properties
    logic [CORDW-1:0] ball_x, ball_y;  // position (origin at top left)
    logic [CORDW-1:0] ball_spx;        // horizontal speed (pixels/frame)
    logic [CORDW-1:0] ball_spy;        // vertical speed (pixels/frame)
    logic [3:0] shot_cnt;              // shot counter
    logic ball_dx, ball_dy;            // direction: 0 is right/down
    logic ball_dx_prev;                // direction in previous tick (for shot counting)
    logic coll_r, coll_l;              // screen collision flags

    // paddle properties
    logic [CORDW-1:0] padl_y, padr_y;  // vertical position of left and right paddles
    logic [CORDW-1:0] ai_y, play_y;    // vertical position of AI and player paddle

    // link paddles to AI or player
    always_comb begin
        padl_y = play_y;
        padr_y = ai_y;
    end

    // debounce buttons
    logic sig_fire, sig_up, sig_dn;
    /* verilator lint_off PINCONNECTEMPTY */
    debounce deb_fire (.clk(clk_pix), .in(btn_fire), .out(), .ondn(), .onup(sig_fire));
//    debounce deb_up (.clk(clk_pix), .in(btn_up), .out(sig_up), .ondn(), .onup());
//    debounce deb_dn (.clk(clk_pix), .in(btn_dn), .out(sig_dn), .ondn(), .onup());
    /* verilator lint_on PINCONNECTEMPTY */

    // game state
    enum {NEW_GAME, POSITION, READY, POINT, END_GAME, PLAY} state, state_next;
    always_comb begin
        case (state)
            NEW_GAME: state_next = POSITION;
            POSITION: state_next = READY;
            READY: state_next = (sig_fire) ? PLAY : READY;
            POINT: state_next = (sig_fire) ? POSITION : POINT;
            END_GAME: state_next = (sig_fire) ? NEW_GAME : END_GAME;
            PLAY: begin
                if (coll_l || coll_r) begin
                    if ((score_l == WIN) || (score_r == WIN)) state_next = END_GAME;
                    else state_next = POINT;
                end else state_next = PLAY;
            end
            default: state_next = NEW_GAME;
        endcase
        if (!resetn) state_next = NEW_GAME;
    end

    // update game state
    always_ff @(posedge clk_pix) state <= state_next;

    // AI paddle control
    always_ff @(posedge clk_pix) begin
        if (state == POSITION) ai_y <= (V_RES - PAD_HEIGHT)/2;
        else if (frame && state == PLAY) begin
            if (ai_y + PAD_HEIGHT/2 < ball_y) begin  // ball below
                if (ai_y + PAD_HEIGHT + PAD_SPY >= V_RES-1) begin  // bottom of screen?
                    ai_y <= V_RES - PAD_HEIGHT - 1;  // move down as far as we can
                end else ai_y <= ai_y + PAD_SPY;  // move down
            end else if (ai_y + PAD_HEIGHT/2 > ball_y + BALL_SIZE) begin // ball above
                if (ai_y < PAD_SPY) begin  // top of screen
                    ai_y <= 0;  // move up as far as we can
                end else ai_y <= ai_y - PAD_SPY;  // move up
            end
        end
    end

    // Player paddle control
    always_ff @(posedge clk_pix) begin
        if (state == POSITION) play_y <= (V_RES - PAD_HEIGHT)/2;
        else if (frame && state == PLAY) begin
            if (sig_dn) begin
                if (play_y + PAD_HEIGHT + PAD_SPY >= V_RES-1) begin  // bottom of screen?
                    play_y <= V_RES - PAD_HEIGHT - 1;  // move down as far as we can
                end else play_y <= play_y + PAD_SPY;  // move down
            end else if (sig_up) begin
                if (play_y < PAD_SPY) begin  // top of screen
                    play_y <= 0;  // move up as far as we can
                end else play_y <= play_y - PAD_SPY;  // move up
            end
        end
    end

    // ball control
    always_ff @(posedge clk_pix) begin

        case (state)
            NEW_GAME: begin
                score_l <= 0;  // reset score
                score_r <= 0;
            end

            POSITION: begin
                coll_l <= 0;  // reset screen collision flags
                coll_r <= 0;
                ball_spx <= BALL_ISPX;  // reset speed
                ball_spy <= BALL_ISPY;
                shot_cnt <= 0;  // reset shot count

                // centre ball vertically and position on paddle (right or left)
                ball_y <= (V_RES - BALL_SIZE)/2;
                if (coll_r) begin
                    ball_x <= H_RES - (PAD_OFFS + PAD_WIDTH + BALL_SIZE);
                    ball_dx <= 1;  // move left
                end else begin
                    ball_x <= PAD_OFFS + PAD_WIDTH;
                    ball_dx <= 0;  // move right
                end
            end

            PLAY: begin
                if (frame) begin
                    // horizontal ball position
                    if (ball_dx == 0) begin  // moving right
                        if (ball_x + BALL_SIZE + ball_spx >= H_RES-1) begin
                            ball_x <= H_RES-BALL_SIZE;  // move to edge of screen
                            score_l <= score_l + 1;
                            coll_r <= 1;
                        end else ball_x <= ball_x + ball_spx;
                    end else begin  // moving left
                        if (ball_x < ball_spx) begin
                            ball_x <= 0;  // move to edge of screen
                            score_r <= score_r + 1;
                            coll_l <= 1;
                        end else ball_x <= ball_x - ball_spx;
                    end

                    // vertical ball position
                    if (ball_dy == 0) begin  // moving down
                        if (ball_y + BALL_SIZE + ball_spy >= V_RES-1)
                            ball_dy <= 1;  // move up next frame
                        else ball_y <= ball_y + ball_spy;
                    end else begin  // moving up
                        if (ball_y < ball_spy)
                            ball_dy <= 0;  // move down next frame
                        else ball_y <= ball_y - ball_spy;
                    end

                    // ball speed increases after SPEEDUP shots
                    if (ball_dx_prev != ball_dx) shot_cnt <= shot_cnt + 1;
                    if (shot_cnt == SPEEDUP) begin  // increase ball speed
                        ball_spx <= (ball_spx < PAD_WIDTH) ? ball_spx + 1 : ball_spx;
                        ball_spy <= ball_spy + 1;
                        shot_cnt <= 0;
                    end
                end
            end
        endcase

        // change direction if ball collides with paddle
        if (ball && padl && ball_dx==1) ball_dx <= 0;  // left paddle
        if (ball && padr && ball_dx==0) ball_dx <= 1;  // right paddle

        // record ball direction in previous frame
        if (frame) ball_dx_prev <= ball_dx;
    end

    // check for ball and paddles at current screen position (sx,sy)
    always_comb begin
        ball = (sx >= ball_x) && (sx < ball_x + BALL_SIZE)
               && (sy >= ball_y) && (sy < ball_y + BALL_SIZE);
        padl = (sx >= PAD_OFFS) && (sx < PAD_OFFS + PAD_WIDTH)
               && (sy >= padl_y) && (sy < padl_y + PAD_HEIGHT);
        padr = (sx >= H_RES - PAD_OFFS - PAD_WIDTH - 1) && (sx < H_RES - PAD_OFFS - 1)
               && (sy >= padr_y) && (sy < padr_y + PAD_HEIGHT);
    end

    // draw the score
    logic pix_score;  // pixel of score char
    simple_score simple_score_inst (
        .clk_pix,
        .sx,
        .sy,
        .score_l,
        .score_r,
        .pix(pix_score)
    );

    // paint colour
    logic [3:0] paint_r, paint_g, paint_b;
    always_comb begin
        if (pix_score) {paint_r, paint_g, paint_b} = 12'hF30;  // score
        else if (ball) {paint_r, paint_g, paint_b} = 12'hFC0;  // ball
        else if (padl || padr) {paint_r, paint_g, paint_b} = 12'hFFF;  // paddles
        else {paint_r, paint_g, paint_b} = 12'h137;  // background
    end

    // display colour: paint colour but black in blanking interval
    logic [3:0] display_r, display_g, display_b;
    always_comb begin
        display_r = (de) ? paint_r : 4'h0;
        display_g = (de) ? paint_g : 4'h0;
        display_b = (de) ? paint_b : 4'h0;
    end

endmodule

module pll125(
    input  clock_in,
    output clock_out,
    output locked
);

    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),         // DIVR =  0
        .DIVF(7'b0001001),      // DIVF =  9
        .DIVQ(3'b011),          // DIVQ =  3
        .FILTER_RANGE(3'b101)   // FILTER_RANGE = 5
    ) uut (
        .LOCK(locked),
        .RESETB(1'b1),
        .BYPASS(1'b0),
        .REFERENCECLK(clock_in),
        .PLLOUTCORE(clock_out)
    );

endmodule
