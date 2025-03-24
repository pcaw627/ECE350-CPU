// module bypass_control (
//     input [31:0] dx_ir,
//     input [31:0] xm_ir,
//     input [31:0] mw_ir,
//     output [1:0] MX_select_A,
//     output [1:0] MX_select_B,
//     output [1:0] WM_select_A
// );


// endmodule

module bypass_control(clock, sw_mem, lw_mem, lw_exe, sw_wb, jr_wb, jr_mem, nop, dx_rs, dx_rt, xm_rd, mw_rd, ALU_in_A_ctrl, ALU_in_B_ctrl, mem_ctrl, stall, blt_mem, bne_mem, blt_wb, bne_wb, bex, j_T, jal, setx_mem, setx_wb, data_resultRDY, first_time_multdiv, multdiv_rd, mul, div, mul_exe, div_exe);

    input [4:0] dx_rs, dx_rt, xm_rd, mw_rd, multdiv_rd;
    input sw_mem, sw_wb, jr_mem, jr_wb, lw_mem, lw_exe, nop, j_T, jal, bex, clock, stall, blt_mem, bne_mem, blt_wb, bne_wb, setx_mem, setx_wb, data_resultRDY, first_time_multdiv, mul, div, mul_exe, div_exe;
    output [1:0] ALU_in_A_ctrl, ALU_in_B_ctrl;
    output mem_ctrl;

    wire multdiv, no_writing_mem, no_writing_wb;

    //00 and 01 are no bypassing
    //10 is if the register we're reading from is being written to in memory stage (gets val. from mem register)
    //11 is if the register we're reading from is being written to in the writeback stage (get val. from wb register)

    //Additional logic: don't bypass in ALU if the command is a nop, sw (gets its own logic below), 
    //a j_T or jal 
    //branch: check if there are branches in each stage, and if so, don't bypass. You need the branching logic per stage
    //or a stall, or if we're dealing with the 0 register (it's always 0)

    //For bex, only bypass if the previous commands write into register 30 (either a setx command OR an ALU command that writes into register 30)
    //Also remember, setx looks like it's writing to the 0 register because of weirdness in our processor code so you have to account for it here

    assign no_writing_mem = sw_mem | bne_mem | blt_mem | jr_mem;
    assign no_writing_wb = sw_wb | bne_wb | blt_wb | jr_wb;
    
    assign ALU_in_A_ctrl = (nop | sw_mem | j_T | jal | (stall & multdiv) | ~(|dx_rs)) ? 2'b00 : (((dx_rs == xm_rd) &  (|xm_rd) & ~bne_mem & ~blt_mem) | (bex & setx_mem) | (bex & (xm_rd == 5'b11110))) & ~no_writing_mem ? 2'b10 : 
   (((((dx_rs == mw_rd) | ((dx_rs == multdiv_rd) & multdiv))) & (|mw_rd) & ~bne_wb & ~blt_wb) | (bex & setx_wb) | (bex & (mw_rd == 5'b11110))) & ~no_writing_wb ? 2'b11 : 2'b01;

//   assign multdiv = ~data_resultRDY & ~first_time_multdiv;
    assign multdiv = mul | div;
   //Bex only reads from register 30 so no need to check for bex in ALU_in_B_ctrl

    assign ALU_in_B_ctrl = ((nop | sw_mem | lw_exe | j_T | jal | (stall & multdiv) | ~(|dx_rt))) ? 2'b00 : ((dx_rt == xm_rd) &  (|xm_rd) & ~bne_mem & ~blt_mem) & ~no_writing_wb ? 2'b10 : 
    (((dx_rt == mw_rd) | ((dx_rt == multdiv_rd) & multdiv)) & (|mw_rd) & ~bne_wb & ~blt_wb) & ~no_writing_wb ? 2'b11 : 2'b01;

    //Sw bypassing logic

    assign mem_ctrl = nop | j_T | jal | stall ? 1'b0 : sw_mem & (xm_rd == mw_rd) ? 1'b1 : 1'b0;

endmodule