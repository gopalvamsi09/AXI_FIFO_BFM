`ifndef FIFO_BFM_WR_SEQ_INCLUDED_
`define FIFO_BFM_WR_SEQ_INCLUDED_


class fifo_bfm_wr_seq extends fifo_bfm_base_seq;

`uvm_object_utils(fifo_bfm_wr_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "fifo_bfm_wr_seq");//, uvm_component parent = null);
  extern virtual task body();

endclass:fifo_bfm_wr_seq

//-----------------------------------------------------------------------------
// Constructor: new
// Initializes fifo_bfm_wr_seq class object
//
// Parameters:
//  name - fifo_bfm_wr_seq
//-----------------------------------------------------------------------------

function fifo_bfm_wr_seq::new(string name="fifo_bfm_wr_seq");
super.new(name);
endfunction:new

//--------------------------------------------------------------------------------------------
// Task: body
// task for fifo wr type sequence
//--------------------------------------------------------------------------------------------
task fifo_bfm_wr_seq::body(); 
begin
  fifo_sequence_item req;
  req=fifo_sequence_item #(32,56)::type_id::create("req");
  repeat(100) begin
  start_item(req);
  req.randomize() with{req.wr_en==1 && req.rd_en==0; req.awsize==3; req.awlen==7; req.wstrb==4'b1111;};
  finish_item(req);
end
end
endtask:body

`endif
