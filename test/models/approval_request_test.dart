import 'package:flutter_test/flutter_test.dart';
import '../helpers/approval_test_data.dart';

void main() {
  test('copyWith can clear the attention message', () {
    final request = buildRequest(attentionMessage: 'تنبيه');

    expect(request.copyWith().attentionMessage, 'تنبيه');
    expect(
      request.copyWith(clearAttentionMessage: true).attentionMessage,
      isNull,
    );
  });
}
