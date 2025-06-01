import 'package:serviexpress_app/data/models/user_model.dart';

class AuthResult {
  final UserModel userModel;
  final bool isNewUser;
  final bool needsProfileCompletion;

  const AuthResult({
    required this.userModel,
    this.isNewUser = false,
    this.needsProfileCompletion = false,
  });
}