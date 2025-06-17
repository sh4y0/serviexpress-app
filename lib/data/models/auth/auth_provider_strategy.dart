import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:serviexpress_app/core/exceptions/error_mapper.dart';
import 'package:serviexpress_app/core/exceptions/error_state.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';

abstract class AuthProviderStrategy {
  Future<ResultState<User>> authenticate();
  String get name;
}

class GoogleAuthProviderStrategy extends AuthProviderStrategy {
  @override
  String get name => 'Google';

  @override
  Future<ResultState<User>> authenticate() async {
    try {
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return const Failure(UserNotFound("Inicio de sesión cancelado."));
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) {
        return const Failure(UnknownError("No se pudo autenticar con Google."));
      }

      return Success(user);
    } on FirebaseAuthException catch (e) {
      return Failure(ErrorMapper.map(e));
    } catch (e) {
      return const Failure(
        UnknownError("Error inesperado en login con Google."),
      );
    }
  }
}

class FacebookAuthProviderStrategy extends AuthProviderStrategy {
  @override
  String get name => 'Facebook';

  @override
  Future<ResultState<User>> authenticate() async {
    try {
      await FacebookAuth.instance.logOut();

      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (loginResult.status != LoginStatus.success) {
        return const Failure(
          UserNotFound("Inicio de sesión cancelado o fallido."),
        );
      }

      final accessToken = loginResult.accessToken;
      if (accessToken == null) {
        return const Failure(UserNotFound("No se obtuvo token de Facebook."));
      }

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(accessToken.tokenString);

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      final User? user = userCredential.user;
      if (user == null) {
        return const Failure(
          UnknownError("No se pudo autenticar con Facebook."),
        );
      }

      return Success(user);
    } on FirebaseAuthException catch (e) {
      return Failure(ErrorMapper.map(e));
    } catch (e) {
      return const Failure(
        UnknownError("Error inesperado en login con Facebook."),
      );
    }
  }
}

class AppleAuthProviderStrategy extends AuthProviderStrategy {
  @override
  String get name => 'Apple';

  @override
  Future<ResultState<User>> authenticate() async {
    return const Failure(
      UnknownError("Autenticación con Apple no implementada."),
    );
  }
}
