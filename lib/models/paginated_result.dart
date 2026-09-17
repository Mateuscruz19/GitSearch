class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final bool hasMore;
  final int? totalCount;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.hasMore,
    this.totalCount,
  });

  int get nextPage => page + 1;
}
