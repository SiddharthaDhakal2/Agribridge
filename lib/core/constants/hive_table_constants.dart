class HiveTableConstant {
  HiveTableConstant._();

  //Database name
  static const String dbName = 'agribridge_db';

  static const int batchTypeID = 0;
  static const String batchTable = 'batch_table';

  static const int authTypeId = 1;
  static const String authTable = 'student_table';

  static const int itemTypeID = 2;
  static const String itemTable = 'item_table';

  static const int categoryTypeId = 3;
  static const String categoryTable = 'category_table';

  static const int commentsTypeId = 4;
  static const String commentsTable = 'comments_table';

  // Product table for home screen/products
  static const int productTypeId = 5;
  static const String productTable = 'product_table';

  // Order table for order history cache
  static const int orderTypeId = 7;
  static const String orderTable = 'order_table';
}
