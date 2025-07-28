/// Valid company names for testing.
class CompanyNameFixtures {
  CompanyNameFixtures._();

  /// Common valid company names used in the stock market.
  static const List<String> validNames = [
    'Apple Inc.',
    'Microsoft Corporation',
    'Alphabet Inc. Class A',
    'Berkshire Hathaway',
    '3M Company',
    'AT&T Inc.',
    'S&P Global',
    'Johnson & Johnson',
    'Procter & Gamble Co.',
    'JPMorgan Chase & Co.',
    'The Walt Disney Company',
    'Meta Platforms, Inc.',
    'Amazon.com, Inc.',
    "McDonald's Corporation",
    "O'Reilly Automotive, Inc.",
    'Barnes & Noble, Inc.',
    "Moody's Corporation",
  ];

  /// Company names with various punctuation marks.
  static const List<String> namesWithPunctuation = [
    'A.B.C. Company',
    'Smith, Jones & Associates',
    'Tech-Solutions Inc.',
    'Parent (Subsidiary) Ltd.',
    'Company & Co.',
    'First-Rate Solutions',
  ];

  /// Company names starting with numbers.
  static const List<String> namesStartingWithNumbers = [
    '3M Company',
    '21st Century Fox',
    '7-Eleven, Inc.',
    '99 Cents Only Stores',
  ];

  /// Single character company names.
  static const List<String> singleCharacterNames = ['A', '1', 'X'];

  /// Company names with minimal alphanumeric content.
  static const List<String> minimalAlphanumericNames = [
    '...A...',
    '---1---',
    '(X)',
    '& B &',
  ];

  /// Test cases for whitespace normalization.
  /// Each tuple contains (input, expected) pairs.
  static const List<(String, String)> whitespaceNormalizationCases = [
    ('  Apple Inc.  ', 'Apple Inc.'),
    ('\tMicrosoft\t', 'Microsoft'),
    ('\n3M Company\n', '3M Company'),
    ('   Leading spaces', 'Leading spaces'),
    ('Trailing spaces   ', 'Trailing spaces'),
  ];

  /// Test cases for multiple space normalization.
  /// Each tuple contains (input, expected) pairs.
  static const List<(String, String)> multipleSpaceNormalizationCases = [
    ('Apple    Inc.', 'Apple Inc.'),
    ('Microsoft  Corporation', 'Microsoft Corporation'),
    ('A   B   C', 'A B C'),
    ('Multiple   spaces    everywhere', 'Multiple spaces everywhere'),
  ];

  /// Invalid company names - empty or whitespace only.
  static const List<String> emptyOrWhitespaceNames = [
    '',
    ' ',
    '  ',
    '\t',
    '\n',
    '   \t\n   ',
  ];

  /// Invalid company names - no alphanumeric characters.
  static const List<String> noAlphanumericNames = [
    '...',
    '---',
    '&&&',
    '()',
    ', , ,',
    '!!!',
    '***',
  ];

  /// Invalid company names - containing invalid characters.
  static const List<String> invalidCharacterNames = [
    'Apple 😊 Inc.',
    'Microsoft\u0000Corp',
    'Company@Email.com',
    'Stock#1',
    r'Price$100',
    'Rate%5',
    'A+B',
    'C=D',
    'E[F]',
    'G{H}',
    'I<J>',
    'K|L',
    r'M\N',
    'O/P',
    'Q?R',
    'S*T',
    'U~V',
    'W^X',
    'Y!Z',
  ];

  /// Generates a company name that exceeds the maximum length.
  static String generateTooLongName() => 'A' * 256;

  /// Generates a company name with exactly the maximum allowed length.
  static String generateMaxLengthName() => 'A' * 255;
}
