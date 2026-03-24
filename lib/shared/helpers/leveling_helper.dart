import 'dart:math';

class LevelingHelper {
  static const int maxLevel = 20;
  static const int targetTotalXp = 50000;

  /// Quanto XP é necessário para passar do nível atual para o próximo.
  /// A dificuldade aumenta de forma quadrática suave.
  static int xpRequiredForNextLevel(int currentLevel) {
    if (currentLevel >= maxLevel) return 0;
    // Fórmula: 140n + 10n²
    return (140 * currentLevel) + (10 * pow(currentLevel, 2)).toInt();
  }

  /// XP Total acumulado necessário para chegar em um determinado nível.
  static int totalXpToReachLevel(int level) {
    if (level <= 1) return 0;
    int total = 0;
    for (int i = 1; i < level; i++) {
      total += xpRequiredForNextLevel(i);
    }
    return total;
  }

  /// Retorna o nível atual baseado no XP total acumulado do usuário.
  static int getLevelFromXp(int totalXp) {
    int level = 1;
    // Percorre os níveis verificando se o XP total já atingiu o patamar do próximo
    while (level < maxLevel && totalXp >= totalXpToReachLevel(level + 1)) {
      level++;
    }
    return level;
  }
}
