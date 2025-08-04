import 'package:test/test.dart';
import 'package:zenvestor_domain/shared/errors.dart';

// Test implementation of DomainError to verify the abstract class behavior
class _TestDomainError extends DomainError {
  const _TestDomainError(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

void main() {
  group('DomainError', () {
    test('is abstract and can be extended', () {
      const error = _TestDomainError('test');
      expect(error, isA<DomainError>());
    });

    test('uses Equatable for equality', () {
      const error1 = _TestDomainError('same');
      const error2 = _TestDomainError('same');
      const error3 = _TestDomainError('different');

      expect(error1, equals(error2));
      expect(error1.hashCode, equals(error2.hashCode));
      expect(error1, isNot(equals(error3)));
    });

    test('toString returns meaningful representation', () {
      const error = _TestDomainError('test-value');
      expect(error.toString(), contains('_TestDomainError'));
    });
  });
}
