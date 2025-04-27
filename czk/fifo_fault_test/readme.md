在FIFO golden项目上修改，用于跑注错测试流程
方法：使用makefile运行vcs
确保存在sim件夹用于存放仿真过程
确保存在result文件夹用于存放仿真结果

目前完成：ecc+注错
signal_list.txt是用于注错的信号 注意需要反斜杠
make vcs_comp 编译
make vcs_faultsim_1 运行单次仿真
make vcs_faultsim_set 运行多次仿真

