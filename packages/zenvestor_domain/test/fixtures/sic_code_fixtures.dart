/// Valid SIC codes for testing.
class SicCodeFixtures {
  SicCodeFixtures._();

  /// Common valid SIC codes from various industries.
  static const List<String> validCodes = [
    '7372', // Prepackaged Software
    '5812', // Eating Places
    '2731', // Book Publishing
    '3571', // Electronic Computers
    '4812', // Radiotelephone Communications
    '6021', // National Commercial Banks
    '7011', // Hotels and Motels
    '8062', // General Medical and Surgical Hospitals
    '9999', // Nonclassifiable Establishments
    '1311', // Crude Petroleum and Natural Gas
    '2011', // Meat Packing Plants
    '3011', // Tires and Inner Tubes
    '4011', // Railroads, Line-Haul Operating
    '5011', // Motor Vehicles and Motor Vehicle Parts and Supplies
    '6011', // Federal Reserve Banks
    '8011', // Offices and Clinics of Doctors of Medicine
    '9011', // Executive Offices
  ];

  /// SIC codes with leading zeros.
  static const List<String> codesWithLeadingZeros = [
    '0111', // Wheat
    '0112', // Rice
    '0115', // Corn
    '0119', // Cash Grains, Not Elsewhere Classified
    '0131', // Cotton
    '0134', // Irish Potatoes
    '0161', // Vegetables and Melons
    '0171', // Berry Crops
    '0181', // Ornamental Floriculture and Nursery Products
    '0211', // Beef Cattle Feedlots
    '0751', // Livestock Services, Except Veterinary
    '0811', // Timber Tracts
  ];

  /// Minimum valid SIC code.
  static const String minimumValidCode = '0100';

  /// Maximum valid SIC code.
  static const String maximumValidCode = '9999';

  /// Test cases for whitespace trimming.
  /// Each tuple contains (input, expected) pairs.
  static const List<(String, String)> whitespaceTrimCases = [
    ('  7372', '7372'),
    ('5812  ', '5812'),
    ('  2731  ', '2731'),
    ('\t3571', '3571'),
    ('4812\n', '4812'),
    ('\t\n0111\t\n', '0111'),
  ];

  /// Test cases for normalization (padding with leading zeros).
  /// Each tuple contains (input, expected) pairs.
  static const List<(String, String)> normalizationCases = [
    ('100', '0100'), // 3 digits to 4
    ('200', '0200'), // 3 digits to 4
    ('999', '0999'), // 3 digits to 4
    ('1', '0001'), // 1 digit to 4
    ('50', '0050'), // 2 digits to 4
    ('99', '0099'), // 2 digits to 4
    ('7', '0007'), // 1 digit to 4
    ('1000', '1000'), // Already 4 digits
    ('7372', '7372'), // Already 4 digits
    ('  100  ', '0100'), // With whitespace
    ('\t7\n', '0007'), // With whitespace
  ];

  /// Invalid SIC codes - empty or whitespace only.
  static const List<String> emptyOrWhitespaceCodes = [
    '',
    ' ',
    '  ',
    '\t',
    '\n',
    '   \t\n   ',
  ];

  /// Invalid SIC codes - wrong length.
  static const List<String> invalidLengthCodes = [
    '12345', // Too long
    '123456', // Too long
    '73721', // Too long
    '99999', // Too long
    '100000', // Too long
  ];

  /// Invalid SIC codes - containing non-numeric characters.
  static const List<String> nonNumericCodes = [
    'ABCD', // All letters
    '73A2', // Letter in middle
    'A372', // Letter at start
    '737B', // Letter at end
    '73-2', // Hyphen
    '73.2', // Period
    '73 2', // Space
    '73_2', // Underscore
    '73@2', // Special character
    '737#', // Hash
    r'73$2', // Dollar sign
    '73%2', // Percent
    '73&2', // Ampersand
    '73*2', // Asterisk
    '73!2', // Exclamation
    '73?2', // Question mark
    '73/2', // Slash
    r'73\2', // Backslash
    '73+2', // Plus
    '73=2', // Equals
  ];

  /// Invalid SIC codes - outside valid range.
  static const List<String> outOfRangeCodes = [
    '0000', // Below minimum
    '0001', // Below minimum
    '0010', // Below minimum
    '0099', // Below minimum
    '0050', // Below minimum
    '0075', // Below minimum
    '1', // Normalizes to 0001 - below minimum
    '12', // Normalizes to 0012 - below minimum
    '99', // Normalizes to 0099 - below minimum
  ];

  /// Generates a SIC code with the specified number of digits.
  static String generateCodeWithLength(int length) => '7' * length;

  /// Generates a valid SIC code.
  static String generateValidCode() => '7372';
}
