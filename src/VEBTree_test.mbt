///|
/// Test bit manipulation functions
test "test_bit_functions" {
  // Test count_trailing_zeros
  assert_eq(count_trailing_zeros(1), 0) // 1 = 0001
  assert_eq(count_trailing_zeros(2), 1) // 2 = 0010
  assert_eq(count_trailing_zeros(4), 2) // 4 = 0100
  assert_eq(count_trailing_zeros(8), 3) // 8 = 1000
  assert_eq(count_trailing_zeros(16), 4) // 16 = 10000

  // Test cluster_size calculation
  assert_eq(cluster_size(4), 2) // universe 4 -> cluster 2
  assert_eq(cluster_size(16), 4) // universe 16 -> cluster 4
  assert_eq(cluster_size(256), 16) // universe 256 -> cluster 16

  // Test high and low functions for universe size 16
  let universe_size = 16
  let cluster_sz = cluster_size(universe_size) // Should be 4

  // Test various values
  let test_cases = [
    (0, 0, 0), // high=0, low=0
    (1, 0, 1), // high=0, low=1
    (4, 1, 0), // high=1, low=0
    (5, 1, 1), // high=1, low=1
    (13, 3, 1), // high=3, low=1
    (15, 3, 3), // high=3, low=3
  ]
  for case in test_cases {
    let (x, expected_high, expected_low) = case
    let h = high(x, cluster_sz)
    let l = low(x, cluster_sz)
    assert_eq(h, expected_high)
    assert_eq(l, expected_low)

    // Test index reconstruction
    let reconstructed = index(h, l, cluster_sz)
    assert_eq(reconstructed, x)
  }
}

///|
/// Test VEB Tree creation
test "test_veb_creation" {
  // Test normal creation
  let veb = new(16)
  assert_eq(veb.universe_size(), 16)
  assert_true(veb.is_empty())

  // Test power-of-2 creation
  let veb2 = new_pow2(4) // 2^4 = 16
  assert_eq(veb2.universe_size(), 16)

  // Test min/max on empty tree
  match veb.min() {
    Empty => assert_true(true)
    _ => abort("Empty tree should return Empty")
  }
  match veb.max() {
    Empty => assert_true(true)
    _ => abort("Empty tree should return Empty")
  }
}

///|
/// Test basic insert and contains operations
test "test_basic_insert_contains" {
  let veb = new(16)

  // Test single insertion
  match veb.insert(5) {
    Success(val) => assert_eq(val, 5)
    _ => abort("Insert should succeed")
  }
  assert_true(veb.contains(5))
  assert_false(veb.contains(3))
  assert_false(veb.is_empty())

  // Test min/max after single insert
  match veb.min() {
    Success(val) => assert_eq(val, 5)
    _ => abort("Should have min")
  }
  match veb.max() {
    Success(val) => assert_eq(val, 5)
    _ => abort("Should have max")
  }

  // Test multiple insertions
  ignore(veb.insert(10))
  ignore(veb.insert(3))
  ignore(veb.insert(12))
  ignore(veb.insert(1))

  // Check all elements exist
  assert_true(veb.contains(1))
  assert_true(veb.contains(3))
  assert_true(veb.contains(5))
  assert_true(veb.contains(10))
  assert_true(veb.contains(12))

  // Check non-existent elements
  assert_false(veb.contains(0))
  assert_false(veb.contains(7))
  assert_false(veb.contains(15))

  // Check min/max
  match veb.min() {
    Success(val) => assert_eq(val, 1)
    _ => abort("Should have min")
  }
  match veb.max() {
    Success(val) => assert_eq(val, 12)
    _ => abort("Should have max")
  }
}

///|
/// Test successor operation
test "test_successor" {
  let veb = new(16)

  // Insert elements: 1, 3, 5, 10, 12
  let elements = [1, 3, 5, 10, 12]
  for elem in elements {
    ignore(veb.insert(elem))
  }

  // Test successors
  match veb.successor(0) {
    Success(val) => assert_eq(val, 1)
    _ => abort("Successor of 0 should be 1")
  }
  match veb.successor(1) {
    Success(val) => assert_eq(val, 3)
    _ => abort("Successor of 1 should be 3")
  }
  match veb.successor(2) {
    Success(val) => assert_eq(val, 3)
    _ => abort("Successor of 2 should be 3")
  }
  match veb.successor(5) {
    Success(val) => assert_eq(val, 10)
    _ => abort("Successor of 5 should be 10")
  }
  match veb.successor(11) {
    Success(val) => assert_eq(val, 12)
    _ => abort("Successor of 11 should be 12")
  }

  // Test no successor
  match veb.successor(12) {
    NotFound => assert_true(true)
    _ => abort("12 should have no successor")
  }
  match veb.successor(15) {
    NotFound => assert_true(true)
    _ => abort("15 should have no successor")
  }
}

///|
/// Test predecessor operation
test "test_predecessor" {
  let veb = new(16)

  // Insert elements: 1, 3, 5, 10, 12
  let elements = [1, 3, 5, 10, 12]
  for elem in elements {
    ignore(veb.insert(elem))
  }

  // Test predecessors
  match veb.predecessor(15) {
    Success(val) => assert_eq(val, 12)
    _ => abort("Predecessor of 15 should be 12")
  }
  match veb.predecessor(12) {
    Success(val) => assert_eq(val, 10)
    _ => abort("Predecessor of 12 should be 10")
  }
  match veb.predecessor(11) {
    Success(val) => assert_eq(val, 10)
    _ => abort("Predecessor of 11 should be 10")
  }
  match veb.predecessor(5) {
    Success(val) => assert_eq(val, 3)
    _ => abort("Predecessor of 5 should be 3")
  }
  match veb.predecessor(2) {
    Success(val) => assert_eq(val, 1)
    _ => abort("Predecessor of 2 should be 1")
  }

  // Test no predecessor
  match veb.predecessor(1) {
    NotFound => assert_true(true)
    _ => abort("1 should have no predecessor")
  }
  match veb.predecessor(0) {
    NotFound => assert_true(true)
    _ => abort("0 should have no predecessor")
  }
}

///|
/// Test delete operation
test "test_delete" {
  let veb = new(16)

  // Insert elements
  let elements = [1, 3, 5, 10, 12]
  for elem in elements {
    ignore(veb.insert(elem))
  }

  // Test deleting non-existent element
  match veb.delete(7) {
    NotFound => assert_true(true)
    _ => abort("Deleting non-existent element should return NotFound")
  }

  // Test deleting existing element
  match veb.delete(5) {
    Success(val) => assert_eq(val, 5)
    _ => abort("Delete should succeed")
  }
  assert_false(veb.contains(5))
  assert_true(veb.contains(3))
  assert_true(veb.contains(10))

  // Test deleting min
  match veb.delete(1) {
    Success(val) => assert_eq(val, 1)
    _ => abort("Delete min should succeed")
  }
  match veb.min() {
    Success(val) => assert_eq(val, 3)
    _ => abort("New min should be 3")
  }

  // Test deleting max
  match veb.delete(12) {
    Success(val) => assert_eq(val, 12)
    _ => abort("Delete max should succeed")
  }
  match veb.max() {
    Success(val) => assert_eq(val, 10)
    _ => abort("New max should be 10")
  }

  // Delete remaining elements
  ignore(veb.delete(3))
  ignore(veb.delete(10))
  assert_true(veb.is_empty())
}

///|
/// Test edge cases with small universe
test "test_small_universe" {
  let veb = new(2)
  assert_true(veb.is_empty())

  // Insert into universe of size 2
  ignore(veb.insert(0))
  assert_true(veb.contains(0))
  assert_false(veb.contains(1))
  match veb.min() {
    Success(val) => assert_eq(val, 0)
    _ => abort("Min should be 0")
  }
  match veb.max() {
    Success(val) => assert_eq(val, 0)
    _ => abort("Max should be 0")
  }

  // Insert second element
  ignore(veb.insert(1))
  assert_true(veb.contains(0))
  assert_true(veb.contains(1))
  match veb.min() {
    Success(val) => assert_eq(val, 0)
    _ => abort("Min should be 0")
  }
  match veb.max() {
    Success(val) => assert_eq(val, 1)
    _ => abort("Max should be 1")
  }

  // Test successor/predecessor in small universe
  match veb.successor(0) {
    Success(val) => assert_eq(val, 1)
    _ => abort("Successor of 0 should be 1")
  }
  match veb.predecessor(1) {
    Success(val) => assert_eq(val, 0)
    _ => abort("Predecessor of 1 should be 0")
  }
}

///|
/// Test out of range operations
test "test_out_of_range" {
  let veb = new(8)

  // Test inserting out of range
  match veb.insert(-1) {
    OutOfRange => assert_true(true)
    _ => abort("Should return OutOfRange")
  }
  match veb.insert(8) {
    OutOfRange => assert_true(true)
    _ => abort("Should return OutOfRange")
  }

  // Test other operations out of range
  assert_false(veb.contains(-1))
  assert_false(veb.contains(8))
  match veb.successor(-1) {
    OutOfRange => assert_true(true)
    _ => abort("Should return OutOfRange")
  }
  match veb.predecessor(8) {
    OutOfRange => assert_true(true)
    _ => abort("Should return OutOfRange")
  }
  match veb.delete(-1) {
    OutOfRange => assert_true(true)
    _ => abort("Should return OutOfRange")
  }
}

///|
/// Test to_array functionality
test "test_to_array" {
  let veb = new(16)

  // Empty tree
  let empty_array = veb.to_array()
  assert_eq(empty_array.length(), 0)

  // Insert elements in random order
  let elements = [10, 3, 15, 1, 7, 12]
  for elem in elements {
    ignore(veb.insert(elem))
  }

  // Get sorted array
  let sorted_array = veb.to_array()
  let expected = [1, 3, 7, 10, 12, 15]
  assert_eq(sorted_array.length(), expected.length())
  for i = 0; i < sorted_array.length(); i = i + 1 {
    assert_eq(sorted_array[i], expected[i])
  }
}

///|
/// Test range query functionality
test "test_range_query" {
  let veb = new(32)

  // Insert elements
  let elements = [2, 5, 8, 12, 15, 20, 25, 30]
  for elem in elements {
    ignore(veb.insert(elem))
  }

  // Test various ranges
  let range1 = veb.range_query(5, 15)
  let expected1 = [5, 8, 12, 15]
  assert_eq(range1.length(), expected1.length())
  for i = 0; i < range1.length(); i = i + 1 {
    assert_eq(range1[i], expected1[i])
  }
  let range2 = veb.range_query(10, 22)
  let expected2 = [12, 15, 20]
  assert_eq(range2.length(), expected2.length())
  for i = 0; i < range2.length(); i = i + 1 {
    assert_eq(range2[i], expected2[i])
  }

  // Test empty range
  let range3 = veb.range_query(16, 19)
  assert_eq(range3.length(), 0)

  // Test count_range
  assert_eq(veb.count_range(5, 15), 4)
  assert_eq(veb.count_range(10, 22), 3)
  assert_eq(veb.count_range(16, 19), 0)
}

///|
/// Test clear functionality
test "test_clear" {
  let veb = new(16)

  // Insert elements
  ignore(veb.insert(5))
  ignore(veb.insert(10))
  ignore(veb.insert(3))
  assert_false(veb.is_empty())
  assert_true(veb.contains(5))

  // Clear tree
  veb.clear()
  assert_true(veb.is_empty())
  assert_false(veb.contains(5))
  assert_false(veb.contains(10))
  assert_false(veb.contains(3))
  match veb.min() {
    Empty => assert_true(true)
    _ => abort("Cleared tree should be empty")
  }
}

///|
/// Test large universe performance
test "test_large_universe" {
  let veb = new(1024) // 2^10

  // Insert every 37th number (to create sparse distribution)
  let mut i = 0
  while i < 1024 {
    ignore(veb.insert(i))
    i += 37
  }

  // Test that all inserted elements exist
  i = 0
  while i < 1024 {
    assert_true(veb.contains(i))
    i += 37
  }

  // Test that some non-inserted elements don't exist
  assert_false(veb.contains(1))
  assert_false(veb.contains(36))
  assert_false(veb.contains(38))

  // Test min and max
  match veb.min() {
    Success(val) => assert_eq(val, 0)
    _ => abort("Should have min")
  }

  // Find max inserted value
  let expected_max = (1024 - 1) / 37 * 37
  match veb.max() {
    Success(val) => assert_eq(val, expected_max)
    _ => abort("Should have max")
  }
}

///|
/// Test iterator functionality
test "test_iterator" {
  let veb = new(16)
  let elements = [2, 7, 3, 11, 5]
  for elem in elements {
    ignore(veb.insert(elem))
  }

  // Test ascending iterator
  let iter = veb.iter()
  let expected_asc = [2, 3, 5, 7, 11]
  for expected in expected_asc {
    match iter.next() {
      Some(val) => assert_eq(val, expected)
      None => abort("Iterator should have more elements")
    }
  }

  // Should be exhausted
  match iter.next() {
    None => assert_true(true)
    Some(_) => abort("Iterator should be exhausted")
  }

  // Test descending iterator
  let iter_rev = veb.iter_rev()
  let expected_desc = [11, 7, 5, 3, 2]
  for expected in expected_desc {
    match iter_rev.next() {
      Some(val) => assert_eq(val, expected)
      None => abort("Reverse iterator should have more elements")
    }
  }
}

///|
test "test_delete_step_by_step" {
  let veb = new(16)

  // Insert elements one by one and check state
  ignore(veb.insert(1))
  ignore(veb.insert(3))
  ignore(veb.insert(5))
  ignore(veb.insert(10))
  ignore(veb.insert(12))

  // Before deletion
  let max_before = veb.max()
  println("Max before deleting 12: \{max_before}")

  // Delete 12
  let delete_result = veb.delete(12)
  println("Delete result: \{delete_result}")

  // After deletion
  let max_after = veb.max()
  println("Max after deleting 12: \{max_after}")

  // Check if 12 is still there
  println("Contains 12 after deletion: \{veb.contains(12)}")

  // Check all elements
  println("All elements: \{veb.to_array()}")
}

///|
/// Enhanced debug test
test "test_delete_enhanced_debug" {
  let veb = new(16)

  // Insert elements
  ignore(veb.insert(1))
  ignore(veb.insert(3))
  ignore(veb.insert(5))
  ignore(veb.insert(10))
  ignore(veb.insert(12))
  println("Initial min: \{veb.min}")
  println("Initial max: \{veb.max}")

  // Check what happens with manual max field access
  println("Before delete - max field: \{veb.max}")
  println("Before delete - contains(12): \{veb.contains(12)}")

  // Delete 12
  let result = veb.delete(12)
  println("Delete result: \{result}")

  // Check fields directly after deletion
  println("After delete - max field: \{veb.max}")
  println("After delete - min field: \{veb.min}")
  println("After delete - contains(12): \{veb.contains(12)}")

  // Manually call max() function
  let max_func_result = veb.max()
  println("max() function result: \{max_func_result}")
}

///|
/// Test size and singleton methods
test "test_size_and_singleton" {
  let veb = new(16)

  // Empty tree
  assert_eq(veb.size(), 0)
  assert_false(veb.is_singleton())

  // Single element
  ignore(veb.insert(5))
  assert_eq(veb.size(), 1)
  assert_true(veb.is_singleton())

  // Multiple elements
  ignore(veb.insert(10))
  ignore(veb.insert(3))
  assert_eq(veb.size(), 3)
  assert_false(veb.is_singleton())

  // Back to singleton
  ignore(veb.delete(3))
  ignore(veb.delete(10))
  assert_eq(veb.size(), 1)
  assert_true(veb.is_singleton())
}

///|
/// Test set operations
test "test_set_operations" {
  // Create two trees with some common elements
  let veb1 = from_array([1, 3, 5, 7, 9], 16)
  let veb2 = from_array([3, 5, 7, 11, 13], 16)
  let veb3 = from_array([2, 4, 6, 8], 16)

  // Test subset relationships
  assert_false(veb1.is_subset(veb3)) // No common elements
  assert_false(veb1.is_subset(veb2)) // Some common elements

  // Create a proper subset
  let veb_subset = from_array([3, 7], 16)
  assert_true(veb_subset.is_subset(veb1))
  assert_true(veb_subset.is_subset(veb2))

  // Test intersection
  let intersection = veb1.intersection(veb2)
  let expected_intersection = [3, 5, 7]
  let actual_intersection = intersection.to_array()
  assert_eq(actual_intersection.length(), expected_intersection.length())
  for i = 0; i < actual_intersection.length(); i = i + 1 {
    assert_eq(actual_intersection[i], expected_intersection[i])
  }

  // Test empty intersection
  let empty_intersection = veb1.intersection(veb3)
  assert_true(empty_intersection.is_empty())
}

///|
/// Test from_array and equals
test "test_from_array_and_equals" {
  // Create a tree from array
  let elements = [3, 7, 12, 15, 20]
  let veb1 = from_array(elements, 32)

  // Create an identical tree manually
  let veb2 = new(32)
  for elem in elements {
    ignore(veb2.insert(elem))
  }

  // Trees should be equal
  assert_true(veb1.equals(veb2))

  // Modify one tree
  ignore(veb2.insert(10))
  assert_false(veb1.equals(veb2))

  // Make them equal again
  ignore(veb1.insert(10))
  assert_true(veb1.equals(veb2))

  // Different universe size but same elements
  let veb3 = from_array(elements, 64)
  ignore(veb3.insert(10))
  assert_true(veb3.equals(veb2))
}
