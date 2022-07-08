class Constants {
  static const String storageBucketBaseUrl = 'gs://zeeu-f8a0e.appspot.com';
  static const String dummyProfileImageUrl =
      'gs://zeeu-f8a0e.appspot.com/dummy/blank.webp';
  static const List<String> specialties = [
    'General',
    'Allergist',
    'Cardiologist',
    'Dermatologist',
    'Endocrinologist',
    'Family Physician',
    'Gastroenterologist',
    'Hematologist',
    'Nephrologist'
  ];
  static const Map<String, String> specialtiesImg = {
    'General': 'assets/specialty/general.png',
    'Allergist': 'assets/specialty/allergist.png',
    'Cardiologist': 'assets/specialty/heart.png',
    'Dermatologist': 'assets/specialty/dermato.png',
    'Endocrinologist': 'assets/specialty/endo.png',
    'Family Physician': 'assets/specialty/physician.png',
    'Gastroenterologist': 'assets/specialty/stomach.png',
    'Hematologist': 'assets/specialty/hemato.png',
    'Nephrologist': 'assets/specialty/nephrologist.png'
  };
  static const apiUri = 'ws://10.0.2.2:8080';
}
