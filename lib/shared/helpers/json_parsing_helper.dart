

/// Helper utilitário para normalizar/parsing de dados vindos de JSON/Firestore.
/// A ideia aqui é centralizar conversões e validações para evitar:
/// - `as String` explodindo com TypeError
/// - null inesperado quebrando o app
/// - dados sujos ("  ", "true", "1", Timestamp vs DateTime)
class JsonParsingHelper {
  /// Construtor privado: impede instanciar a classe.
  /// Você usa apenas os métodos estáticos: JsonParsingHelper.requiredString(...)
  JsonParsingHelper._();

  /// Tenta extrair uma String opcional de um valor dinâmico.
  /// Regras:
  /// - null -> null
  /// - String -> trim + se vazio vira null
  /// - outros tipos -> toString + trim + se vazio vira null
  ///
  /// Útil para campos opcionais do Firestore (ou campos que vêm sujos).
  static String? optionalString(dynamic key) {
    if (key == null) {
      return null;
    }

    // Se já for String, só limpa espaços e valida vazio.
    if (key is String) {
      final trimed = key.trim();
      return trimed.isEmpty ? null : trimed;
    }

    // Se não for String, converte e aplica as mesmas regras.
    final parserd = key.toString().trim();
    return parserd.isEmpty ? null : parserd;
  }

  /// Retorna String, mas nunca null.
  /// Se não tiver valor válido, devolve '' (string vazia).
  ///
  /// Bom quando o UI precisa de String sempre (ex: Text widget),
  /// mas cuidado: pode esconder erro de dado obrigatório se usado errado.
  static String stringOrEmtpy(dynamic key) {
    return optionalString(key) ?? '';
  }

  /// Obtém uma String obrigatória de um json, validando:
  /// - trim
  /// - vazio
  /// - null
  ///
  /// Se inválido, lança FormatException (melhor para "dado mal formatado").
  static String requiredString(Map<String, dynamic> json, String key) {
    final value = optionalString(json[key]);
    if (value == null) {
      throw FormatException('O campo "$key" é obrigatório');
    }
    return value;
  }

  /// Obtém uma data obrigatória em formato DateTime.
  /// Aceita múltiplos formatos comuns em apps reais:
  /// - Timestamp (Firestore) -> toDate()
  /// - DateTime já pronto -> retorna direto
  /// - int -> epoch milliseconds
  /// - String -> DateTime.tryParse (ISO 8601)
  ///
  /// Se não conseguir converter, lança FormatException.
  static DateTime requiredDate(dynamic rawDate, {String key = 'date'}) {
    
    if (rawDate is DateTime) {
      return rawDate;
    }
    if (rawDate is int) {
      return DateTime.fromMillisecondsSinceEpoch(rawDate);
    }
    if (rawDate is String) {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        return parsed;
      }
    }
    throw FormatException('O campo "$key" deve ser uma data válida');
  }

  /// Tenta extrair int opcional.
  /// - null -> null
  /// - int -> retorna
  /// - outros -> tenta int.tryParse(toString())
  ///
  /// Atenção: se vier double "10.0" isso vira null (por causa do tryParse).
  static int? optionalInt(dynamic key) {
    if (key == null) {
      return null;
    }
    if (key is int) {
      return key;
    }
    return int.tryParse(key.toString());
  }

  /// Extrai int obrigatório de um json.
  /// Se falhar, lança Exception (genérico).
  ///
  /// Sugestão futura: usar FormatException aqui também pra padronizar.
  static int requiredInt(Map<String, dynamic> json, String key) {
    final value = optionalInt(json[key]);
    if (value == null) {
      throw FormatException('O campo "$key" é obrigatório');
    }
    return value;
  }

  /// Tenta extrair bool opcional.
  /// Aceita:
  /// - bool nativo
  /// - String "true"/"false"
  /// - String "1"/"0"
  ///
  /// Se não reconhecer, retorna null (não explode).
  static bool? optionalBool(dynamic key) {
    if (key == null) {
      return null;
    }
    if (key is bool) {
      return key;
    }
    if (key is String) {
      final s = key.toLowerCase().trim();
      if (s == 'true' || s == '1' || s == 'sim') {
        return true;
      }
      if (s == 'false' || s == '0' || s == 'não') {
        return false;
      }
    }
    return null;
  }

  /// Tenta extrair double opcional.
  /// - null -> null
  /// - double -> retorna
  /// - outros -> tenta double.tryParse(toString())
  ///
  /// Atenção: se vier int (ex: 10), hoje vai cair no tryParse e virar 10.0?
  /// (porque "10" parseia). Mas se vier numérico com vírgula "10,5" -> null.
  static double? optionalDouble(dynamic key) {
    if (key == null) {
      return null;
    }
    if (key is double) {
      return key;
    }
    if (key is num) {
      return key.toDouble();
    }
    final number = optionalString(key);
    if (number == null) {
      return null;
    }
    final normal = number.replaceAll(',', '.');

    return double.tryParse(normal);
  }

  /// Extrai double obrigatório de um json.
  /// Se inválido, lança FormatException.
  static double requiredDouble(Map<String, dynamic> json, String key) {
    final value = optionalDouble(json[key]);
    if (value == null) {
      throw FormatException(
        'O campo "$key" é obrigatório e deve ser um número valido',
      );
    }
    return value;
  }

  /// Extrai bool obrigatório de um json.
  /// Se inválido, lança Exception (genérico).
  ///
  /// Sugestão futura: usar FormatException aqui também.
  static bool requiredBool(Map<String, dynamic> json, String key) {
    final value = optionalBool(json[key]);
    if (value == null) {
      throw FormatException('O campo "$key" é obrigatório');
    }
    return value;
  }

  /*/// Converte um campo para List<String> com fallback seguro.
  /// Regras:
  /// - null -> []
  /// - List<String> -> retorna direto
  /// - List<dynamic> -> converte cada item pra string
  /// - qualquer outra coisa -> []
  ///
  Ideal pra Firestore, onde listas frequentemente vêm como List<dynamic>.*/
  static List<String> stringListOrEmpty(dynamic key) {
    if (key == null) {
      return [];
    }
    if (key is List<String>) {
      return key;
    }
    if (key is List<dynamic>) {
      return key.map((i) => i.toString()).toList();
    }
    return [];
  }
}
