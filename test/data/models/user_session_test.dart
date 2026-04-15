import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_app/core/models/user_session.dart';

void main() {
  group('UserSession', () {
    const session = UserSession(
      userId: 'u001',
      name: 'John',
      email: 'john@test.com',
      site: 'WH-A',
      role: UserRole.worker,
      token: 'tok',
    );

    test('equality matches on userId and token', () {
      const same = UserSession(
        userId: 'u001',
        name: 'Different',
        email: 'other@test.com',
        site: 'WH-B',
        role: UserRole.supervisor,
        token: 'tok',
      );
      expect(session, equals(same));
    });

    test('different userId is not equal', () {
      const other = UserSession(
        userId: 'u002',
        name: 'John',
        email: 'john@test.com',
        site: 'WH-A',
        role: UserRole.worker,
        token: 'tok',
      );
      expect(session, isNot(equals(other)));
    });

    test('different token is not equal', () {
      const other = UserSession(
        userId: 'u001',
        name: 'John',
        email: 'john@test.com',
        site: 'WH-A',
        role: UserRole.worker,
        token: 'different-tok',
      );
      expect(session, isNot(equals(other)));
    });
  });
}
