{ Copyright 2016 Mohamed Aziz Knani }

{ Licensed under the Apache License, Version 2.0 (the "License"); }
{ you may not use this file except in compliance with the License. }
{ You may obtain a copy of the License at }

{     http://www.apache.org/licenses/LICENSE-2.0 }

{ Unless required by applicable law or agreed to in writing, software }
{ distributed under the License is distributed on an "AS IS" BASIS, }
{ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{ See the License for the specific language governing permissions and }
{ limitations under the License. }


{$COPERATORS ON}

Uses Crt;
type
   Arr	  = Array [0..1000] of Byte;

var
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
		    sourecode : AnsiString
		    );
type
   P = record
	  endp, startp : Integer;
       end;	       
var
   Stack   : Array [1..100] of Integer;
   Pointer : Integer;
   
   Procedure StackInit;
   begin
      Pointer := 0;
   end;

   Function StackPop: Integer;
   begin
      Pointer -= 1;
      StackPop := Stack[Pointer+1];
   end;

   Procedure StackInsert(element : integer );
   begin
      Pointer += 1;
      Stack[Pointer] := element;
   end;

var
   b	   : Byte;
   ptr	   : Integer;
   currPtr : Integer;

begin
   ptr := 1;
   currPtr := 0;
   StackInit;
   While (ptr<=Length(sourceCode)) do begin
      case sourceCode[ptr] of
	'<' : currPtr -= 1;
	'>' : currPtr += 1;
	'+' : if currPtr>=0 then A[currPtr] += 1;
	'-' : if currPtr>=0 then A[currPtr] -= 1;
	';' : if currPtr>=0 then begin
	   Read(b);
	   A[currPtr] := b;
	end;
	':': if currPtr>=0 then Write(A[currPtr], ' ');
	',': if currPtr>=0 then begin
	   Read(b);
	   A[currPtr] := b;
	end;
	'.' : if currPtr>=0 then begin
	   Write(chr(A[currPtr]));
	end;
      end;
      if sourceCode[ptr]='[' then begin
	 StackInsert(ptr);
      end
      else if sourceCode[ptr] = ']' then begin
	 if (currPtr>=0) and (A[currPtr]<>0) then begin
	    ptr := StackPop;
	    StackInsert(ptr);
	 end
         else
	    StackPop;
      end;
      ptr += 1;
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

   Init(A);
   
   Evaluator(A, sourceCode);
end.
