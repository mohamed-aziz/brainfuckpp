// Simple brainfuck++ interpreter

{$COPERATORS ON}


Uses Crt;
type
   Arr	  = Array [0..1000] of Byte;

var
   T		    : Arr;
   filename	    : String;
   sourcefile	    : Text;
   sourceCode, line : AnsiString;
   A		    : Arr;

Function codeCLeaner(code: AnsiString): AnsiString;
var
   i	  : Integer;
   Res : AnsiString;
begin
   Res := '';
   for i:=1 to Length(code) do begin
      if code[i] in [';', ':', '<', '>', '+', '-', '[', ']', ',', '.'] then
	 Res += code[i];
   end;
   
   codeCLeaner := Res;
end;

Procedure Init(var A :Arr );
var
   i : Integer;
begin
   // Init all cell segments to zero.
   for i:=Low(A) to High(A) do begin
      A[i] := 0;
   end;
end;

Procedure Evaluator( A : Arr; // The cell segments array
		    sourecode : AnsiString; 
		    ptr, // current source code pointer
		    matchingPar: Integer; // the matching pair index
                    currPtr:	    Integer // current Array index
		    );
var
   b : Byte;
begin
   if ptr>=0 then begin
      Writeln(sourceCode[ptr], ' ', matchingPar, ' ', currPtr, ' ', A[currPtr]);
      // if the source code is done then Halt
      if ptr>length(sourceCode) then
	 Halt(0);
      // if there is a loop
      if sourcecode[ptr] = '[' then begin
	 matchingPar := ptr;
      end;
 
      if sourceCode[ptr]='[' then begin
	 Evaluator(A, sourceCode, ptr+1, matchingPar , currPtr);
      end;

      // if there is loop end check if cell at pointer is zero or not?
      if sourceCode[ptr]=']' then begin
	 if A[currPtr]<>0 then
	    Evaluator(A, sourceCode, matchingPar, -1,currPtr
		      );
	 
      end;

      case sourceCode[ptr] of
	'<' : currPtr -= 1;
	'>' : currPtr += 1;
	'+' : A[currPtr] += 1;
	'-' : A[currPtr] -= 1;
	';' : begin
	   Read(b);
	   A[currPtr] := b;
	end;
	':': Write(A[currPtr], ' ');
	',': begin
	   Read(b);
	   A[currPtr] := b;
	end;
	'.' : begin
	   Write(chr(A[currPtr]) ,' ');
	end;
      end;
      Evaluator(
		A, sourceCode, ptr+1, matchingPar, currPtr
		);
      
   end;
end;

begin
   if ParamCount>0 then begin
      filename := ParamStr(1);
   end
   else begin
      Writeln('USAGE: ', ParamStr(0), ' filename');
      Halt(1);
   end;

   Assign(sourcefile, filename);
   {$I-}
   Reset(sourcefile);
   {$I+}
   if IOResult <> 0 then begin
      Writeln('Error openning ', filename);
      Halt(2);
   end;
   sourceCode := '';
   While not(EOF(sourcefile)) do begin
      Readln(sourcefile, line);
      sourceCode += line;
   end;
   sourceCode := codeCLeaner(sourcecode);
   
   Writeln(sourcecode);

   Init(A);
   
   Evaluator(A, sourceCode, 1, -1, 0);
end.
