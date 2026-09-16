unit LTOArchOps;
{$mode objfpc}
interface
function FetchAdd(P: PLongInt): LongInt;
implementation
function FetchAdd(P: PLongInt): LongInt; assembler; nostackframe;
asm
  mov w1, #1
  ldadd w1, w0, [x0]
end;
end.
