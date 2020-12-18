bison mathy.y

bison -d mathy.y -o mathy.cpp

flex -o mathy_lex.cpp mathy.l

g++ -o mathy_exe mathy.cpp mathy_lex.cpp