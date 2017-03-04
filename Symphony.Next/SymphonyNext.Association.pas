unit SymphonyNext.Association;

interface

procedure SetSCFAssociation ;

implementation

uses SymphonyNext.Consts, SymphonyNext.Logger
     {$IFDEF MSWINDOWS}, SymphonyNext.WinAssociation {$ENDIF}
     {$IFDEF ANDROID}, SymphonyNext.AndroidAssociation {$ENDIF}
    ;

procedure SetSCFAssociation ;
begin
  {$IFDEF MSWINDOWS}
  RegFileExt(scfExt, scfExtDesc, scfExtMenuCaption);
  {$ENDIF}

  {$IFDEF ANDROID}
  RegFileExt  ;
  {$ENDIF}
end;

end.
