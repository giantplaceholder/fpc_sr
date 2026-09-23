{ %CPU=x86_64 }
{ Compile with LLVM, -Aclang-llvm -Clflto -XLL on Linux. References from
  assembler to assembler routines and external aliases must survive LTO. }
program tllvmasmrefs;
{$mode objfpc}
{$asmmode att}

var
  Stored: LongInt; public name 'asm_stored';
  StoredAlias: LongInt; external name 'asm_stored';

function LocalHelper: LongInt; assembler; nostackframe;
asm
  movl $17,%eax
end;

function PublicHelper: LongInt; public name 'asm_helper'; assembler; nostackframe;
asm
  movl $25,%eax
end;

function HelperAlias: LongInt; external name 'asm_helper';

function ThroughAsm: LongInt; assembler; nostackframe;
asm
  subq $8,%rsp
  call LocalHelper
  movl %eax,StoredAlias(%rip)
  call HelperAlias
  addl StoredAlias(%rip),%eax
  addq $8,%rsp
end;

begin
  if ThroughAsm<>42 then
    Halt(1);
end.
