import 'dart:io';

// Retorna uma List com todos os divisores próprios de n
List<int> getDivisoresProprios(int n) {
  if (n <= 1) return [];
  
  List<int> divisores = [];
  for (int i = 1; i <= n ~/ 2; i++) {
    if (n % i == 0) {
      divisores.add(i);
    }
  }
  return divisores;
}

// Calcula a soma dos elementos de uma lista
int somarLista(List<int> lista) {
  return lista.fold(0, (acc, elem) => acc + elem);
}

void main() {
  final entrada = stdin.readLineSync() ?? '';
  final partes = entrada.trim().split(RegExp(r'\s+'));

  if (partes.length < 2) {
    return print('Por favor forneça dois números inteiros positivos.');
  }

  int? a = int.tryParse(partes[0]);
  int? b = int.tryParse(partes[1]);

  if (a == null || b == null) {
    return print('Por favor forneça dois números inteiros positivos.');
  }
  if (a != a.toInt() || b != b.toInt()){
    return print('Por favor forneça dois números inteiros positivos.');
  }
  if (a < 0 || b < 0){
    return print('Por favor forneça dois números inteiros positivos.');
  }
  if (a > b){
    return print('O primeiro número deve ser menor ou igual ao segundo.');
  }
  // Garante que o intervalo seja percorrido do menor para o maior
  int inicio = a;
  int fim = b;

  // Listas para armazenar os resultados encontrados
  List<int> numerosPerfeitos = [];
  Map<int, List<int>> fatoresPerfeitos = {};

  int? melhorAbundante;
  int maiorSomaAbundante = -1;
  List<int> fatoresMelhorAbundante = [];

  for (int num = inicio; num <= fim; num++) {
    List<int> divisores = getDivisoresProprios(num);
    int soma = somarLista(divisores);

    // Número Perfeito: soma dos divisores == próprio número
    if (soma == num && num > 0) {
      numerosPerfeitos.add(num);
      fatoresPerfeitos[num] = divisores;
    }

    // Número Abundante: soma dos divisores > próprio número
    if (soma > num && num > 0) {
      if (soma > maiorSomaAbundante) {
        maiorSomaAbundante = soma;
        melhorAbundante = num;
        fatoresMelhorAbundante = divisores;
      }
    }
  }

  if (numerosPerfeitos.isEmpty) {
    print('Nenhum número perfeito encontrado na faixa entre $inicio e $fim.');
  } else {
    for (final num in numerosPerfeitos) {
      print('$num é um número perfeito.');
      print('Fatores: ${fatoresPerfeitos[num]}');
    }
  }

  if (melhorAbundante == null) {
    print('Nenhum número abundante encontrado na faixa entre $inicio e $fim.');
  } else {
    print('Maior número abundante: $melhorAbundante');
    print('Fatores: $fatoresMelhorAbundante');
    print('Soma dos fatores: $maiorSomaAbundante');
  }
}