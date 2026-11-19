# Trabalho 2 – Termo em Haskell

Arthur Cunha de Paula – 23.1.8008 – CSI114 Linguagens de Programação

Adivinhe a palavra secreta de 5 letras em até 6 tentativas. A cada palpite, cada letra aparece em:

- **verde**: letra certa na posição certa;
- **amarelo**: a letra existe, mas em outra posição;
- **cinza**: a letra não existe na palavra.

## Como executar

Na pasta do trabalho (com `aceitas.txt` e `secretas.txt`), rode:

```
ghci Termo.hs
ghci> main
```

## Arquivos

- `Termo.hs`: código do jogo.
- `aceitas.txt`: palavras aceitas como palpite.
- `secretas.txt`: palavras que podem ser sorteadas.
