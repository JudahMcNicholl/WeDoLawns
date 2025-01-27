import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';

class GSign {
  GSign._();
  static final GSign instance = GSign._();
  final GoogleSignIn googleSignIn = GoogleSignIn.standard(scopes: [
    DriveApi.driveReadonlyScope,
  ]);
}
