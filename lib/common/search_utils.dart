import 'package:string_similarity/string_similarity.dart';

/// Normalize text by removing spaces, symbols, emojis, etc.
String normalize(String text) {
  return text.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'), ''); // remove everything except letters + numbers
}

/// Tokenizer → breaks text & creates multiple matchable combinations
List<String> tokenize(String text) {
  final cleaned =
      text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ''); // keep spaces

  final tokens =
      cleaned.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

  final variants = <String>{
    cleaned.replaceAll(" ", ""), // full merged version
    cleaned, // spaced version
    ...tokens, // separate words
  };

  // Generate combinations: bed room light → bedroom, roomlight, bedroomlight
  for (int i = 0; i < tokens.length; i++) {
    for (int j = i; j < tokens.length; j++) {
      variants.add(tokens.sublist(i, j + 1).join());
    }
  }

  return variants.toList();
}

/// Fuzzy comparison using string_similarity
bool fuzzyMatch(String a, String b) {
  double score = a.similarityTo(b);
  return score > 0.35; // adjustable threshold
}

/// Smart fuzzy + token search
bool smartMatch(String source, String query) {
  final sourceTokens = tokenize(source);
  final q = normalize(query);

  for (final token in sourceTokens) {
    final nToken = normalize(token);

    if (nToken.contains(q)) return true; // direct contains
    if (fuzzyMatch(nToken, q)) return true; // fuzzy
  }
  return false;
}

/// Generic list filter for any object type
List<T> smartFilter<T>(
  List<T> list,
  String query,
  List<String Function(T item)> fields,
) {
  if (query.trim().isEmpty) return list;

  return list.where((item) {
    for (final fieldGetter in fields) {
      final value = fieldGetter(item);
      if (smartMatch(value, query)) return true;
    }
    return false;
  }).toList();
}
