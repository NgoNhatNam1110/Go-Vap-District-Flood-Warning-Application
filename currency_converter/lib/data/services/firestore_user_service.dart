import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_converter/data/models/user_model.dart';

/// Service quản lý dữ liệu người dùng trên Firestore
/// Thực hiện CRUD operations (Create, Read, Update, Delete) cho tài liệu người dùng
class FirestoreUserService {
  static final FirestoreUserService _instance =
      FirestoreUserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  FirestoreUserService._internal();

  factory FirestoreUserService() {
    return _instance;
  }

  /// Tạo tài liệu người dùng mới
  /// 
  /// Tham số:
  /// - user: Mô hình UserModel chứa thông tin người dùng
  /// 
  /// Ném Exception nếu có lỗi khi ghi dữ liệu
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(user.toJson());
    } catch (e) {
      throw Exception('Lỗi tạo tài khoản: $e');
    }
  }

  /// Lấy thông tin người dùng từ Firestore
  /// 
  /// Tham số:
  /// - uid: ID người dùng
  /// 
  /// Trả về: UserModel nếu tìm thấy, null nếu không tồn tại
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data() ?? {});
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi lấy thông tin người dùng: $e');
    }
  }

  /// Cập nhật thông tin người dùng
  /// 
  /// Tham số:
  /// - uid: ID người dùng
  /// - userData: Dữ liệu cần cập nhật (partial update)
  /// 
  /// Ném Exception nếu có lỗi khi cập nhật
  Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        ...userData,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Lỗi cập nhật thông tin: $e');
    }
  }

  /// Xóa tài liệu người dùng
  /// 
  /// Tham số:
  /// - uid: ID người dùng
  /// 
  /// Ném Exception nếu có lỗi khi xóa
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).delete();
    } catch (e) {
      throw Exception('Lỗi xóa tài khoản: $e');
    }
  }

  /// Theo dõi thông tin người dùng theo thời gian thực
  /// 
  /// Tham số:
  /// - uid: ID người dùng
  /// 
  /// Trả về: Stream<UserModel?> để tự động cập nhật UI khi dữ liệu thay đổi
  Stream<UserModel?> watchUser(String uid) {
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromJson(doc.data() ?? {}) : null);
  }

  /// Kiểm tra email đã tồn tại chưa
  /// 
  /// Tham số:
  /// - email: Email cần kiểm tra
  /// 
  /// Trả về: true nếu email đã tồn tại, false nếu chưa
  Future<bool> emailExists(String email) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Lỗi kiểm tra email: $e');
    }
  }
}
