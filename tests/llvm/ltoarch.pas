program LTOArch;
{$mode objfpc}
uses LTOArchOps;
var Value: LongInt;
begin
  Value := 41;
  if FetchAdd(@Value) <> 41 then Halt(1);
  if Value <> 42 then Halt(2);
  WriteLn('OK');
end.
