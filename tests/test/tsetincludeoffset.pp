{ Include/Exclude must adjust a nonzero set base using the converted bit-index
  register width, including when the original element type is only one byte. }
{$mode delphi}
{$inline off}
program tsetincludeoffset;
type
  TByteSet = set of 8..15;
  TWordSet = set of 8..23;
  TDWordSet = set of 8..39;

function Element(I: Integer): Integer;
begin
  Result := I;
end;

procedure Check;
var
  B: TByteSet;
  W: TWordSet;
  D: TDWordSet;
  I, J: Integer;
begin
  B := [];
  W := [];
  D := [];
  for J := 8 to 39 do
  begin
    I := Element(J);
    Include(D, I);
    if not (I in D) then Halt(1);
    if I <= 23 then
    begin
      Include(W, I);
      if not (I in W) then Halt(2);
    end;
    if I <= 15 then
    begin
      Include(B, I);
      if not (I in B) then Halt(3);
    end;
  end;
  if (B <> [8..15]) or (W <> [8..23]) or (D <> [8..39]) then Halt(4);
  for J := 39 downto 8 do
  begin
    I := Element(J);
    Exclude(D, I);
    if I in D then Halt(5);
    if I <= 23 then
    begin
      Exclude(W, I);
      if I in W then Halt(6);
    end;
    if I <= 15 then
    begin
      Exclude(B, I);
      if I in B then Halt(7);
    end;
  end;
  if (B <> []) or (W <> []) or (D <> []) then Halt(8);
end;
begin
  Check;
end.
