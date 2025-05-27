`ifndef TVIP_AXI_FAULT_SVH
`define TVIP_AXI_FAULT_SVH
class fault_injector extends uvm_component;
    `uvm_component_utils(fault_injector)
    
    logic fault_en=1'b0;
    string signal_name;
    logic force_value = 1'b0;
    int fault_type = 1; // 1:permanent force 2:temporary force
    bit is_config_valid = 1;
    int t_fault_start = 100; 
    int t_fault_duration = 20; 
    int tmp; 

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    //Parse command line arguments
    virtual function void build_phase(uvm_phase phase);
        string force_value_str;
        
        if (!$test$plusargs("FAULT_EN")) begin
            fault_en = 1'b0; 
        end else begin
            fault_en = 1'b1; 
            `uvm_info("FAULT_EN", $sformatf("Fault enable: %d", fault_en), UVM_LOW)
        end
        
        if (!$value$plusargs("SIGNAL_NAME=%s", signal_name)) begin
            `uvm_error("PARAM_ERROR", "signal_name missing")
            is_config_valid = is_config_valid && 0;
        end else begin
            `uvm_info("SIGNAL_NAME", $sformatf("Signal name: %s", signal_name), UVM_LOW)
        end

        if ($value$plusargs("FORCE_VALUE=%s", force_value_str)) begin
            force_value = force_value_str.atoi(); // 将字符串转换为 logic
            `uvm_info("FORCE_VALUE", $sformatf("Force value: %b", force_value), UVM_LOW)
        end else begin
            `uvm_error("PARAM_ERROR", "force_value missing")
            is_config_valid = is_config_valid && 0;
        end

        if (!$value$plusargs("FAULT_TYPE=%d", fault_type)) begin
            `uvm_error("PARAM_ERROR", "fault_type missing")
            is_config_valid = is_config_valid && 0;
        end else begin
            `uvm_info("FAULT_TYPE", $sformatf("Fault type: %d", fault_type), UVM_LOW)
        end

        if (!$value$plusargs("T_FAULT_START=%d", t_fault_start)) begin
            //随机化
            t_fault_start = $urandom_range(22, 50);
            `uvm_info("RANDOM_T_FAULT_START", $sformatf("Randomized t_fault_start: %d", t_fault_start), UVM_LOW)
        end

        if (!$value$plusargs("T_FAULT_DURATION=%d", t_fault_duration)) begin
            
        end
        
        if (!uvm_hdl_check_path(signal_name)) begin
            `uvm_error("PATH_INVALID", $sformatf("Invalid signal path: %s", signal_name))
            is_config_valid = is_config_valid && 0; // 标记参数无效
        end
    endfunction

    //Execute fault injection 
    virtual task run_phase(uvm_phase phase);
        if (!fault_en) begin
            `uvm_info("FAULT_DISABLE", "Fault injection is disabled.", UVM_LOW)
            return;
        end
        if (!is_config_valid) begin
            `uvm_info("FAULT_SKIP", "Wrong parameter, no fault.", UVM_LOW)
            return; 
        end
        
        #t_fault_start;
        if (uvm_hdl_force(signal_name, force_value)) begin
            `uvm_info("FORCE_SUCCESS", $sformatf("Forced %s to %b", signal_name, force_value), UVM_LOW)
            if (fault_type == 2) begin
                #t_fault_duration;
                if (uvm_hdl_release(signal_name)) begin
                    `uvm_info("RELEASE_SUCCESS", $sformatf("Released %s", signal_name), UVM_LOW)
                end else begin
                    `uvm_error("RELEASE_FAIL", $sformatf("Failed to release %s", signal_name))
                end
            end
        end else begin
            `uvm_error("FORCE_FAIL", $sformatf("Failed to force %s", signal_name))
        end
    endtask

endclass
`endif