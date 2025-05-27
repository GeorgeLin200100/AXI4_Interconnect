#part1 获取模块列表
set module_file [open "./all_module.txt" w]

proc collect_modules {module_path} {
    global module_file

    # 写入当前模块路径
    puts $module_file "$module_path"

    # 进入当前模块作用域
    scope $module_path

    # 获取子模块列表
    set submodules [split [show -instances] "\n"]
    foreach line $submodules {
        # 递归处理子模块
        if {[string match "{*}" $line]} {
        set line [string range $line 1 end-1]
        }
        set child_path "${module_path}.${line}"
        collect_modules $child_path
    }

    # 返回上一级模块作用域
    scope -up
}

# 从顶层模块开始
#set top_module [scope]
set top_module top.u_connector.u_connector
collect_modules $top_module
close $module_file

#part2 获取端口和信号
set signal_file [open "./all_signal.txt" w]

proc collect_signals {} {
    global signal_file

    set file [open "./all_module.txt" r]
    set content [read $file]
    close $file
    set modules [split $content "\n"]

    # port
    puts $signal_file "Port:"
    foreach module $modules {
        set ports [split  [show $module -ports]  "\n"]
        foreach port $ports {
            puts $signal_file "$module.$port"
        }
    }

    # signal
    puts $signal_file "signal:"
    foreach module $modules {
        set signals [split  [show $module -signals] "\n"]   
        foreach signal $signals {
            puts $signal_file "$module.$signal"
        }
    }

}


collect_signals 

close $signal_file