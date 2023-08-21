`ifndef FIFO_BFM_WR_TEST_INCLUDED_
`define FIFO_BFM_WR_TEST_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: fifo_bfm_wr_test
// Extends the fifo base test 
//--------------------------------------------------------------------------------------------
class fifo_bfm_wr_test extends fifo_bfm_base_test;
  `uvm_component_utils(fifo_bfm_wr_test)

  //Instatiation of fifo_bfm_wr_seq
  fifo_bfm_wr_seq fifo_wr_seq;
  axi4_slave_nbk_write_64b_transfer_seq axi4_slave_nbk_write_64b_transfer_seq_h;
  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "fifo_bfm_wr_test", uvm_component parent = null);
  extern virtual task run_phase(uvm_phase phase);

endclass : fifo_bfm_wr_test

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - fifo_bfm_wr_test
//  parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function fifo_bfm_wr_test::new(string name = "fifo_bfm_wr_test",
                                 uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: run_phase
// Creates the fifo_bfm_wr_seq sequence
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
task fifo_bfm_wr_test::run_phase(uvm_phase phase);
 axi4_slave_nbk_write_64b_transfer_seq_h = axi4_slave_nbk_write_64b_transfer_seq::type_id::create("axi4_slave_nbk_write_64b_transfer_seq_h");
  fifo_wr_seq=fifo_bfm_wr_seq::type_id::create("fifo_wr_seq");
  `uvm_info(get_type_name(),$sformatf("fifo_bfm_wr_test"),UVM_LOW);
  phase.raise_objection(this);
  fork
    begin: T1_SL_WR
      forever begin
        axi4_slave_nbk_write_64b_transfer_seq_h.start(axi_env_h.axi_slave_agent_h.axi4_slave_write_seqr_h);
      end
    end
  join_none

  fifo_wr_seq.start(axi_env_h.write_fifo_agent_h.sequencer);
  phase.drop_objection(this);

endtask : run_phase

`endif








