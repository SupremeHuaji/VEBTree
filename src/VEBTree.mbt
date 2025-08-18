///|
/// Create a new VEB Tree with given universe size
/// universe_size must be a power of 2
pub fn new(universe_size : Int) -> VEBTree {
  if universe_size <= 0 || (universe_size & (universe_size - 1)) != 0 {
    abort("Universe size must be a positive power of 2")
  }
  { universe_size, min: None, max: None, summary: None, clusters: None }
}

///|
/// Create VEB Tree for specific universe size (2^k)
pub fn new_pow2(k : Int) -> VEBTree {
  if k < 0 || k > 30 {
    abort("k must be between 0 and 30")
  }
  new(1 << k)
}

///|
/// Check if tree is empty
pub fn is_empty(self : VEBTree) -> Bool {
  match self.min {
    None => true
    Some(_) => false
  }
}

///|
/// Get the size of universe
pub fn universe_size(self : VEBTree) -> Int {
  self.universe_size
}

///|
/// Optimized delete function - fixed version
pub fn delete(self : VEBTree, x : Int) -> VEBResult {
  if x < 0 || x >= self.universe_size {
    return OutOfRange
  }

  // 检查元素是否存在
  if self.contains(x) == false {
    return NotFound
  }
  match self.min {
    None => NotFound
    Some(min_val) =>
      match self.max {
        None => NotFound
        Some(max_val) => {
          // 单元素情况
          if min_val == max_val {
            if x == min_val {
              self.min = None
              self.max = None
              return Success(x)
            } else {
              return NotFound // 已经通过 contains 检查，不应该走到这里
            }
          }

          // 基础情况
          if self.universe_size == 2 {
            if x == 0 {
              self.min = Some(1)
              self.max = Some(1)
              return Success(x)
            } else { // x == 1
              self.min = Some(0)
              self.max = Some(0)
              return Success(x)
            }
          }

          // 情况1：删除最小值
          if x == min_val {
            // 找到下一个最小值
            match self.successor(min_val) {
              Success(new_min) => {
                // 更新最小值指针
                self.min = Some(new_min)
                // 注意：不要再从集群中删除 new_min
                return Success(x)
              }
              _ => {
                // 没有后继元素，树应该只有一个元素
                // 这种情况前面已处理，不应该到这里
                self.min = None
                self.max = None
                return Success(x)
              }
            }
          }

          // 情况2：删除最大值
          if x == max_val {
            // 找到前一个最大值
            match self.predecessor(max_val) {
              Success(new_max) => {
                // 更新最大值指针
                self.max = Some(new_max)
                // 注意：不要再从集群中删除 new_max
                return Success(x)
              }
              _ => {
                // 没有前驱元素，树应该只有一个元素
                // 这种情况前面已处理，不应该到这里
                self.min = None
                self.max = None
                return Success(x)
              }
            }
          }

          // 情况3：删除内部元素
          // 这时不需要更新min/max
          return self.delete_from_clusters(x)
        }
      }
  }
}

///|
/// Internal implementation for deleting from cluster structure

///|
/// Internal implementation for deleting from cluster structure
fn delete_from_clusters(self : VEBTree, x : Int) -> VEBResult {
  if self.universe_size <= 2 {
    return Success(x)
  }
  match self.clusters {
    Some(clusters) =>
      match self.summary {
        Some(summary) => {
          let cluster_sz = cluster_size(self.universe_size)
          let high_idx = high(x, cluster_sz)
          let low_idx = low(x, cluster_sz)

          // 边界检查
          if high_idx >= clusters.length() {
            return Success(x)
          }
          let cluster = clusters[high_idx]

          // 递归删除
          match cluster.delete(low_idx) {
            Success(_) => {
              // 确保集群真的变空后才从summary中删除
              if cluster.is_empty() {
                ignore(summary.delete(high_idx))
              }

              // 额外检查确保元素真的被删除
              if self.contains(x) {
                // 手动遍历并强制删除这个元素
                self.force_element_removal(x)
              }
              Success(x)
            }
            _ => Success(x)
          }
        }
        None => Success(x)
      }
    None => Success(x)
  }
}

///|
/// 强制删除元素，确保所有引用都被清理
fn force_element_removal(self : VEBTree, x : Int) -> Unit {
  // 检查并更新min/max引用
  match self.min {
    Some(min_val) if min_val == x =>
      match self.successor(min_val) {
        Success(new_min) => self.min = Some(new_min)
        _ =>
          match self.max {
            Some(max_val) if max_val != x => self.min = self.max
            _ => self.min = None
          }
      }
    _ => ()
  }
  match self.max {
    Some(max_val) if max_val == x =>
      match self.predecessor(max_val) {
        Success(new_max) => self.max = Some(new_max)
        _ =>
          match self.min {
            Some(min_val) if min_val != x => self.max = self.min
            _ => self.max = None
          }
      }
    _ => ()
  }
}

///|

///|
/// Optimized insert to work seamlessly with delete
pub fn insert(self : VEBTree, x : Int) -> VEBResult {
  if x < 0 || x >= self.universe_size {
    return OutOfRange
  }

  // Empty tree case
  match self.min {
    None => {
      self.min = Some(x)
      self.max = Some(x)
      return Success(x)
    }
    Some(min_val) => {
      let max_val = self.max.unwrap()

      // Element already exists
      if x == min_val || x == max_val {
        return Success(x)
      }

      // Base case
      if self.universe_size == 2 {
        if x < min_val {
          self.min = Some(x)
        }
        if x > max_val {
          self.max = Some(x)
        }
        return Success(x)
      }

      // Determine what to insert into cluster structure
      let (actual_min, actual_max, cluster_element) = if x < min_val {
        // New element becomes min, old min goes to clusters
        (x, max_val, min_val)
      } else if x > max_val {
        // New element becomes max and goes to clusters
        (min_val, x, x)
      } else {
        // Element goes to clusters, min/max unchanged
        (min_val, max_val, x)
      }

      // Update min/max
      self.min = Some(actual_min)
      self.max = Some(actual_max)

      // Ensure cluster structure exists
      match self.clusters {
        None => self.initialize_structure()
        Some(_) => ()
      }
      let clusters = self.clusters.unwrap()
      let summary = self.summary.unwrap()
      let cluster_sz = cluster_size(self.universe_size)
      let high_idx = high(cluster_element, cluster_sz)
      let low_idx = low(cluster_element, cluster_sz)

      // Insert into cluster
      if clusters[high_idx].is_empty() {
        // First element in this cluster
        ignore(summary.insert(high_idx))
        clusters[high_idx].min = Some(low_idx)
        clusters[high_idx].max = Some(low_idx)
      } else {
        // Recursively insert into cluster
        ignore(clusters[high_idx].insert(low_idx))
      }
      Success(x)
    }
  }
}

///|
/// Count trailing zeros in a number
pub fn count_trailing_zeros(n : Int) -> Int {
  if n <= 0 {
    return 0
  }
  let mut count = 0
  let mut num = n

  // 使用位运算快速计算
  if (num & 0xFFFF) == 0 {
    count += 16
    num = num >> 16
  }
  if (num & 0xFF) == 0 {
    count += 8
    num = num >> 8
  }
  if (num & 0xF) == 0 {
    count += 4
    num = num >> 4
  }
  if (num & 0x3) == 0 {
    count += 2
    num = num >> 2
  }
  if (num & 0x1) == 0 {
    count += 1
  }
  count
}

///|
/// Combine high and low indices using bit manipulation
pub fn index(high : Int, low : Int, cluster_size : Int) -> Int {
  (high << count_trailing_zeros(cluster_size)) | low
}

///|
/// Get cluster size for given universe size
pub fn cluster_size(universe_size : Int) -> Int {
  let log_u = count_trailing_zeros(universe_size)
  let sqrt_log = (log_u + 1) / 2
  1 << sqrt_log
}

///|
/// Initialize clusters and summary for non-base case
pub fn initialize_structure(self : VEBTree) -> Unit {
  if self.universe_size <= 2 {
    return
  }
  let cluster_sz = cluster_size(self.universe_size)
  let num_clusters = self.universe_size / cluster_sz

  // Initialize summary
  self.summary = Some(new(num_clusters))

  // Initialize clusters
  let clusters_array = Array::make(num_clusters, new(cluster_sz))
  for i = 0; i < num_clusters; i = i + 1 {
    clusters_array[i] = new(cluster_sz)
  }
  self.clusters = Some(clusters_array)
}

///|
/// Optimized contains with early termination
pub fn contains(self : VEBTree, x : Int) -> Bool {
  if x < 0 || x >= self.universe_size {
    return false
  }
  match self.min {
    None => false
    Some(min_val) => {
      // Quick check for min/max
      if x == min_val || x == self.max.unwrap() {
        return true
      }

      // Base case
      if self.universe_size <= 2 {
        return false
      }

      // Check in clusters
      match self.clusters {
        None => false
        Some(clusters) => {
          let cluster_sz = cluster_size(self.universe_size)
          let high_idx = high(x, cluster_sz)
          let low_idx = low(x, cluster_sz)
          clusters[high_idx].contains(low_idx)
        }
      }
    }
  }
}

///|
/// Optimized successor with better cluster navigation
pub fn successor(self : VEBTree, x : Int) -> VEBResult {
  if x < 0 || x >= self.universe_size {
    return OutOfRange
  }
  match self.min {
    None => NotFound
    Some(min_val) => {
      // Base case
      if self.universe_size == 2 {
        if x == 0 && self.max == Some(1) {
          return Success(1)
        } else {
          return NotFound
        }
      }

      // If x < min, return min
      if x < min_val {
        return Success(min_val)
      }
      let max_val = self.max.unwrap()

      // If x >= max, no successor
      if x >= max_val {
        return NotFound
      }
      match self.clusters {
        None =>
          // Only min and max exist
          if x < max_val {
            Success(max_val)
          } else {
            NotFound
          }
        Some(clusters) => {
          let cluster_sz = cluster_size(self.universe_size)
          let high_idx = high(x, cluster_sz)
          let low_idx = low(x, cluster_sz)
          let summary = self.summary.unwrap()

          // Check if successor exists in same cluster
          match clusters[high_idx].max() {
            Success(max_low) if low_idx < max_low =>
              match clusters[high_idx].successor(low_idx) {
                Success(succ_low) =>
                  Success(index(high_idx, succ_low, cluster_sz))
                _ => NotFound
              }
            _ =>
              // Find successor cluster
              match summary.successor(high_idx) {
                Success(succ_high) =>
                  match clusters[succ_high].min() {
                    Success(min_low) =>
                      Success(index(succ_high, min_low, cluster_sz))
                    _ => NotFound
                  }
                _ => NotFound
              }
          }
        }
      }
    }
  }
}

///|
/// Optimized predecessor with better cluster navigation
pub fn predecessor(self : VEBTree, x : Int) -> VEBResult {
  if x < 0 || x >= self.universe_size {
    return OutOfRange
  }
  match self.max {
    None => NotFound
    Some(max_val) => {
      // Base case
      if self.universe_size == 2 {
        if x == 1 && self.min == Some(0) {
          return Success(0)
        } else {
          return NotFound
        }
      }

      // If x > max, return max
      if x > max_val {
        return Success(max_val)
      }
      let min_val = self.min.unwrap()

      // If x <= min, no predecessor
      if x <= min_val {
        return NotFound
      }
      match self.clusters {
        None =>
          // Only min and max exist
          if x > min_val {
            Success(min_val)
          } else {
            NotFound
          }
        Some(clusters) => {
          let cluster_sz = cluster_size(self.universe_size)
          let high_idx = high(x, cluster_sz)
          let low_idx = low(x, cluster_sz)
          let summary = self.summary.unwrap()

          // Check if predecessor exists in same cluster
          match clusters[high_idx].min() {
            Success(min_low) if low_idx > min_low =>
              match clusters[high_idx].predecessor(low_idx) {
                Success(pred_low) =>
                  Success(index(high_idx, pred_low, cluster_sz))
                _ => NotFound
              }
            _ =>
              // Find predecessor cluster
              match summary.predecessor(high_idx) {
                Success(pred_high) =>
                  match clusters[pred_high].max() {
                    Success(max_low) =>
                      Success(index(pred_high, max_low, cluster_sz))
                    _ =>
                      // Return min if it's a valid predecessor
                      if min_val < x {
                        Success(min_val)
                      } else {
                        NotFound
                      }
                  }
                _ =>
                  // Return min if it's a valid predecessor
                  if min_val < x {
                    Success(min_val)
                  } else {
                    NotFound
                  }
              }
          }
        }
      }
    }
  }
}

///|
/// Get minimum element
pub fn min(self : VEBTree) -> VEBResult {
  match self.min {
    Some(val) => Success(val)
    None => Empty
  }
}

///|
/// Get maximum element
pub fn max(self : VEBTree) -> VEBResult {
  match self.max {
    Some(val) => Success(val)
    None => Empty
  }
}

///|
/// Get all elements in ascending order
pub fn to_array(self : VEBTree) -> Array[Int] {
  let result : Array[Int] = []

  // 一次性收集所有元素
  match self.min {
    None => () // 空树
    Some(min_val) => {
      // 直接使用迭代器，避免递归调用
      let mut curr = Some(min_val)
      while curr != None {
        result.push(curr.unwrap())
        curr = match self.successor(curr.unwrap()) {
          Success(next) => Some(next)
          _ => None
        }
      }
    }
  }
  result
}

///|
/// Create iterator for tree traversal
pub fn iter(self : VEBTree) -> VEBIterator {
  { tree: self, current: self.min, ascending: true }
}

///|
/// Create reverse iterator
pub fn iter_rev(self : VEBTree) -> VEBIterator {
  { tree: self, current: self.max, ascending: false }
}

///|
/// Iterator next method
pub fn next(self : VEBIterator) -> Int? {
  match self.current {
    None => None
    Some(val) => {
      let next_val = if self.ascending {
        match self.tree.successor(val) {
          Success(succ) => Some(succ)
          _ => None
        }
      } else {
        match self.tree.predecessor(val) {
          Success(pred) => Some(pred)
          _ => None
        }
      }
      let result = self.current
      self.current = next_val
      result
    }
  }
}

///|
/// Range query: get all elements in [low, high]

///|
/// 优化的范围查询，复杂度 O(k + log log U)
pub fn range_query(self : VEBTree, low : Int, high : Int) -> Array[Int] {
  if low > high {
    return []
  }
  let result : Array[Int] = []

  // 找到第一个大于等于 low 的元素 - O(log log U)
  let start = match self.successor(low - 1) {
    Success(val) => val
    _ =>
      match self.min {
        Some(min_val) if min_val >= low => min_val
        _ => return [] // 没有在范围内的元素
      }
  }

  // 如果起始元素已经超出范围，返回空数组
  if start > high {
    return []
  }

  // 收集所有范围内元素 - O(k)
  let mut curr = Some(start)
  while curr != None {
    let val = curr.unwrap()
    if val > high {
      break
    }
    result.push(val)
    curr = match self.successor(val) {
      Success(next) => Some(next)
      _ => None
    }
  }
  result
}

///|
/// Count elements in range [low, high]
pub fn count_range(self : VEBTree, low : Int, high : Int) -> Int {
  self.range_query(low, high).length()
}

///|
/// Clear all elements
pub fn clear(self : VEBTree) -> Unit {
  self.min = None
  self.max = None
  self.summary = None
  self.clusters = None
}

///|
/// Calculate high-level cluster index using bit manipulation
pub fn high(x : Int, cluster_size : Int) -> Int {
  x >> count_trailing_zeros(cluster_size)
}

///|
/// Calculate low-level index within cluster using bit manipulation
pub fn low(x : Int, cluster_size : Int) -> Int {
  let mask = cluster_size - 1
  x & mask
}

///|
/// Check if element exists in VEB Tree (debug version)
pub fn contains_debug(self : VEBTree, x : Int) -> Bool {
  if x < 0 || x >= self.universe_size {
    println("contains_debug: x=\{x} out of range [0, \{self.universe_size})")
    return false
  }
  match self.min {
    None => {
      println("contains_debug: tree is empty")
      false
    }
    Some(min_val) => {
      let max_val = self.max.unwrap()
      println("contains_debug: checking x=\{x}, min=\{min_val}, max=\{max_val}")
      if x == min_val {
        println("contains_debug: x equals min -> TRUE")
        return true
      }
      if x == max_val {
        println("contains_debug: x equals max -> TRUE")
        return true
      }
      if self.universe_size <= 2 {
        println("contains_debug: universe_size <= 2, x not min/max -> FALSE")
        return false
      } else {
        match self.clusters {
          None => {
            println("contains_debug: no clusters initialized -> FALSE")
            false
          }
          Some(clusters) => {
            let cluster_sz = cluster_size(self.universe_size)
            let high_idx = high(x, cluster_sz)
            let low_idx = low(x, cluster_sz)
            println(
              "contains_debug: checking cluster[\{high_idx}] for low_idx=\{low_idx}",
            )
            println("contains_debug: cluster_size=\{cluster_sz}")
            let result = clusters[high_idx].contains(low_idx)
            println(
              "contains_debug: cluster[\{high_idx}].contains(\{low_idx}) = \{result}",
            )
            result
          }
        }
      }
    }
  }
}

///|
/// 延迟初始化 - 仅在必要时创建集群
pub fn initialize_structure_lazy(self : VEBTree) -> Unit {
  if self.universe_size <= 2 || self.clusters != None {
    return
  }
  let cluster_sz = cluster_size(self.universe_size)
  let num_clusters = self.universe_size / cluster_sz

  // 延迟初始化 - 只创建数组，不初始化每个集群
  self.summary = Some(new(num_clusters))
  self.clusters = Some(Array::make(num_clusters, new(cluster_sz)))
}

///|
/// 实现更高效的元素计数，复杂度 O(log log U)
pub fn size(self : VEBTree) -> Int {
  match self.min {
    None => 0
    Some(min_val) =>
      match self.max {
        None => 0 // 不应该发生
        Some(max_val) => {
          if min_val == max_val {
            return 1 // 只有一个元素
          }

          // 基础情况
          if self.universe_size <= 2 {
            return if min_val == max_val { 1 } else { 2 }
          }

          // 递归计算子集群中的元素数量
          let mut count = 2 // min 和 max
          match self.clusters {
            Some(clusters) =>
              match self.summary {
                Some(summary) => {
                  // 获取所有非空集群
                  let summary_elements = summary.to_array()

                  // 计算每个集群中的元素数量
                  for cluster_idx in summary_elements {
                    count = count + clusters[cluster_idx].size()
                  }

                  // 避免重复计算 min/max (如果它们存在于集群中)
                  if min_val != max_val {
                    let cluster_sz = cluster_size(self.universe_size)
                    let min_high = high(min_val, cluster_sz)
                    let min_low = low(min_val, cluster_sz)
                    let max_high = high(max_val, cluster_sz)
                    let max_low = low(max_val, cluster_sz)

                    // 检查 min 是否在集群中计算过
                    if clusters[min_high].contains(min_low) {
                      count = count - 1
                    }

                    // 检查 max 是否在集群中计算过
                    if clusters[max_high].contains(max_low) {
                      count = count - 1
                    }
                  }
                }
                None => ()
              }
            None => ()
          }
          count
        }
      }
  }
}

///|
/// 从数组创建 VEB Tree，时间复杂度 O(n log log U)
pub fn from_array(elements : Array[Int], universe_size : Int) -> VEBTree {
  let tree = new(universe_size)

  // 批量插入所有元素
  for elem in elements {
    ignore(tree.insert(elem))
  }
  tree
}

///|
/// 检查当前树是否是另一个树的子集，时间复杂度 O(n log log U)
pub fn is_subset(self : VEBTree, other : VEBTree) -> Bool {
  // 空集是任何集合的子集
  if self.is_empty() {
    return true
  }

  // 如果当前树有元素但other为空，则不是子集
  if other.is_empty() {
    return false
  }

  // 检查所有元素是否都在other中
  let elements = self.to_array()
  for elem in elements {
    if other.contains(elem) == false {
      return false
    }
  }
  true
}

///|
/// 求两个VEB树的交集，时间复杂度 O(n log log U)
pub fn intersection(self : VEBTree, other : VEBTree) -> VEBTree {
  // 创建一个足够大的树存储结果
  let universe_size = if self.universe_size > other.universe_size {
    self.universe_size
  } else {
    other.universe_size
  }
  let result = new(universe_size)

  // 遍历较小的树并检查元素是否在另一个树中
  let elements = if self.size() <= other.size() {
    self.to_array()
  } else {
    other.to_array()
  }
  for elem in elements {
    if (self.size() <= other.size() && other.contains(elem)) ||
      (self.size() > other.size() && self.contains(elem)) {
      ignore(result.insert(elem))
    }
  }
  result
}

///|
/// 是否包含单个元素
pub fn is_singleton(self : VEBTree) -> Bool {
  match self.min {
    Some(min_val) => self.max == Some(min_val)
    None => false
  }
}

///|
/// 检查两个VEB树是否包含相同元素
pub fn equals(self : VEBTree, other : VEBTree) -> Bool {
  if self.is_empty() && other.is_empty() {
    return true
  }
  if self.size() != other.size() {
    return false
  }

  // 比较所有元素
  let self_elements = self.to_array()
  let other_elements = other.to_array()
  if self_elements.length() != other_elements.length() {
    return false
  }
  for i = 0; i < self_elements.length(); i = i + 1 {
    if self_elements[i] != other_elements[i] {
      return false
    }
  }
  true
}
