/**
 *223038085 BF MOTSEKI
 *223040545 FB AMATEBELLE
 *223051025 LD MOKHETI
 *223007530 A JARA
 *223020021 B MBINGA
 * 221034577 ML MWENDA
 *222033434 KD TSOLO
 *224020157 KP MOLELEKENG
 *223005893 TV THABISI
 */

/// Question: Module Data - Academic Levels and Modules

class ModuleData {
  /// Academic levels offered
  static const List<String> academicLevels = [
    'First Year',
    'Second Year',
    'Third Year',
  ];

  /// Modules per academic level
  static const Map<String, List<String>> modulesByLevel = {
    'First Year': [
      'Introduction to Programming',
      'Computer Fundamentals',
      'Information Systems 1',
      'Business Communication',
      'Mathematics for IT',
      'Database Fundamentals',
    ],
    'Second Year': [
      'Object Oriented Programming',
      'Data Structures',
      'Systems Analysis and Design',
      'Web Development',
      'Networking Fundamentals',
      'Software Engineering',
    ],
    'Third Year': [
      'Technical Programming III (TPG316C)',
      'Software Development III (SOD316C)',
      'Communication Networks III (CMN316C)',
      'IT Strategy III (ITS316C)',
      'Project Management',
      'Advanced Database Systems',
    ],
  };

  /// Returns modules for a given academic level
  static List<String> getModulesForLevel(String level) {
    return modulesByLevel[level] ?? [];
  }
}