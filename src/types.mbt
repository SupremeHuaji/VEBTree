///|
/// Van Emde Boas Tree supporting integers in range [0, universe_size)
/// Uses bit manipulation for optimal performance
pub(all) struct VEBTree {
  /// Size of the universe (must be power of 2)
  universe_size : Int
  /// Minimum element in the tree
  mut min : Int?
  /// Maximum element in the tree  
  mut max : Int?
  /// Summary structure for high-level clusters
  mut summary : VEBTree?
  /// Array of cluster structures for low-level elements
  mut clusters : Array[VEBTree]?
} derive(Show, Eq)

///|
/// Result type for VEB Tree operations
pub(all) enum VEBResult {
  Success(Int)
  NotFound
  Empty
  OutOfRange
} derive(Show, Eq)

///|
/// Iterator for VEB Tree traversal
pub(all) struct VEBIterator {
  tree : VEBTree
  mut current : Int?
  ascending : Bool
} derive(Show)
