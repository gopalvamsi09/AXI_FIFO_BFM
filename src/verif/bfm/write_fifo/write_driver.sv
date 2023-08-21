`ifndef WRITE_FIFO_DRIVER_INCLUDED_
`define WRITE_FIFO_DRIVER_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: write_fifo_driver
// <Description_here>
//--------------------------------------------------------------------------------------------
class write_fifo_driver extends uvm_driver#(fifo_sequence_item);
  `uvm_component_utils(write_fifo_driver)

  //variable intf
  //DEfining virtual interface
  virtual fifo_if intf;

  //variable pkt
  //Declaring sequence item handle
  fifo_sequence_item#(32,56) pkt;

  bit[127:0] queue0[$];
  bit[127:0] queue1[$];
  bit[127:0] queue2[$];
  bit[127:0] queue3[$];
  bit[127:0] queue4[$];

  bit [127:0] packet;
  //int z;

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "write_fifo_driver", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task reset();
  extern virtual task drive(fifo_sequence_item pkt);
endclass : write_fifo_driver

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - write_fifo_driver
//  parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function write_fifo_driver::new(string name = "write_fifo_driver",
                                 uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//--------------------------------------------------------------------------------------------
// Function: build_phase
// <Description_here>
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function void write_fifo_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
uvm_config_db#(virtual fifo_if)::get(this,"","vif",intf);
  
endfunction : build_phase

//--------------------------------------------------------------------------------------------
// Function: connect_phase
// <Description_here>
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
function void write_fifo_driver::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
endfunction : connect_phase

  task write_fifo_driver::reset();
    wait(!intf.rst);
    intf.wr_data<=0;
    intf.wr_en<=0;
    intf.rd_en<=0;
    wait(intf.rst);
  endtask

//--------------------------------------------------------------------------------------------
// Task: run_phase
// <Description_here>
//
// Parameters:
//  phase - uvm phase
//--------------------------------------------------------------------------------------------
task write_fifo_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);

    reset();
      forever begin
      pkt=fifo_sequence_item#(32,56)::type_id::create("pkt");
      seq_item_port.get_next_item(pkt);
      $cast(pkt.type_of_axi_e,1); //gopal mentioned
      $display("running drive task");
      $display("type of axi = %d",pkt.type_of_axi_e);
      pkt.print();
      drive(pkt);
      @(posedge intf.clk);
      intf.wr_en<=0;
      $display("DRIVER, finished drive task");
      seq_item_port.item_done();
    end
  endtask : run_phase

  

  task write_fifo_driver::drive(fifo_sequence_item pkt);
    //int pkt_size =  (((2**pkt.awsize)*(pkt.awlen+1))+72);
    //real qo;
    //int ro;
    //real dp;
    ////pkt_size = (((2**pkt.awsize)*(pkt.awlen+1))+72);
    //bit[pkt_size-1:0] packet;

    //
    //qo = pkt_size/128;
    //ro = $floor(qo);
    //dp = qo-ro;
    //if(dp>0) ro = ro+1;
    //else ro = ro;
    
    @(posedge intf.clk);
    @(posedge intf.clk);
    intf.wr_en<=pkt.wr_en;
    intf.rd_en<=pkt.rd_en;
    //intf.data_in<=pkt.data_in;
    // Write Address Channel
    //pkt.type_of_axi_e=1;
     // $display("type of axi = %d",pkt.type_of_axi_e);
     // Packet = {SOP (8 bits) + TXN_ID (4 bits) + ADDR (32 bits) + LEN (4 bits) + SIZE (3 bits) + BURST (2 bits) + LOCK (2 bits) + CACHE (2 bits) + PROT (3 bits) + STROBE (4 bits) + DATA (1024 bits) + EOP (8 bits)}
    if(pkt.type_of_axi_e == 0) begin
      packet = {pkt.sop, pkt.awid,pkt.awaddr, pkt.awlen, pkt.awsize, pkt.awburst ,pkt.awlock,pkt.awcache,pkt.awprot, pkt.wstrb,8'h0,pkt.eop};
      queue0.push_back(pkt.awaddr);
    end

// Write Data Channel
if(pkt.type_of_axi_e == 1) begin
      //packet = {pkt.sop, pkt.type_of_axi_e, pkt.wid, pkt.wstrb, pkt.wdata, pkt.wlast, pkt.eop};
      //hard coded wdata inorder to give exact 128 bits
      packet =
      {pkt.sop,pkt.awid,pkt.awaddr,pkt.awlen,pkt.awsize,pkt.awburst,pkt.awlock,pkt.awcache,pkt.awprot,pkt.wstrb,pkt.wdata,pkt.eop};
      
      //queue1.push_back(pkt.wdata); //gopal commented all
        intf.wr_data <= packet;
        //for(int i = 0; i<ro; i++) begin
        //  
        //  @(posedge intf.clk);
        //  if(i!=(ro-1))
        //    intf.wr_data <= packet[pkt_size-i*128 -: 128];
        //  else begin
        //    if(pkt_size-i*128<0)
        //      intf.wr_data <= packet[pkt_size-i*128 -: (128+(pkt_size-i*128))];
        //    else intf.wr_data <= packet[pkt_size-i*128 -: 128];
        //end
        //end
        //queue1.pop_front();
      $display("DRIVER, inside write address queue");
      end

// Read Address Channel
if(pkt.type_of_axi_e == 2) begin
      packet = {pkt.sop, pkt.type_of_axi_e, pkt.arid, pkt.arlen, pkt.arsize, pkt.arburst, pkt.araddr, pkt.eop};
       queue2.push_back(pkt.araddr);
     end

// Read Data Channel
if(pkt.type_of_axi_e == 3) begin
     packet = {pkt.sop, pkt.type_of_axi_e, pkt.rid, pkt.rresp, pkt.rlast, pkt.rdata , pkt.eop};
      queue3.push_back(pkt.rdata);
    end
// Write Response Channel
if(pkt.type_of_axi_e == 4) begin
     packet = {pkt.sop, pkt.type_of_axi_e, pkt.bid, pkt.bresp, pkt.eop};
     queue4.push_back(pkt.bresp);
   end


endtask : drive

`endif

