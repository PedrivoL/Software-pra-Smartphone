import 'dart:io'; 
bool primo(int a) {
  if (a <= 1) return false;
  if (a == 2) return true;
  if (a % 2 == 0) return false;
  for (int i = 3; i * i <= a; i += 2) {
    if (a % i == 0) return false;
  }
  return true;
}
void main() {
  stdout.write('');
  String? entrada = stdin.readLineSync();
  if (entrada == null || entrada.trim().isEmpty) {
    print('Entrada vazia!');
    return;
  }
    num? numero = num.tryParse(entrada.trim());
     if (entrada.contains(',')){
        print('Formato numérico inválido!');
    }else if (numero == null) {
      print('Não é um número!');
    } else if (numero is double) {
      print('Não é inteiro!');
    } else if (numero is int && numero>0) {
      if (primo(numero)) {
        print('É primo!');
      } else {
        print('Não é primo!');
      }
    } else if (numero is int && numero <0){
        print('Número negativo!');
    } 
}