import 'dart:math';
import 'package:flutter/material.dart';

class JogoDaVelha extends StatefulWidget {
  const JogoDaVelha({super.key});

  @override
  State<JogoDaVelha> createState() => _JogoDaVelhaState();
}

class _JogoDaVelhaState extends State<JogoDaVelha> {
  List<String> _tabuleiro = List.filled(9, '');
  String _jogador = 'X';
  bool _contraMaquina = false;
  final Random _randomico = Random();
  bool _pensando = false;
  bool _dificuldadeFacil = true;

  void _iniciarJogo() {
    setState(() {
      _tabuleiro = List.filled(9, '');
      _jogador = 'X';
      _pensando = false;
    });
  }

  void _trocaJogador() {
    _jogador = _jogador == 'X' ? 'O' : 'X';
  }

  void _mostreDialogoVencedor(String vencedor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(vencedor == 'Empate' ? 'Empate!' : 'Vencedor: $vencedor'),
          actions: [
            ElevatedButton(
              child: const Text('Reiniciar Jogo'),
              onPressed: () {
                Navigator.of(context).pop();
                _iniciarJogo();
              },
            ),
          ],
        );
      },
    );
  }

  String? _verificaVencedor() {
    const posicoesVencedoras = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (var posicoes in posicoesVencedoras) {
      if (_tabuleiro[posicoes[0]] == _tabuleiro[posicoes[1]] &&
          _tabuleiro[posicoes[0]] == _tabuleiro[posicoes[2]] &&
          _tabuleiro[posicoes[0]] != '') {
        return _tabuleiro[posicoes[0]];
      }
    }

    if (!_tabuleiro.contains('')) {
      return 'Empate';
    }

    return null;
  }

  void _jogadaComputador() {
    setState(() => _pensando = true);
    Future.delayed(const Duration(seconds: 1), () {
      int movimento;
      if (_dificuldadeFacil) {
        do {
          movimento = _randomico.nextInt(9);
        } while (_tabuleiro[movimento] != '');
      } else {
        movimento = _jogadaDificil();
      }

      setState(() {
        _tabuleiro[movimento] = 'O';
        String? vencedor = _verificaVencedor();
        if (vencedor != null) {
          _mostreDialogoVencedor(vencedor);
        } else {
          _trocaJogador();
        }
        _pensando = false;
      });
    });
  }

  int _jogadaDificil() {
    for (int i = 0; i < 9; i++) {
      if (_tabuleiro[i] == '') {
        _tabuleiro[i] = 'O';
        if (_verificaVencedor() == 'O') {
          return i;
        }
        _tabuleiro[i] = '';
      }
    }

    for (int i = 0; i < 9; i++) {
      if (_tabuleiro[i] == '') {
        _tabuleiro[i] = 'X';
        if (_verificaVencedor() == 'X') {
          _tabuleiro[i] = '';
          return i;
        }
        _tabuleiro[i] = '';
      }
    }

    int movimento;
    do {
      movimento = _randomico.nextInt(9);
    } while (_tabuleiro[movimento] != '');
    return movimento;
  }

  void _jogada(int index) {
    if (_tabuleiro[index] == '' && !_pensando) {
      setState(() {
        _tabuleiro[index] = _jogador;
        String? vencedor = _verificaVencedor();
        if (vencedor != null) {
          _mostreDialogoVencedor(vencedor);
        } else {
          _trocaJogador();
          if (_contraMaquina && _jogador == 'O') {
            _jogadaComputador();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double altura = MediaQuery.of(context).size.height * 0.5;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch(
              value: _contraMaquina,
              onChanged: (value) {
                setState(() {
                  _contraMaquina = value;
                  _iniciarJogo();
                });
              },
            ),
            Text(_contraMaquina ? 'Computador' : 'Humano'),
          ],
        ),
        if (_contraMaquina)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Fácil'),
              Radio(
                value: true,
                groupValue: _dificuldadeFacil,
                onChanged: (value) => setState(() => _dificuldadeFacil = true),
              ),
              const Text('Difícil'),
              Radio(
                value: false,
                groupValue: _dificuldadeFacil,
                onChanged: (value) => setState(() => _dificuldadeFacil = false),
              ),
            ],
          ),
        SizedBox(
          width: altura,
          height: altura,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _jogada(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      _tabuleiro[index],
                      style: const TextStyle(fontSize: 40.0),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: _iniciarJogo,
          child: const Text('Reiniciar Jogo'),
        ),
      ],
    );
  }
}
