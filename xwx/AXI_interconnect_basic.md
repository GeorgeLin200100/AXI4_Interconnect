## AXI Infrastructure Cores

The following IP cores, described in this document, can be included within each instance of the AXI Interconnect core, depending on the configuration of AXI Interconnect core and its connectivity in the IP integrator block design:
• AXI Crossbar connects one or more similar AXI memory-mapped masters to one or more similar memory-mapped slaves.
• AXI Data Width Converter connects one AXI memory-mapped master to one AXI memory-mapped slave having a wider or narrower datapath.
• AXI Clock Converter connects one AXI memory-mapped master to one AXI
memory-mapped slave operating in a different clock domain.
• AXI Protocol Converter connects one AXI4, AXI3 or AXI4-Lite master to one AXI slave of a different AXI memory-mapped protocol.
• AXI Data FIFO connects one AXI memory-mapped master to one AXI memory-mapped slave through a set of FIFO buffers.
• AXI Register Slice connects one AXI memory-mapped master to one AXI
memory-mapped slave through a set of pipeline registers, typically to break a critical timing path.
• AXI MMU provides address range decoding and remapping services for AXI
Interconnect.



Each AXI Interconnect core can be configured to perform one the following general connectivity patterns:
• N-to-1 Interconnect
• 1-to-N Interconnect
• N-to-M Interconnect (Crossbar Mode)
• N-to-M Interconnect (Shared Access Mode)
The Interconnect can also be configured to connect one master to one slave, in which case the IP integrator will automate the instantiation and configuration of any couplers that are needed along the pathway.

### N to 1 interconnect

When multiple master devices arbitrate for access to a single slave device, such as a memory controller, use the AXI Interconnect core in a N-to-1 configuration.

![image-20250407165403771](C:\Users\xwx\AppData\Roaming\Typora\typora-user-images\image-20250407165403771.png)

### 1 to N interconnect

When a single master device, typically a processor, accesses multiple memory-mapped slave peripherals, use the AXI Interconnect core in a 1-to-N configuration. In these cases, arbitration (仲裁)(in the address and Write datapaths) is not performed, as shown in Figure 2-3.

![image-20250407165615405](C:\Users\xwx\AppData\Roaming\Typora\typora-user-images\image-20250407165615405.png)

### N-to-M Interconnect (Crossbar Mode)

The N-to-M use case of the AXI Interconnect core, when in Crossbar mode, features a Shared-Address Multiple-Data (SAMD) topology, consisting of sparse data crossbar connectivity, with single, shared Write and Read address arbitration, as shown in Figure 2-4 and Figure 2-5.

![image-20250407170148149](C:\Users\xwx\AppData\Roaming\Typora\typora-user-images\image-20250407170148149.png)

![image-20250407170201545](C:\Users\xwx\AppData\Roaming\Typora\typora-user-images\image-20250407170201545.png)

？ 涉及outstanding，out of order等技术？ 多master/slave只靠一个id如何确认相互传递的两个id

1、同时读写-仲裁，可以支持不同的master(多个不同的processer)同时对多个不同地址的数据并行处理

2、master 向slave执行写操作时，讲slave看作一整个完整的slave，有一个共享的写数据空间，interconnect模块会将输入地址拆分到不同的slave上面去

### N-to-M Interconnect (Shared Access Mode)

When in Shared Access mode, the N-to-M use case of the AXI Interconnect core provides for only one outstanding transaction at a time (single issuing), as shown in Figure 2-6. For each connected master, read transaction requests always take priority over writes. The arbiter then selects from among the requesting masters.
A write or read data transfer is then enabled to the targeted slave device. After the data transfer (including the write response) completes, the next request is arbitrated. Shared Access mode minimizes the resources used to implement the crossbar module of the Interconnect.
Shared Access mode is available when AXI Crossbar is configured for any AXI protocol, but is always used when configured as AXI4-Lite.

![image-20250407195234052](C:\Users\xwx\AppData\Roaming\Typora\typora-user-images\image-20250407195234052.png)



### comparison

AXI4 Interconnect模块中的 **Crossbar模式（Performance Optimized）** 和 **Shared Access模式（Area Optimized）** 是两种不同的互连架构设计策略，主要区别在于硬件资源消耗（面积）与性能（吞吐量、延迟）之间的权衡。以下是它们在架构实现和应用场景两方面的详细对比：

---

### **1. 架构实现**
#### **(1) Crossbar模式（性能优化）**
- **核心机制**  
  采用**交叉开关（Crossbar Switch）**结构，为每个主设备（Master）和从设备（Slave）之间的通信提供独立的物理通路。  
  - 允许多个主设备同时访问不同的从设备，实现**并行传输**。  
  - 每个主从通路通过独立的仲裁器和数据通道（如FIFO）管理，避免资源争用。  

- **硬件资源**  
  - 需要为每个可能的**主-从组合**配置独立的逻辑和布线资源（例如多路复用器、仲裁逻辑）。  
  - 随着主从设备数量的增加，硬件资源（面积）呈**平方级增长**（N×M个通路，N为Master数，M为Slave数）。  
  - 典型特征：**高吞吐、低延迟**，但面积开销大。

#### **(2) Shared Access模式（面积优化）**
- **核心机制**  
  采用**共享总线（Shared Bus）**结构，所有主设备通过同一组物理线路访问从设备。  
  - 同一时间仅允许一个主设备占用总线，其他主设备需等待仲裁。  
  - 通过集中式仲裁器（Central Arbiter）分配总线使用权，通常采用优先级或轮询策略。  

- **硬件资源**  
  - 仅需一组共享的总线线路和仲裁逻辑，硬件资源消耗**与主从设备数量无关**。  
  - 面积显著小于Crossbar模式，但**串行化访问**会导致吞吐量下降和潜在的性能瓶颈。

---

### **2. 应用场景**
#### **(1) Crossbar模式（性能优化）**
- **适用场景**  
  - 需要**高带宽、低延迟**的系统：  
    - 多核处理器同时访问多个内存控制器（如DDR、HBM）。  
    - 实时性要求高的场景（如视频处理、AI推理）。  
  - **并行性要求高**的任务：  
    - 多个主设备（如CPU、GPU、DMA）频繁并发访问不同从设备（如SRAM、外设）。  

- **典型案例**  
  - 数据中心加速卡：多个计算单元并行访问高带宽内存。  
  - 高端SoC：多核CPU与GPU共享内存子系统，需避免总线争用导致的性能下降。

#### **(2) Shared Access模式（面积优化）**
- **适用场景**  
  - **资源受限**的嵌入式系统：  
    - 低功耗IoT设备、微控制器（MCU）等对芯片面积敏感的场景。  
  - **低并发需求**的任务：  
    - 主设备较少（如单核CPU + 少数外设），访问频率较低。  
    - 无需严格实时性的控制类应用（如传感器数据采集）。  

- **典型案例**  
  - 汽车电子控制单元（ECU）：主设备（MCU）与外设（CAN、SPI）间通信。  
  - 低端FPGA设计：资源有限时，通过共享总线连接低速外设。

---

### **3. 对比总结**
| **特性**             | **Crossbar模式**    | **Shared Access模式**  |
| -------------------- | ------------------- | ---------------------- |
| **硬件资源（面积）** | 高（N×M通路）       | 低（单一共享总线）     |
| **吞吐量**           | 高（并行传输）      | 低（串行传输）         |
| **延迟**             | 低（无仲裁等待）    | 高（需仲裁等待）       |
| **适用主从设备数量** | 主从设备较多（>4）  | 主从设备较少（≤4）     |
| **典型场景**         | 高性能计算、多核SoC | 嵌入式系统、低功耗设备 |

---

### **4. 设计选择建议**
- **选择Crossbar模式**：  
  当系统需要支持**高并发、低延迟**的通信，且对芯片面积和功耗不敏感时（如服务器芯片、GPU）。  

- **选择Shared Access模式**：  
  当系统**主从设备较少**、对**面积和成本敏感**，且性能要求不高时（如MCU、IoT设备）。

通过合理选择互连模式，可以在性能与面积之间实现最佳平衡，满足不同应用场景的需求。



![image-20250407195303219](C:\Users\xwx\AppData\Roaming\Typora\typora-user-images\image-20250407195303219.png)

