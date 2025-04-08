# PDU_v3

## 食用指南

### 1. 添加你自己的 CPU 代码

在 `PDU_v3/vsrc/PDU/CPU` 目录下创建 `your_cpu` 目录，并将你的 CPU 代码放在该目录下，不过你可以把你的 CPU 代码放在任何地方，只要你之后将其导入 vivado 工程中即可

### 2. 修改 `PDU_v3/vsrc/PDU/include/mem_init.vh` 文件

打开 `PDU_v3/vsrc/PDU/include/mem_init.vh` 文件，修改 `PDU_IMEM_FILE` 、 `PDU_DMEM_FILE` 、 `CPU_IMEM_FILE` 和 `CPU_DMEM_FILE`

- `PDU_IMEM_FILE` 和 `PDU_DMEM_FILE`

    根据你实现的指令集，选择 `PDU_v3/vsrc/inits/pdu_inits` 下的 `loongarch` 和 `riscv` 文件夹，将两个宏定义分别定义为文件夹中 `pdu_imem.ini` 和 `pdu_dmem.ini` 的**绝对路径**，注意，路径应该以**字符串**表示，即需包含在两个双引号之间

- `CPU_IMEM_FILE` 和 `CPU_DMEM_FILE`

    在本框架中，可以在 `PDU_v3/vsrc/inits` 路径下找到 `cpu_inits` 文件夹，将 CPU 所用的初始化文件 `instr.ini` 和 `data.ini` 放入其中，然后将两个宏定义同样修改成两个文件的**绝对路径**即可，其实你可以把初始化文件放在任何地方，只要宏定义的绝对路径能正确找到 cpu 的两初始化文件即能正确实现

### 3. 创建 vivado 工程

打开 vivado 并且创建工程，在 **Add source** 界面下选择 **Add Directories** ，选择 `PDU_v3/vsrc` 目录添加，如果你的 CPU 代码不在 `PDU_v3/vsrc` 及其子目录下，你需要额外导入你的 CPU 代码文件

![image](./assets/add_source.png)

在 **Add Constraints** 界面下选择添加 `PDU_v3/impl/XC7A100t-CSG324-1.xdc` 约束文件，自然，你需要选择 **xc7a100t-csg324-1** 型开发板

![image](./assets/add_constraints.png)

创建完毕后，你的工程文件结构应该如下

![image](./assets/project_struc.png)

### 4. 烧写工程

如果一切无误，你可以直接进行 **write bitstream** 操作，不出意外的话，你会得到 **WNS** 为 **-15.108ns** （甚至更糟），不要慌张，这是正常现象，你可以直接进行上板验证

## 操作指南

### 1. 上板操作

上板后，点击 button 可以发现串口输出了 `PDU:` 的字样，此时就可以进行命令输入了，所有命令的输入必须以**换行符结尾**，并且**对大小写敏感**

![image](./assets/on_board.png)

### 2. 支持的命令

**以下命令的 addr 支持十进制数和 "0x" 开头的十六进制数**

- `ri <addr.> [<count> = 1]`: 读取指令
- `wi <addr.> [<count> = 1]`: 写入指令
- `rd <addr.> [<count> = 1]`: 读取数据
- `wd <addr.> [<count> = 1]`: 写入数据
- `rr`: 读取寄存器
- `bs <addr.>`: 设置断点
- `bc <id>`: 清除断点
- `bl`: 查看断点
- `step`: 单步执行
- `run`: 运行
- `reset`: 重置

## 示例

![image](./assets/example1.png)

![image](./assets/example2.png)
