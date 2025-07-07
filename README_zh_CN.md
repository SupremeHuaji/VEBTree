# VEB Tree

[English](https://github.com/SupremeHuaji/VEBTree/blob/main/README.md) | [简体中文](https://github.com/SupremeHuaji/VEBTree/blob/main/README_zh_CN.md)

一个用 MoonBit 实现的高效 van Emde Boas (VEB) Tree 数据结构，专为整数集合操作设计。VEB Tree 提供 O(log log U) 时间复杂度的插入、删除、查找、前驱和后继操作，在处理有限整数范围的应用中性能优于传统的平衡树和哈希表。

## 🚀 核心特性

• 🚀 **超高效操作** – O(log log U) 时间复杂度的插入、删除、查找、前驱和后继操作  
• ⚡ **常数时间极值访问** – O(1) 时间获取最小值和最大值  
• 📊 **高效范围查询** – O(k + log log U) 时间获取范围内的 k 个元素  
• 🔄 **完整集合操作** – 支持交集、子集检测和相等性比较  
• 🧠 **递归结构** – 利用递归分层设计实现优异性能  
• 🔍 **精确查询** – 支持前驱、后继和存在性检查  
• 🔢 **优化整数集** – 专为整数集合操作优化，支持有限整数范围  
• 🧪 **全面测试** – 经过完整的单元测试验证

## 📥 安装
```bash
moon add SupremeHuaji/VEBTree
```

## 🚀 使用指南

### 🔨 创建 VEB Tree
创建和初始化 VEB Tree 的不同方法。

```moonbit
  // 创建一个宇宙大小为 16 的 VEB Tree
  let veb = new(16)
  
  // 使用 2 的幂创建 (2^8 = 256)
  let veb_pow = new_pow2(8)
  
  // 从数组创建
  let elements = [1, 3, 5, 7, 9]
  let veb_from_array = from_array(elements, 16)
```

### ➕ 添加和删除元素
使用 `insert` 和 `delete` 方法操作集合元素。

```moonbit
  let veb = new(16)
  
  // 插入元素
  match veb.insert(5) {
    Success(val) => println("插入成功: \{val}")
    _ => println("插入失败")
  }
  
  // 删除元素
  match veb.delete(5) {
    Success(val) => println("删除成功: \{val}")
    NotFound => println("元素不存在")
    OutOfRange => println("元素超出范围")
  }
  
  // 检查树的大小
  println("当前元素数量: \{veb.size()}")
```

### 🔍 查询操作
查找元素和执行各种查询。

```moonbit
  let veb = from_array([1, 3, 5, 7, 9], 16)
  
  // 检查元素是否存在
  if veb.contains(5) {
    println("5 存在于集合中")
  }
  
  // 获取最小值和最大值
  match veb.min() {
    Success(min_val) => println("最小值: \{min_val}")
    _ => println("树为空")
  }
  
  match veb.max() {
    Success(max_val) => println("最大值: \{max_val}")
    _ => println("树为空")
  }
  
  // 查找后继和前驱
  match veb.successor(5) {
    Success(succ) => println("5 的后继是: \{succ}")
    _ => println("没有后继")
  }
  
  match veb.predecessor(5) {
    Success(pred) => println("5 的前驱是: \{pred}")
    _ => println("没有前驱")
  }
```

### 🎯 范围查询和集合操作
获取范围内元素和执行集合操作。

```moonbit
  let veb1 = from_array([1, 3, 5, 7, 9], 16)
  let veb2 = from_array([5, 7, 9, 11, 13], 16)
  
  // 范围查询
  let range_elements = veb1.range_query(3, 8)
  println("范围 [3, 8] 内的元素: \{range_elements}")
  
  // 范围内元素数量
  let count = veb1.count_range(3, 8)
  println("范围 [3, 8] 内的元素数: \{count}")
  
  // 子集检查
  if veb1.is_subset(veb2) {
    println("veb1 是 veb2 的子集")
  } else {
    println("veb1 不是 veb2 的子集")
  }
  
  // 相等性检查
  if veb1.equals(veb2) {
    println("两个集合相等")
  } else {
    println("两个集合不相等")
  }
  
  // 计算交集
  let intersection = veb1.intersection(veb2)
  println("交集: \{intersection.to_array()}")
```

## 📊 性能特征

| 操作 | 时间复杂度 | 空间复杂度 | 说明 |
|------|-----------|-----------|------|
| `new`, `new_pow2` | O(1) | O(1) | 创建空树 |
| `insert` | O(log log U) | O(log log U) | 插入单个元素 |
| `delete` | O(log log U) | O(log log U) | 删除单个元素 |
| `contains` | O(log log U) | O(1) | 检查元素存在性 |
| `min`, `max` | O(1) | O(1) | 获取最小/最大元素 |
| `successor`, `predecessor` | O(log log U) | O(1) | 查找后继/前驱 |
| `range_query` | O(k + log log U) | O(k) | 范围查询，k为结果数量 |
| `to_array` | O(n) | O(n) | 转换为数组 |
| `intersection` | O(n log log U) | O(min(n,m)) | 计算两个树的交集 |

其中：
- `U` = 宇宙大小（支持的整数范围）
- `n`, `m` = 两个树的元素数量
- `k` = 操作或结果的元素数量

## 🏗️ 实现细节

### 📦 数据结构

VEB Tree 是一种递归结构，由以下组件组成：

1. **宇宙大小 (universe_size)**
   - 定义支持的整数范围 [0, universe_size-1]
   - 必须是2的幂

2. **最小值/最大值 (min/max)**
   - 直接存储当前子树的最小值和最大值
   - 允许O(1)时间访问极值

3. **摘要结构 (summary)**
   - 递归的VEB树，跟踪哪些集群非空
   - 用于快速定位元素

4. **集群数组 (clusters)**
   - √U个集群，每个集群是递归的VEB树
   - 处理不同范围的元素

### 🔄 递归分层设计

VEB Tree使用递归分层设计实现高效操作：

```moonbit
  // 宇宙大小为16的VEB Tree结构示意图
  /*
                 [0-15] (root)
                 /     \
         min/max      summary [0-3]
                     /       \
                   /           \
              clusters[0]    clusters[1]    clusters[2]    clusters[3]
               [0-3]         [0-3]          [0-3]          [0-3]
  */
```

### 📈 高效操作原理

VEB Tree的高效操作基于其层次结构和递归设计：

- **查找操作**: 使用high/low位拆分快速定位元素位置
- **插入/删除**: 递归更新min/max和相应的集群
- **前驱/后继**: 使用summary结构快速跳转到相邻元素

```moonbit
  // 分割元素x为high和low部分的示例
  let cluster_sz = cluster_size(universe_size)  // √U
  let high_idx = high(x, cluster_sz)  // x / √U
  let low_idx = low(x, cluster_sz)    // x % √U
```

## 🎯 使用场景

### 💾 网络路由表
```moonbit
  // IP地址路由表模拟
  let active_routes = new(256)  // 简化为8位IP
  
  // 添加活跃路由
  ignore(active_routes.insert(128))
  ignore(active_routes.insert(192))
  ignore(active_routes.insert(64))
  
  // 查找最接近的路由
  let ip = 130
  match active_routes.predecessor(ip) {
    Success(route) => println("找到最接近的路由: \{route}")
    _ => println("没有找到合适的路由")
  }
```

### 🔍 调度系统
```moonbit
  // 任务调度器
  let scheduled_tasks = new_pow2(12)  // 支持0-4095的时间点
  
  // 添加任务
  ignore(scheduled_tasks.insert(120))  // 120ms
  ignore(scheduled_tasks.insert(340))  // 340ms
  ignore(scheduled_tasks.insert(980))  // 980ms
  
  // 查找下一个要执行的任务
  let current_time = 200
  match scheduled_tasks.successor(current_time) {
    Success(next_task) => println("下一个任务执行时间: \{next_task}ms")
    _ => println("没有更多待执行任务")
  }
```

### 📊 范围统计分析
```moonbit
  // 分数分布分析
  let scores = from_array([45, 62, 78, 85, 92, 98], 101)  // 0-100分
  
  // 统计不同分数段
  let below_60 = scores.count_range(0, 59)
  let passing = scores.count_range(60, 79)
  let good = scores.count_range(80, 89)
  let excellent = scores.count_range(90, 100)
  
  println("不及格 (<60): \{below_60}")
  println("及格 (60-79): \{passing}")
  println("良好 (80-89): \{good}")
  println("优秀 (90-100): \{excellent}")
```

## 🔧 配置和调优

### 宇宙大小选择
```moonbit
  // 选择合适的宇宙大小对性能至关重要
  
  // 对于小范围整数 (如年龄 0-150)
  let ages = new_pow2(8)  // 2^8 = 256 > 150
  
  // 对于中等范围 (如端口号 0-65535)
  let ports = new_pow2(16)  // 2^16 = 65536
  
  // 对于大范围整数，考虑分片或其他数据结构
  // VEB Tree在非常大的宇宙大小下可能消耗过多内存
```

## 🆚 VEB Tree vs 其他数据结构

| 特性 | VEB Tree | 平衡树 | 哈希表 |
|------|----------|--------|--------|
| **查找** | O(log log U) | O(log n) | 平均 O(1)，最坏 O(n) |
| **插入/删除** | O(log log U) | O(log n) | 平均 O(1)，最坏 O(n) |
| **前驱/后继** | O(log log U) | O(log n) | O(n) |
| **范围查询** | O(k + log log U) | O(k + log n) | O(n) |
| **最小/最大** | O(1) | O(log n) | O(n) |
| **空间使用** | O(U) | O(n) | O(n) |
| **适用场景** | 整数集合，需要前驱/后继 | 一般用途 | 快速查找，不需要顺序 |

## 🤝 贡献

欢迎贡献代码！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📜 许可证

本项目基于 MIT 许可证。详情请参见 LICENSE 文件。

## 🔗 相关资源

- [van Emde Boas树介绍](https://en.wikipedia.org/wiki/Van_Emde_Boas_tree)
- [MoonBit 语言文档](https://www.moonbitlang.com/docs/)
- [算法导论 - van Emde Boas树](https://mitpress.mit.edu/books/introduction-algorithms-third-edition)