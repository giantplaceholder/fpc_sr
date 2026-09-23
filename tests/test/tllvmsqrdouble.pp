program SqrFloat;
{$mode delphi}
var Calls: Integer;
function GetFloat: Double;
begin
  Inc(Calls);
  Result := 1.5;
end;
procedure SetFloat(Value: Double);
begin
  if Value <> 2.25 then Halt(1);
end;
begin
  SetFloat(Sqr(GetFloat));
  if Calls <> 1 then Halt(2);
end.
