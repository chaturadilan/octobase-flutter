import 'package:flutter_test/flutter_test.dart';
import 'package:octobase_flutter/octobase_flutter.dart';

void main() {
  test('register a user', () async {
    Octobase octobase =
        OctobaseServer.init('http://10.0.3.2/octo/dev', 'api/school/v1');
    octobase
        .register('Hello', 'Dilan', 'bcdilan@gmail.com', 'bcdilan',
            'dilan123456', 'dilan123456')
        .then((value) {
      print(value.email);
    }).onError((error, stackTrace) {
      print(error.toString());
      print(stackTrace.toString());
    });
  });
}
