x86ChessEngine  
=====  

A simple chess engine AI wrritten in LINUX NASM64 assembly

![alt tag](https://raw.githubusercontent.com/CrSeth/x86ChessEngine/master/hvc.gif?token=AFCwpfAAaVU2gQBT9gk98c31-9Oc9fJWks5Vd8GWwA%3D%3D)

Features:
 * AI vs AI  
 * Human vs AI  
 * GTK GUI written in C  
    
What doesn't Work:
 * castling
 * pawn passant
  
What To Do:
 * Move from NegaMax to Alpha-Beta AI  
 * Decrease memory usage when moving/undoing moves 
 * Add GUI move verification, and user msg's
 * Add opening book
  
Running  
====
Requires: NASM, GCC, gtk2-dev  
`make && ./Chess -h -c`  
Human = '-h' flag & Computer = '-c'  
you can do '-c -c' or '-c -h', etc
 

----
Computer Architecture Project  
@Instituto Tecnológico de Costa Rica

  
