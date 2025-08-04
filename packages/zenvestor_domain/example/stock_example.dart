import 'package:fpdart/fpdart.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart';

void main() {
  // Example 1: Creating a stock with all fields
  print('Example 1: Creating a stock with all fields');
  final tickerResult = TickerSymbol.create('AAPL');
  final nameResult = CompanyName.create('Apple Inc.');
  final sicResult = SicCode.create('3571');
  final gradeResult = Grade.create('A');

  // Using Either's fold to handle potential errors
  tickerResult.fold(
    (error) => print('Error creating ticker: $error'),
    (ticker) {
      nameResult.fold(
        (error) => print('Error creating name: $error'),
        (name) {
          sicResult.fold(
            (error) => print('Error creating SIC code: $error'),
            (sicCode) {
              gradeResult.fold(
                (error) => print('Error creating grade: $error'),
                (grade) {
                  // Create stock with all fields
                  final stockResult = Stock.create(
                    ticker: ticker,
                    name: Some(name),
                    sicCode: Some(sicCode),
                    grade: Some(grade),
                  );

                  stockResult.fold(
                    (error) => print('Error creating stock: $error'),
                    (stock) {
                      print('Created stock: $stock');
                      print('Ticker: ${stock.ticker.value}');
                      print(
                          'Name: ${stock.name.fold(() => 'None', (n) => n.value)}');
                      print(
                          'SIC Code: ${stock.sicCode.fold(() => 'None', (s) => s.value)}');
                      print(
                          'Grade: ${stock.grade.fold(() => 'None', (g) => g.value)}');
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  );

  print('\n${'-' * 50}\n');

  // Example 2: Creating a minimal stock (only ticker)
  print('Example 2: Creating a minimal stock');
  final minimalTickerResult = TickerSymbol.create('MSFT');

  minimalTickerResult.fold(
    (error) => print('Error: $error'),
    (ticker) {
      final stockResult = Stock.create(ticker: ticker);

      stockResult.fold(
        (error) => print('Error: $error'),
        (stock) {
          print('Created minimal stock: $stock');
          print('Has name: ${stock.name.isSome()}');
          print('Has SIC code: ${stock.sicCode.isSome()}');
          print('Has grade: ${stock.grade.isSome()}');
        },
      );
    },
  );

  print('\n${'-' * 50}\n');

  // Example 3: Using copyWith to update a stock
  print('Example 3: Using copyWith to update stock');
  final originalTickerResult = TickerSymbol.create('GOOGL');
  final originalNameResult = CompanyName.create('Alphabet Inc.');

  originalTickerResult.fold(
    (error) => print('Error: $error'),
    (ticker) {
      originalNameResult.fold(
        (error) => print('Error: $error'),
        (name) {
          final originalStock = Stock.create(
            ticker: ticker,
            name: Some(name),
          ).getOrElse((error) => throw Exception('Failed to create stock'));

          print('Original stock: $originalStock');

          // Update the grade
          final newGradeResult = Grade.create('B');
          newGradeResult.fold(
            (error) => print('Error: $error'),
            (newGrade) {
              final updatedStock = originalStock.copyWith(
                grade: Some(newGrade),
              );

              print('Updated stock: $updatedStock');
              print(
                  'Grade changed from None to ${updatedStock.grade.fold(() => 'None', (g) => g.value)}');
            },
          );
        },
      );
    },
  );

  print('\n${'-' * 50}\n');

  // Example 4: Error handling
  print('Example 4: Error handling');

  // Invalid ticker (too long)
  final invalidTickerResult = TickerSymbol.create('TOOLONG');
  invalidTickerResult.fold(
    (error) => print('Expected error for invalid ticker: $error'),
    (ticker) => print('This should not happen'),
  );

  // Invalid grade
  final invalidGradeResult = Grade.create('E'); // E is not a valid grade
  invalidGradeResult.fold(
    (error) => print('Expected error for invalid grade: $error'),
    (grade) => print('This should not happen'),
  );

  // Invalid SIC code
  final invalidSicResult = SicCode.create('ABC'); // Not numeric
  invalidSicResult.fold(
    (error) => print('Expected error for invalid SIC code: $error'),
    (sicCode) => print('This should not happen'),
  );
}
