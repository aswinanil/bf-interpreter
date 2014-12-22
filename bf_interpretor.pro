:- use_module(library(clpfd)).

/**************************************SAMPLE INPUT******************************************/
%Hello World
% interpret:- interpret("+++++ +++++ [ > +++++ ++ > +++++ +++++ > +++ > +
% <<<< - ] > ++ . > + . +++++ ++ . . +++ . > ++ . << +++++ +++++ +++++ .
% > . +++ . ----- - . ----- --- . > + . > ." , "", "").

%Add 2 numbers, 3 & 4 read from std input,
interpret:- interpret(",>,[<+>-]<.", "99", "").
/********************************************************************************************/


%Interpretor for BF
%Takes as arguments: a BF Program, standard input, standard output, integer array, instruction pointer, data pointer
interpret(P,I,O):- changeIntInput(I,[],NewI), execute(P,NewI,O,[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],0,0).

execute(P,_,O,_,_,IP):-
	length(P,LEN), IP>=LEN, changeIntOutput(O,[],NewO), atom_chars(ASC,NewO), writeln(ASC),!.
execute(P,I,O,IA,DP,IP):-
	length(P,LEN), IP\=LEN,
	nth0(IP,P,E), execute(E,P,I,O,IA,DP,IP,NewI,NewO,NewIA,NewDP,NewIP), execute(P,NewI,NewO,NewIA,NewDP,NewIP).

%BF commands
execute(32,_,I,O,IA,DP,IP,NewI,NewO,NewIA,NewDP,NewIP):-
	NewIP#=IP+1,
	NewI=I, NewO=O, NewIA=IA, NewDP=DP.
execute(62,_,I,O,IA,DP,IP,NewI,NewO,NewIA,NewDP,NewIP):-
	NewDP#=DP+1,
	NewI=I, NewO=O, NewIA=IA, NewIP#=IP+1.
execute(60,_,I,O,IA,DP,IP,NewI,NewO,NewIA,NewDP,NewIP):-
	NewDP#=DP-1,
	NewI=I, NewO=O, NewIA=IA, NewIP#=IP+1.
execute(43,_,I,O,IA,DP,IP,NewI,NewO,NewIA,NewDP,NewIP):-
	nth0(DP,IA,E), NewE#=E+1, nth0(DP,TempIA,NewE,IA), TempDP#=DP+1, delEleAt(TempDP,TempIA,NewIA),
	NewI=I, NewDP=DP, NewO=O,NewIP#=IP+1.
execute(45,_,I,O,IA,DP,IP,NewI,NewO,NewIA,NewDP,NewIP):-
	nth0(DP,IA,E), NewE#=E-1, nth0(DP,TempIA,NewE,IA), TempDP#=DP+1, delEleAt(TempDP,TempIA,NewIA),
	NewI=I, NewDP=DP, NewO=O, NewIP#=IP+1.
execute(46,_,I,O,IA,DP,IP,NewI,NewO,NewIA,NewDP,NewIP):-
	nth0(DP,IA,E), append(O,[E],NewO),
	NewI=I, NewDP=DP, NewIA=IA, NewIP#=IP+1.
execute(44,_,I,O,IA,DP,IP,NewI,NewO,NewIA,NewDP,NewIP):-
	I = [H|T], nth0(DP,TempIA,H,IA), TempDP#=DP+1, delEleAt(TempDP,TempIA,NewIA), NewI=T,
	NewO=O, NewDP=DP, NewIP#=IP+1.
execute(91,P,I,O,IA,DP,IP,NewI,NewO,NewIA,NewDP,NewIP):-
	nth0(DP,IA,E), jump91(P,IP,NewIP,E),
	NewI=I, NewO=O, NewIA=IA, NewDP=DP.
execute(93,P,I,O,IA,DP,IP,NewI,NewO,NewIA,NewDP,NewIP):-
	nth0(DP,IA,E), jump93(P,IP,NewIP,E),
	NewI=I, NewO=O, NewIA=IA, NewDP=DP.

%4 rules below used by command '['
hitBracket91(93,_,IP,NewIP):-
	NewIP#=IP+1.
hitBracket91(_,P,IP,NewIP):-
	TempIP#=IP+1,
	nth0(TempIP,P,E),
	hitBracket91(E,P,TempIP,NewIP).
jump91(P,IP,NewIP,0):-
	TempIP#=IP+1,
	nth0(TempIP,P,E),
	hitBracket91(E,P,TempIP,NewIP).
jump91(_,IP,NewIP,_):-
	NewIP#=IP+1.

%4 rules below used by command ']'
hitBracket93(91,_,IP,NewIP):-
	NewIP#=IP+1.
hitBracket93(_,P,IP,NewIP):-
	TempIP#=IP-1,
	nth0(TempIP,P,E),
	hitBracket93(E,P,TempIP,NewIP).
jump93(_,IP,NewIP,0):-
	NewIP#=IP+1.
jump93(P,IP,NewIP,_):-
	TempIP#=IP-1,
	nth0(TempIP,P,E),
	hitBracket93(E,P,TempIP,NewIP).

%Deletes an element at a specified index of a list
%Takes as arguments: an index, an integer array, new Ineger Array to be returned
delEleAt(Ind,IA,NewIA):-
	copyBefore(Ind,IA,[],BeforeInd, AfterInd),
	append(BeforeInd, AfterInd, NewIA).
copyBefore(0,IA,TempIA,BeforeInd, After):-
	BeforeInd=TempIA,
	IA=[_|After].
copyBefore(Ind,IA,TempIA,BeforeInd, After):-
	IA=[H|T],
	append(TempIA,[H],Temp2IA),
	NewInd#=Ind-1,
	copyBefore(NewInd,T,Temp2IA,BeforeInd, After).

%3 rules below convert ASC11 codes for integers to the integer itself
changeIntInput([],BuffI,NewI):-
	NewI=BuffI.
changeIntInput(I,BuffI,NewI):-
	I=[H|T],
	47<H, H<58,
	getNum(INT,H),
	append(BuffI,[INT],NewBuffI),
	changeIntInput(T,NewBuffI,NewI).
changeIntInput(I,BuffI,NewI):-
	I=[H|T],
	append(BuffI,[H],NewBuffI),
	changeIntInput(T,NewBuffI,NewI).

%3 rules below convert integers to ASC11 code
changeIntOutput([],BuffO,NewO):-
	NewO=BuffO.
changeIntOutput(O,BuffO,NewO):-
	O=[H|T],
	0<H, H<9,
	getNum(H,ASC),
	append(BuffO,[ASC],NewBuffO),
	changeIntOutput(T,NewBuffO,NewO).
changeIntOutput(O,BuffO,NewO):-
	O=[H|T],
	append(BuffO,[H],NewBuffO),
	changeIntOutput(T,NewBuffO,NewO).

%Used for integer-ASC11 conversion
getNum(INT,48):- INT=0.
getNum(INT,49):- INT=1.
getNum(INT,50):- INT=2.
getNum(INT,51):- INT=3.
getNum(INT,52):- INT=4.
getNum(INT,53):- INT=5.
getNum(INT,54):- INT=6.
getNum(INT,55):- INT=7.
getNum(INT,56):- INT=8.
getNum(INT,57):- INT=9.
