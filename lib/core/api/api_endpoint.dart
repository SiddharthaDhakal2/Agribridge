
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  static const String baseUrl = 'http://10.0.2.2:3000/agribridge';
  //static const String baseUrl = 'http://localhost:3000/agribridge';
  //static const String baseUrl = 'http://192.168.1.xxx:3000/agribridge'; // Replace xxx with your IP
  // For Android Emulator use: 'http://10.0.2.2:3000/agribridge'
  // For iOS Simulator use: 'http://localhost:3000/agribridge'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:3000/agribridge'
  // For Windows Desktop use: 'http://localhost:3000/agribridge'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // // ============ Batch Endpoints ============
  // static const String batches = '/batches';
  // static String batchById(String id) => '/batches/$id';

  // // ============ Category Endpoints ============
  // static const String categories = '/categories';
  // static String categoryById(String id) => '/categories/$id';

  // ============ Customer Endpoints ============
  static const String customers = '/customers';
  static const String customerLogin = '/customers/login';
  static const String customerRegister = '/customers/signup';
  // static String customerById(String id) => '/customers/$id';
  // // ============ Item Endpoints ============
  // static const String items = '/items';
  // static String itemById(String id) => '/items/$id';
  // static String itemClaim(String id) => '/items/$id/claim';

  // ============ Comment Endpoints ============
  // static const String comments = '/comments';
  // static String commentById(String id) => '/comments/$id';
  // static String commentsByItem(String itemId) => '/comments/item/$itemId';
  // static String commentLike(String id) => '/comments/$id/like';
}

