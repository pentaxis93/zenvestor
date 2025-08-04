/// Valid grades for testing.
class GradeFixtures {
  GradeFixtures._();

  /// All valid grade values.
  static const List<String> validGrades = [
    'A', // Excellent
    'B', // Good
    'C', // Average
    'D', // Below Average
    'F', // Failing
  ];

  /// Test cases for normalization (lowercase to uppercase).
  /// Each tuple contains (input, expected) pairs.
  static const List<(String, String)> normalizationCases = [
    ('a', 'A'),
    ('b', 'B'),
    ('c', 'C'),
    ('d', 'D'),
    ('f', 'F'),
  ];

  /// Test cases for whitespace trimming.
  /// Each tuple contains (input, expected) pairs.
  static const List<(String, String)> whitespaceTrimCases = [
    ('  A', 'A'),
    ('B  ', 'B'),
    ('  C  ', 'C'),
    ('\tD', 'D'),
    ('F\n', 'F'),
    ('\t\nA\t\n', 'A'),
  ];

  /// Invalid grades - empty or whitespace only.
  static const List<String> emptyOrWhitespaceGrades = [
    '',
    ' ',
    '  ',
    '\t',
    '\n',
    '   \t\n   ',
  ];

  /// Invalid grades - not in the allowed set.
  static const List<String> invalidGrades = [
    'E', // Common misconception
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  /// Invalid grades - grade modifiers.
  static const List<String> gradeModifiers = [
    'A+',
    'A-',
    'B+',
    'B-',
    'C+',
    'C-',
    'D+',
    'D-',
    'F+',
    'F-',
  ];

  /// Invalid grades - multiple characters.
  static const List<String> multipleCharacterGrades = [
    'AA',
    'AB',
    'ABC',
    'Pass',
    'Fail',
    'Good',
    'Excellent',
  ];

  /// Invalid grades - containing invalid characters.
  static const List<String> withInvalidCharacters = [
    '1', // Number
    '2',
    '3',
    '4',
    '5',
    'A1', // Letter and number
    '1A',
    'A.', // Period
    'A-', // Already covered in modifiers but included for completeness
    'A_', // Underscore
    'A ', // Space after
    ' A', // Already covered but included for completeness
    'A@', // At symbol
    'A#', // Hash
    r'A$', // Dollar sign
    'A%', // Percent
    'A&', // Ampersand
    'A*', // Asterisk
    'A!', // Exclamation
    'A?', // Question mark
    'A/', // Slash
    r'A\', // Backslash
    'A+', // Already covered in modifiers
    'A=', // Equals
    'A[', // Left bracket
    'A]', // Right bracket
    'A{', // Left brace
    'A}', // Right brace
    'A(', // Left parenthesis
    'A)', // Right parenthesis
    'A<', // Less than
    'A>', // Greater than
    'A|', // Pipe
    'A~', // Tilde
    'A^', // Caret
    'A`', // Backtick
    "A'", // Single quote
    'A"', // Double quote
    'A,', // Comma
    'A;', // Semicolon
    'A:', // Colon
  ];
}
