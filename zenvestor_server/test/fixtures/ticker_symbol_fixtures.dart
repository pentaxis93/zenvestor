/// Valid ticker symbols for testing.
class TickerSymbolFixtures {
  TickerSymbolFixtures._();

  /// Common valid ticker symbols from major US exchanges.
  static const List<String> validTickers = [
    'AAPL', // Apple Inc.
    'GOOGL', // Alphabet Inc. Class A
    'MSFT', // Microsoft Corporation
    'AMZN', // Amazon.com Inc.
    'TSLA', // Tesla Inc.
    'BRK', // Berkshire Hathaway
    'JPM', // JPMorgan Chase & Co.
    'V', // Visa Inc.
    'JNJ', // Johnson & Johnson
    'WMT', // Walmart Inc.
    'PG', // Procter & Gamble Co.
    'UNH', // UnitedHealth Group Inc.
    'DIS', // The Walt Disney Company
    'MA', // Mastercard Inc.
    'NVDA', // NVIDIA Corporation
    'XOM', // Exxon Mobil Corporation
    'HD', // The Home Depot Inc.
    'BAC', // Bank of America Corporation
    'PFE', // Pfizer Inc.
    'ABBV', // AbbVie Inc.
  ];

  /// Single-letter ticker symbols (edge case for minimum length).
  static const List<String> singleLetterTickers = [
    'A', // Agilent Technologies
    'B', // Barnes Group
    'C', // Citigroup
    'F', // Ford Motor Company
    'K', // Kellogg Company
    'L', // Loews Corporation
    'M', // Macy's
    'O', // Realty Income Corporation
    'S', // SentinelOne
    'T', // AT&T Inc.
    'V', // Visa Inc.
    'W', // Wayfair
    'X', // United States Steel Corporation
    'Y', // Alleghany Corporation
    'Z', // Zillow Group
  ];

  /// Maximum length (5 character) ticker symbols.
  static const List<String> maxLengthTickers = [
    'GOOGL', // Alphabet Inc. Class A
    'BRKB', // Berkshire Hathaway Class B
    'CSCO', // Cisco Systems
    'INTC', // Intel Corporation
    'NFLX', // Netflix Inc.
    'PYPL', // PayPal Holdings
    'QCOM', // QUALCOMM Inc.
    'SBUX', // Starbucks Corporation
    'TMUS', // T-Mobile US
    'VRTX', // Vertex Pharmaceuticals
  ];

  /// Test cases for normalization (lowercase to uppercase).
  /// Each tuple contains (input, expected) pairs.
  static const List<(String, String)> normalizationCases = [
    ('aapl', 'AAPL'),
    ('googl', 'GOOGL'),
    ('Msft', 'MSFT'),
    ('TsLa', 'TSLA'),
    ('nflx', 'NFLX'),
  ];

  /// Test cases for whitespace trimming.
  /// Each tuple contains (input, expected) pairs.
  static const List<(String, String)> whitespaceTrimCases = [
    ('  AAPL', 'AAPL'),
    ('MSFT  ', 'MSFT'),
    ('  TSLA  ', 'TSLA'),
    ('\tGOOGL', 'GOOGL'),
    ('NFLX\n', 'NFLX'),
    ('\t\nAMZN\t\n', 'AMZN'),
  ];

  /// Invalid ticker symbols - empty or whitespace only.
  static const List<String> emptyOrWhitespaceTickers = [
    '',
    ' ',
    '  ',
    '\t',
    '\n',
    '   \t\n   ',
  ];

  /// Invalid ticker symbols - too long (more than 5 characters).
  static const List<String> tooLongTickers = [
    'ABCDEF',
    'GOOGLEX',
    'MICROSFT',
    'ALPHABET',
    'BERKSHIRE',
    'JPMORGAN',
  ];

  /// Invalid ticker symbols - containing invalid characters.
  static const List<String> withInvalidCharacters = [
    'ABC.D', // Period
    'ABC-D', // Hyphen
    'ABC_D', // Underscore
    'AB CD', // Space
    'ABC123', // Numbers
    'ABC@', // At symbol
    'ABC#', // Hash
    r'ABC$', // Dollar sign
    'ABC%', // Percent
    'ABC&', // Ampersand
    'ABC*', // Asterisk
    'ABC!', // Exclamation
    'ABC?', // Question mark
    'ABC/', // Slash
    r'ABC\', // Backslash
    'ABC+', // Plus
    'ABC=', // Equals
    'ABC[', // Left bracket
    'ABC]', // Right bracket
    'ABC{', // Left brace
    'ABC}', // Right brace
    'ABC(', // Left parenthesis
    'ABC)', // Right parenthesis
    'ABC<', // Less than
    'ABC>', // Greater than
    'ABC|', // Pipe
    'ABC~', // Tilde
    'ABC^', // Caret
    'ABC`', // Backtick
    "ABC'", // Single quote
    'ABC"', // Double quote
    'ABC,', // Comma
    'ABC;', // Semicolon
    'ABC:', // Colon
    '123', // Only numbers
    '12ABC', // Starting with numbers
    'A1B2C', // Mixed letters and numbers
  ];

  /// Generates a ticker symbol that exceeds the maximum length.
  static String generateTooLongTicker() => 'A' * 6;

  /// Generates a ticker symbol with exactly the maximum allowed length.
  static String generateMaxLengthTicker() => 'A' * 5;
}
