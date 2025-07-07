# VEB Tree

[English](https://github.com/SupremeHuaji/VEBTree/blob/main/README.md) | [简体中文](https://github.com/SupremeHuaji/VEBTree/blob/main/README_zh_CN.md)

An efficient van Emde Boas (VEB) Tree data structure implemented in MoonBit, designed specifically for integer set operations. VEB Tree provides O(log log U) time complexity for insertion, deletion, search, predecessor and successor operations, outperforming traditional balanced trees and hash tables when handling applications with finite integer ranges.

## 🚀 Core Features

• 🚀 **Ultra-efficient Operations** – O(log log U) time complexity for insertion, deletion, search, predecessor and successor operations  
• ⚡ **Constant-time Extrema Access** – O(1) time to retrieve minimum and maximum values  
• 📊 **Efficient Range Queries** – O(k + log log U) time to get k elements within a range  
• 🔄 **Complete Set Operations** – Support for intersection, subset detection and equality comparison  
• 🧠 **Recursive Structure** – Leveraging recursive layered design for exceptional performance  
• 🔍 **Precise Queries** – Support for predecessor, successor and existence checks  
• 🔢 **Optimized Integer Sets** – Specialized for integer set operations, supporting finite integer ranges  
• 🧪 **Comprehensive Testing** – Validated through complete unit tests

## 📥 Installation
```bash
moon add SupremeHuaji/VEBTree
```

## 🚀 Usage Guide

### 🔨 Creating a VEB Tree
Different methods for creating and initializing a VEB Tree.

```moonbit
  // Create a VEB Tree with universe size 16
  let veb = new(16)
  
  // Create using powers of 2 (2^8 = 256)
  let veb_pow = new_pow2(8)
  
  // Create from array
  let elements = [1, 3, 5, 7, 9]
  let veb_from_array = from_array(elements, 16)
```

### ➕ Adding and Removing Elements
Use `insert` and `delete` methods to manipulate set elements.

```moonbit
  let veb = new(16)
  
  // Insert element
  match veb.insert(5) {
    Success(val) => println("Insert successful: \{val}")
    _ => println("Insert failed")
  }
  
  // Delete element
  match veb.delete(5) {
    Success(val) => println("Delete successful: \{val}")
    NotFound => println("Element does not exist")
    OutOfRange => println("Element out of range")
  }
  
  // Check tree size
  println("Current number of elements: \{veb.size()}")
```

### 🔍 Query Operations
Find elements and perform various queries.

```moonbit
  let veb = from_array([1, 3, 5, 7, 9], 16)
  
  // Check if element exists
  if veb.contains(5) {
    println("5 exists in the set")
  }
  
  // Get minimum and maximum values
  match veb.min() {
    Success(min_val) => println("Minimum value: \{min_val}")
    _ => println("Tree is empty")
  }
  
  match veb.max() {
    Success(max_val) => println("Maximum value: \{max_val}")
    _ => println("Tree is empty")
  }
  
  // Find successor and predecessor
  match veb.successor(5) {
    Success(succ) => println("Successor of 5 is: \{succ}")
    _ => println("No successor")
  }
  
  match veb.predecessor(5) {
    Success(pred) => println("Predecessor of 5 is: \{pred}")
    _ => println("No predecessor")
  }
```

### 🎯 Range Queries and Set Operations
Get elements within a range and perform set operations.

```moonbit
  let veb1 = from_array([1, 3, 5, 7, 9], 16)
  let veb2 = from_array([5, 7, 9, 11, 13], 16)
  
  // Range query
  let range_elements = veb1.range_query(3, 8)
  println("Elements in range [3, 8]: \{range_elements}")
  
  // Count elements in range
  let count = veb1.count_range(3, 8)
  println("Number of elements in range [3, 8]: \{count}")
  
  // Subset check
  if veb1.is_subset(veb2) {
    println("veb1 is a subset of veb2")
  } else {
    println("veb1 is not a subset of veb2")
  }
  
  // Equality check
  if veb1.equals(veb2) {
    println("The two sets are equal")
  } else {
    println("The two sets are not equal")
  }
  
  // Calculate intersection
  let intersection = veb1.intersection(veb2)
  println("Intersection: \{intersection.to_array()}")
```

## 📊 Performance Characteristics

| Operation | Time Complexity | Space Complexity | Description |
|------|-----------|-----------|------|
| `new`, `new_pow2` | O(1) | O(1) | Create empty tree |
| `insert` | O(log log U) | O(log log U) | Insert single element |
| `delete` | O(log log U) | O(log log U) | Delete single element |
| `contains` | O(log log U) | O(1) | Check element existence |
| `min`, `max` | O(1) | O(1) | Get min/max element |
| `successor`, `predecessor` | O(log log U) | O(1) | Find successor/predecessor |
| `range_query` | O(k + log log U) | O(k) | Range query, k is result size |
| `to_array` | O(n) | O(n) | Convert to array |
| `intersection` | O(n log log U) | O(min(n,m)) | Calculate intersection of two trees |

Where:
- `U` = Universe size (supported integer range)
- `n`, `m` = Number of elements in two trees
- `k` = Number of elements in operations or results

## 🏗️ Implementation Details

### 📦 Data Structure

VEB Tree is a recursive structure consisting of the following components:

1. **Universe Size (universe_size)**
   - Defines the supported integer range [0, universe_size-1]
   - Must be a power of 2

2. **Minimum/Maximum Values (min/max)**
   - Directly store the minimum and maximum values of the current subtree
   - Allow O(1) time access to extrema

3. **Summary Structure (summary)**
   - Recursive VEB tree that tracks which clusters are non-empty
   - Used for fast element location

4. **Cluster Array (clusters)**
   - √U clusters, each a recursive VEB tree
   - Handles different ranges of elements

### 🔄 Recursive Layered Design

VEB Tree uses recursive layered design to achieve efficient operations:

```moonbit
  // Diagram of a VEB Tree structure with universe size 16
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

### 📈 Efficient Operation Principles

VEB Tree's efficient operations are based on its hierarchical structure and recursive design:

- **Search Operations**: Use high/low bit splitting to quickly locate element positions
- **Insert/Delete**: Recursively update min/max and corresponding clusters
- **Predecessor/Successor**: Use summary structure to quickly jump to adjacent elements

```moonbit
  // Example of splitting element x into high and low parts
  let cluster_sz = cluster_size(universe_size)  // √U
  let high_idx = high(x, cluster_sz)  // x / √U
  let low_idx = low(x, cluster_sz)    // x % √U
```

## 🎯 Use Cases

### 💾 Network Routing Tables
```moonbit
  // IP address routing table simulation
  let active_routes = new(256)  // Simplified to 8-bit IP
  
  // Add active routes
  ignore(active_routes.insert(128))
  ignore(active_routes.insert(192))
  ignore(active_routes.insert(64))
  
  // Find the closest route
  let ip = 130
  match active_routes.predecessor(ip) {
    Success(route) => println("Found closest route: \{route}")
    _ => println("No suitable route found")
  }
```

### 🔍 Scheduling Systems
```moonbit
  // Task scheduler
  let scheduled_tasks = new_pow2(12)  // Supports time points 0-4095
  
  // Add tasks
  ignore(scheduled_tasks.insert(120))  // 120ms
  ignore(scheduled_tasks.insert(340))  // 340ms
  ignore(scheduled_tasks.insert(980))  // 980ms
  
  // Find the next task to execute
  let current_time = 200
  match scheduled_tasks.successor(current_time) {
    Success(next_task) => println("Next task execution time: \{next_task}ms")
    _ => println("No more tasks to execute")
  }
```

### 📊 Range Statistical Analysis
```moonbit
  // Score distribution analysis
  let scores = from_array([45, 62, 78, 85, 92, 98], 101)  // 0-100 points
  
  // Count different score ranges
  let below_60 = scores.count_range(0, 59)
  let passing = scores.count_range(60, 79)
  let good = scores.count_range(80, 89)
  let excellent = scores.count_range(90, 100)
  
  println("Failing (<60): \{below_60}")
  println("Passing (60-79): \{passing}")
  println("Good (80-89): \{good}")
  println("Excellent (90-100): \{excellent}")
```

## 🔧 Configuration and Tuning

### Universe Size Selection
```moonbit
  // Choosing the right universe size is critical for performance
  
  // For small integer ranges (e.g., ages 0-150)
  let ages = new_pow2(8)  // 2^8 = 256 > 150
  
  // For medium ranges (e.g., port numbers 0-65535)
  let ports = new_pow2(16)  // 2^16 = 65536
  
  // For large integer ranges, consider sharding or other data structures
  // VEB Trees may consume excessive memory with very large universe sizes
```

## 🆚 VEB Tree vs Other Data Structures

| Feature | VEB Tree | Balanced Tree | Hash Table |
|------|----------|--------|--------|
| **Search** | O(log log U) | O(log n) | Average O(1), worst O(n) |
| **Insert/Delete** | O(log log U) | O(log n) | Average O(1), worst O(n) |
| **Predecessor/Successor** | O(log log U) | O(log n) | O(n) |
| **Range Query** | O(k + log log U) | O(k + log n) | O(n) |
| **Min/Max** | O(1) | O(log n) | O(n) |
| **Space Usage** | O(U) | O(n) | O(n) |
| **Suitable For** | Integer sets, need pred/succ | General purpose | Fast lookups, no ordering needed |

## 🤝 Contributions

Contributions are welcome! Please follow these steps:

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License. See the LICENSE file for details.

## 🔗 Related Resources

- [van Emde Boas Tree Introduction](https://en.wikipedia.org/wiki/Van_Emde_Boas_tree)
- [MoonBit Language Documentation](https://www.moonbitlang.com/docs/)
- [Introduction to Algorithms - van Emde Boas Trees](https://mitpress.mit.edu/books/introduction-algorithms-third-edition)

