********************
Author: Jianzhao Bi
Initial: 02/26/2016
Updated: 02/28/2016
********************

********************
数据下载
********************

文件介绍

1. inv：invariant数据，即不随时间变化的数据，包括ECMWF地表高程等
2. mdl：模式数据，多层，包括不同level的风向风速等信息
3. sfc：地表数据，单层，包括一些近地表信息


数据下载

1. inv：直接使用download.py进行下载，需调整时间和空间范围
2. mdl&sfc：
	single.py：下载单日的数据
	download.py：下载多日数据，需配合retrieve.sh使用
	retrieve.sh：生成一年的逐日日期，并将此日期字符串传递给download.py进行数据下载
3. 数据下载的步骤可参见README.txt（改成STEPS.txt）


注意事项

1. 下载后需检查每一年的文件数是否正确（如2005年需有365个文件）
2. 下载后还需检查每一个文件的大小是否一致，因为部分文件可能下载得不完全，导致文件大小较小

********************
数据后处理
********************

-script.pbs
	脚本程序，将main.m文件提交到PBS系统上运行

-main.m
	使用并行计算的方法将年份变量传递给windGlobalProcess函数

-windGlobalProcess.m
	处理单年的风场数据