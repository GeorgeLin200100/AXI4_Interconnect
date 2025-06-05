#part1 获取模块列表
set module_file [open "./all_module.txt" w]

proc collect_modules {module_path} {
    global module_file

    # 写入目标模块
    puts $module_file "$module_path"

    # 进入目标模块层级
    scope $module_path

    # 获取子模块列表
    set submodules [split [show -instances] "\n"]
    foreach line $submodules {
        if {[string match "{*}" $line]} {
            set line [string range $line 1 end-1]
        }
        # 递归处理子模块
        set child_path "${module_path}.${line}"
        collect_modules $child_path
    }

    # 返回上一级模块作用域
    scope -up
}

# 设置顶层模块
#set top_module top
set top_module top.u_connector.u_connector
collect_modules $top_module
close $module_file

#part2 获取端口和信号
set signal_file [open "./all_signal.txt" w]

proc get_msb_lsb {signal} {
    set info [show -type $signal]
    set props [lindex $info 1]
    set type [lindex $props 0]
    if {$type !="VECTOR"} {
        return [list 0 0]
    }

    set range [lindex $props 2]
    if {$range == {}} {
        return [list 0 0]
    }

    set msb [lindex [lindex $range 0] 0]
    set lsb [lindex [lindex $range 0] 1]

    return [list $msb $lsb]
}


#proc collect_signals {} {
    global signal_file

    set file [open "./all_module.txt" r]
    set content [read $file]
    close $file
    set modules [split $content "\n"]
    set modules [lrange $modules 0 end-1]
    # port
    puts $signal_file "port:"
    foreach module $modules {
        scope $module
        set ports [split  [show $module -ports]  "\n"]
        foreach port $ports {
            if {$port eq "clk" || $port eq "rst"} {
                continue
            } 
            echo $module.$port
            set msb [lindex [get_msb_lsb $port] 0]
            set lsb [lindex [get_msb_lsb $port] 1]

            if {[string match "{*}" $port]} {
                set port [string range $port 1 end-1]
            }
            
            if {$msb == $lsb} {
                puts $signal_file "$module.$port"
            } else {
                for {set i $lsb} {$i <= $msb} {incr i} {
                    puts $signal_file "$module.$port\[$i\]"
                }
            }
            
        }
    }

    # signal
    puts $signal_file "signal:"
    foreach module $modules {
        scope $module
        set signals [split  [show $module -signals] "\n"]   
        foreach signal $signals {
            echo $module.$signal

            if {[string match "{*}" $signal]} {
                set signal [string range $signal 1 end-1]
            }

            set msb [lindex [get_msb_lsb $signal] 0]
            set lsb [lindex [get_msb_lsb $signal] 1]


            if {$msb == $lsb} {
                puts $signal_file "$module.$signal"
            } else {
                for {set i $lsb} {$i <= $msb} {incr i} {
                    puts $signal_file "$module.$signal\[$i\]"
                }
            }
        }
    }

#}


#collect_signals 

close $signal_file
#run