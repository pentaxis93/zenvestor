import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/errors/domain_error.dart';
import 'package:zenvestor_server/src/domain/value_objects/grade.dart';

void main() {
  group('Grade', () {
    group('create', () {
      group('valid grades', () {
        test('should create Grade with uppercase letter A', () {
          final result = Grade.create('A');

          expect(result.isRight(), isTrue);
          result.fold(
            (error) => fail('Should not fail'),
            (grade) => expect(grade.value, equals('A')),
          );
        });

        test('should create Grade with uppercase letter B', () {
          final result = Grade.create('B');

          expect(result.isRight(), isTrue);
          result.fold(
            (error) => fail('Should not fail'),
            (grade) => expect(grade.value, equals('B')),
          );
        });

        test('should create Grade with uppercase letter C', () {
          final result = Grade.create('C');

          expect(result.isRight(), isTrue);
          result.fold(
            (error) => fail('Should not fail'),
            (grade) => expect(grade.value, equals('C')),
          );
        });

        test('should create Grade with uppercase letter D', () {
          final result = Grade.create('D');

          expect(result.isRight(), isTrue);
          result.fold(
            (error) => fail('Should not fail'),
            (grade) => expect(grade.value, equals('D')),
          );
        });

        test('should create Grade with uppercase letter F', () {
          final result = Grade.create('F');

          expect(result.isRight(), isTrue);
          result.fold(
            (error) => fail('Should not fail'),
            (grade) => expect(grade.value, equals('F')),
          );
        });

        test('should normalize lowercase to uppercase for a', () {
          final result = Grade.create('a');

          expect(result.isRight(), isTrue);
          result.fold(
            (error) => fail('Should not fail'),
            (grade) => expect(grade.value, equals('A')),
          );
        });

        test('should normalize lowercase to uppercase for all valid grades',
            () {
          final testCases = ['a', 'b', 'c', 'd', 'f'];
          final expected = ['A', 'B', 'C', 'D', 'F'];

          for (var i = 0; i < testCases.length; i++) {
            final result = Grade.create(testCases[i]);

            expect(result.isRight(), isTrue);
            result.fold(
              (error) => fail('Should not fail for ${testCases[i]}'),
              (grade) => expect(grade.value, equals(expected[i])),
            );
          }
        });

        test('should trim whitespace and accept grade with leading spaces', () {
          final result = Grade.create('  A');

          expect(result.isRight(), isTrue);
          result.fold(
            (error) => fail('Should not fail'),
            (grade) => expect(grade.value, equals('A')),
          );
        });

        test('should trim whitespace and accept grade with trailing spaces',
            () {
          final result = Grade.create('B  ');

          expect(result.isRight(), isTrue);
          result.fold(
            (error) => fail('Should not fail'),
            (grade) => expect(grade.value, equals('B')),
          );
        });

        test('should trim whitespace and accept grade with surrounding spaces',
            () {
          final result = Grade.create('  C  ');

          expect(result.isRight(), isTrue);
          result.fold(
            (error) => fail('Should not fail'),
            (grade) => expect(grade.value, equals('C')),
          );
        });

        test('should handle lowercase with whitespace', () {
          final result = Grade.create(' d ');

          expect(result.isRight(), isTrue);
          result.fold(
            (error) => fail('Should not fail'),
            (grade) => expect(grade.value, equals('D')),
          );
        });
      });

      group('invalid grades', () {
        test('should return error for empty string', () {
          final result = Grade.create('');

          expect(result.isLeft(), isTrue);
          result.fold(
            (error) {
              expect(error, isA<GradeEmpty>());
              expect(error.message, equals('Grade cannot be empty'));
              expect((error as GradeEmpty).providedValue, equals(''));
            },
            (grade) => fail('Should not succeed'),
          );
        });

        test('should return error for whitespace only', () {
          final result = Grade.create('   ');

          expect(result.isLeft(), isTrue);
          result.fold(
            (error) {
              expect(error, isA<GradeEmpty>());
              expect(error.message, equals('Grade cannot be empty'));
              expect((error as GradeEmpty).providedValue, equals('   '));
            },
            (grade) => fail('Should not succeed'),
          );
        });

        test('should return error for invalid letter E', () {
          final result = Grade.create('E');

          expect(result.isLeft(), isTrue);
          result.fold(
            (error) {
              expect(error, isA<GradeInvalidValue>());
              expect(error.message, equals('Grade must be A, B, C, D, or F'));
              expect((error as GradeInvalidValue).actualValue, equals('E'));
            },
            (grade) => fail('Should not succeed'),
          );
        });

        test('should return error for invalid letters', () {
          final invalidLetters = ['E', 'G', 'H', 'X', 'Y', 'Z'];

          for (final letter in invalidLetters) {
            final result = Grade.create(letter);

            expect(result.isLeft(), isTrue);
            result.fold(
              (error) {
                expect(error, isA<GradeInvalidValue>());
                expect(error.message, equals('Grade must be A, B, C, D, or F'));
                expect(
                    (error as GradeInvalidValue).actualValue, equals(letter));
              },
              (grade) => fail('Should not succeed for $letter'),
            );
          }
        });

        test('should return error for grade with modifier A+', () {
          final result = Grade.create('A+');

          expect(result.isLeft(), isTrue);
          result.fold(
            (error) {
              expect(error, isA<GradeInvalidValue>());
              expect(error.message, equals('Grade must be A, B, C, D, or F'));
              expect((error as GradeInvalidValue).actualValue, equals('A+'));
            },
            (grade) => fail('Should not succeed'),
          );
        });

        test('should return error for grade modifiers', () {
          final invalidGrades = [
            'A+',
            'A-',
            'B+',
            'B-',
            'C+',
            'C-',
            'D+',
            'D-',
            'F+',
            'F-'
          ];

          for (final grade in invalidGrades) {
            final result = Grade.create(grade);

            expect(result.isLeft(), isTrue);
            result.fold(
              (error) {
                expect(error, isA<GradeInvalidValue>());
                expect(error.message, equals('Grade must be A, B, C, D, or F'));
                expect((error as GradeInvalidValue).actualValue, equals(grade));
              },
              (grade) => fail('Should not succeed for $grade'),
            );
          }
        });

        test('should return error for numeric input', () {
          final numericInputs = ['1', '2', '90', '100', '0'];

          for (final input in numericInputs) {
            final result = Grade.create(input);

            expect(result.isLeft(), isTrue);
            result.fold(
              (error) {
                expect(error, isA<GradeInvalidValue>());
                expect(error.message, equals('Grade must be A, B, C, D, or F'));
                expect((error as GradeInvalidValue).actualValue, equals(input));
              },
              (grade) => fail('Should not succeed for $input'),
            );
          }
        });

        test('should return error for special characters', () {
          final specialChars = ['@', '#', '!', '%', '^', '&', '*', '(', ')'];

          for (final char in specialChars) {
            final result = Grade.create(char);

            expect(result.isLeft(), isTrue);
            result.fold(
              (error) {
                expect(error, isA<GradeInvalidValue>());
                expect(error.message, equals('Grade must be A, B, C, D, or F'));
                expect((error as GradeInvalidValue).actualValue, equals(char));
              },
              (grade) => fail('Should not succeed for $char'),
            );
          }
        });

        test('should return error for multiple characters', () {
          final multipleChars = ['AA', 'BB', 'ABC', 'ABCD', 'FF'];

          for (final chars in multipleChars) {
            final result = Grade.create(chars);

            expect(result.isLeft(), isTrue);
            result.fold(
              (error) {
                expect(error, isA<GradeInvalidValue>());
                expect(error.message, equals('Grade must be A, B, C, D, or F'));
                expect((error as GradeInvalidValue).actualValue, equals(chars));
              },
              (grade) => fail('Should not succeed for $chars'),
            );
          }
        });
      });
    });

    group('equality', () {
      test('should be equal when grades have same value', () {
        final result1 = Grade.create('A');
        final result2 = Grade.create('A');

        expect(result1.isRight(), isTrue);
        expect(result2.isRight(), isTrue);

        final grade1 = result1.fold((error) => null, (grade) => grade)!;
        final grade2 = result2.fold((error) => null, (grade) => grade)!;

        expect(grade1, equals(grade2));
        expect(grade1.hashCode, equals(grade2.hashCode));
      });

      test('should be equal when created from different case', () {
        final result1 = Grade.create('A');
        final result2 = Grade.create('a');

        expect(result1.isRight(), isTrue);
        expect(result2.isRight(), isTrue);

        final grade1 = result1.fold((error) => null, (grade) => grade)!;
        final grade2 = result2.fold((error) => null, (grade) => grade)!;

        expect(grade1, equals(grade2));
        expect(grade1.hashCode, equals(grade2.hashCode));
      });

      test('should be equal when created with whitespace', () {
        final result1 = Grade.create('B');
        final result2 = Grade.create(' B ');

        expect(result1.isRight(), isTrue);
        expect(result2.isRight(), isTrue);

        final grade1 = result1.fold((error) => null, (grade) => grade)!;
        final grade2 = result2.fold((error) => null, (grade) => grade)!;

        expect(grade1, equals(grade2));
        expect(grade1.hashCode, equals(grade2.hashCode));
      });

      test('should not be equal when grades have different values', () {
        final result1 = Grade.create('A');
        final result2 = Grade.create('B');

        expect(result1.isRight(), isTrue);
        expect(result2.isRight(), isTrue);

        final grade1 = result1.fold((error) => null, (grade) => grade)!;
        final grade2 = result2.fold((error) => null, (grade) => grade)!;

        expect(grade1, isNot(equals(grade2)));
        expect(grade1.hashCode, isNot(equals(grade2.hashCode)));
      });

      test('should not be equal for all different grade pairs', () {
        final grades = ['A', 'B', 'C', 'D', 'F'];

        for (var i = 0; i < grades.length; i++) {
          for (var j = i + 1; j < grades.length; j++) {
            final result1 = Grade.create(grades[i]);
            final result2 = Grade.create(grades[j]);

            expect(result1.isRight(), isTrue);
            expect(result2.isRight(), isTrue);

            final grade1 = result1.fold((error) => null, (grade) => grade)!;
            final grade2 = result2.fold((error) => null, (grade) => grade)!;

            expect(grade1, isNot(equals(grade2)),
                reason: '${grades[i]} should not equal ${grades[j]}');
          }
        }
      });
    });

    group('toString', () {
      test('should return Grade(A) format', () {
        final result = Grade.create('A');

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not fail'),
          (grade) => expect(grade.toString(), equals('Grade(A)')),
        );
      });

      test('should return correct format for all grades', () {
        final grades = ['A', 'B', 'C', 'D', 'F'];

        for (final gradeValue in grades) {
          final result = Grade.create(gradeValue);

          expect(result.isRight(), isTrue);
          result.fold(
            (error) => fail('Should not fail for $gradeValue'),
            (grade) => expect(grade.toString(), equals('Grade($gradeValue)')),
          );
        }
      });

      test('should return normalized value in toString', () {
        final result = Grade.create(' a ');

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not fail'),
          (grade) => expect(grade.toString(), equals('Grade(A)')),
        );
      });
    });

    group('error interface implementations', () {
      test('GradeEmpty implements RequiredFieldError interface', () {
        const error = GradeEmpty('  ');

        expect(error.fieldContext, equals('grade'));
        expect(error.toString(), equals('GradeEmpty(providedValue:   )'));
        expect(error.props, equals(['  ']));
      });

      test('GradeInvalidValue implements FormatValidationError interface', () {
        const error = GradeInvalidValue('X');

        expect(error.expectedFormat, equals('A, B, C, D, or F'));
        expect(error.fieldContext, equals('grade'));
        expect(error.toString(), equals('GradeInvalidValue(actualValue: X)'));
        expect(error.props, equals(['X']));
      });

      test('GradeEmpty equality', () {
        const error1 = GradeEmpty('');
        const error2 = GradeEmpty('');
        const error3 = GradeEmpty(' ');

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });

      test('GradeInvalidValue equality', () {
        const error1 = GradeInvalidValue('E');
        const error2 = GradeInvalidValue('E');
        const error3 = GradeInvalidValue('G');

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });
    });
  });
}
