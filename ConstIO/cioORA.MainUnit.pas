unit cioORA.MainUnit;

interface

uses cioIntf.MainUnit, SymphonyPlugIn.ParamInterface, DB, Ora, OraSQLMonitor ;

Type
  TConstDBOraIO = class(TInterfacedObject, IConstIO)
  private
    FReader: TOraQuery ;
    FWriter: TOraQuery ;
    FMonitor: TOraSQLMonitor ;

    function  GetQuery(ASession: TOraSession): TOraQuery ;
    procedure SetParamType(AQuery: TOraQuery; AParamName: String; AFieldType: TFieldType) ;
  public
    constructor Create(ASession: TOraSession) ;
    destructor  Destroy ; override ;

    function LoadCFGGroup(GroupName: String): ISymphonyPlugInCFGGroup ;
    function SaveCFGGroup(Group: ISymphonyPlugInCFGGroup): Boolean ;
    function SaveConst(Group: ISymphonyPlugInCFGGroup; Param: ISymphonyPlugInParam; IsPersonalParam: Boolean): Boolean ;
  end;

function GetConstIO(ASession: TObject): IConstIO ; export ;

exports GetConstIO ;

implementation

uses System.Variants, XMLValUtil, SymphonyPlugIn.ParamImpl ;

function GetConstIO(ASession: TObject): IConstIO ;
begin
  Result:= nil ;
  if ASession is TOraSession then
                      Result  := TConstDBOraIO.Create(TOraSession(ASession));
end;

{ TConstDBOraIO }
{$REGION 'TConstDBOraIO'}
constructor TConstDBOraIO.Create(ASession: TOraSession);
begin
  FReader := GetQuery(ASession) ;
  FReader.SQL.Text  := 'select distinct nvcconst, nvccomment, ikoduser, nvcvalue ' +
                       'from svm.sconst where regexp_like(lower(nvcname_application), lower(trim(:GroupName)) || ''[.bpl]?'') and ' +
                       '(ikoduser is null or ikoduser = (select ikoduser from svm.suser where upper(nvclogin) = upper(user)))' ;
  SetParamType(FReader, 'GroupName', ftString);

  FWriter := GetQuery(ASession) ;
  FWriter.SQL.Text  :=
'  declare l_ikoduser number ; l_rc number ; l_common number := :CommonParam ;                                                                            ' +
'  begin if l_common = 1 then l_ikoduser := null ; else begin                                                                                             ' +
'  select ikoduser into l_ikoduser from svm.suser where upper(nvclogin) = upper(user) ;                                                                   ' +
'  exception when no_data_found then                                                                                                                      ' +
'  raise_application_error(-20001, ''Пользователь "'' || user || ''" не зарегестрирован в КИС "Симфония"! Обратитесь к администратору системы.'') ;       ' +
'  end ; end if ;                                                                                                                                         ' +
'  update svm.sconst set nvcvalue = :nvcvalue                                                                                                             ' +
'  where upper(nvcconst) = upper(:nvcconst) and upper(nvcname_application) = upper(:GroupName)                                                            ' +
'  and ((l_common = 0 and ikoduser = l_ikoduser) or (l_common = 1 and ikoduser is null))    ;                                                             ' +
'  l_rc := SQL%RowCount ;                                                                                                                                 ' +
'  if l_rc = 0 and l_common = 0 then                                                                                                                      ' +
'  insert into svm.sconst (nvcconst, nvcvalue, nvccomment, ikoduser, nvcname_application, itype_const)                                                    ' +
'  select nvcconst, :nvcvalue, nvccomment, l_ikoduser, nvcname_application, 4                                                                             ' +
'  from svm.sconst                                                                                                                                        ' +
'  where upper(nvcconst) = upper(:nvcconst) and ikoduser IS NULL and                                                                                      ' +
'  itype_const = 2 and upper(nvcname_application) = upper(:GroupName) ;                                                                                   ' +
'  l_rc := SQL%RowCount ;                                                                                                                                 ' +
'  end if ;                                                                                                                                               ' +
'  if l_rc = 0 then                                                                                                                                       ' +
'  insert into svm.sconst (nvcconst, nvcvalue, ikoduser, nvcname_application, itype_const)                                                                ' +
'  values (:nvcconst, :nvcvalue, l_ikoduser, :GroupName, (case when l_common = 0 then 4 else 2 end)) ;                                                    ' +
'  end if ; commit ; end ;' ;

{                                                                                                                                                          ' +
'  declare l_ikoduser number ; begin begin                                                                                                                 ' +
'      select ikoduser into l_ikoduser from svm.suser where upper(nvclogin) = upper(user) ;                                                                ' +
'   exception when no_data_found then                                                                                                                      ' +
'         raise_application_error(-20001, ''Пользователь "'' || user || ''" не зарегестрирован в КИС "Симфония"! Обратитесь к администратору системы.'') ; ' +
'   end ;                                                                                                                                                  ' +
'                                                                                                                                                          ' +
'   update svm.sconst set nvcvalue = :nvcvalue                                                                                                             ' +
'   where upper(nvcconst) = upper(:nvcconst) and ikoduser = l_ikoduser and upper(nvcname_application) = upper(:GroupName) ;                                ' +
'                                                                                                                                                          ' +
'   if SQL%RowCount = 0 then                                                                                                                               ' +
'      insert into svm.sconst (nvcconst, nvcvalue, nvccomment, ikoduser, nvcname_application, itype_const)                                                 ' +
'      select nvcconst, :nvcvalue, nvccomment, l_ikoduser, nvcname_application, 4                                                                          ' +
'      from svm.sconst                                                                                                                                     ' +
'      where upper(nvcconst) = upper(:nvcconst) and ikoduser IS NULL and                                                                                   ' +
'            itype_const = 2 and upper(nvcname_application) = upper(:GroupName) ;                                                                          ' +
'   end if ;                                                                                                                                               ' +
'   if SQL%RowCount = 0 then                                                                                                                               ' +
'      insert into svm.sconst (nvcconst, nvcvalue, ikoduser, nvcname_application, itype_const)                                                             ' +
'      values (:nvcconst, :nvcvalue, l_ikoduser, :GroupName, 4) ;                                                                                          ' +
'    end if ; commit ; end ;  '  ;  }

  SetParamType(FWriter, 'CommonParam',  ftInteger);
  SetParamType(FWriter, 'nvcconst',     ftString);
  SetParamType(FWriter, 'nvcvalue',     ftString);
  SetParamType(FWriter, 'GroupName',    ftString);

  FMonitor  := TOraSQLMonitor.Create(nil);
  FMonitor.Active := True ;
end;

destructor TConstDBOraIO.Destroy;
begin
  FReader.Free ;
  FWriter.Free ;
  FMonitor.Free ;
  inherited;
end;

function TConstDBOraIO.GetQuery(ASession: TOraSession): TOraQuery;
begin
  Result          := TOraQuery.Create(nil);
  Result.Session  := ASession ;
end;

function TConstDBOraIO.LoadCFGGroup(GroupName: String): ISymphonyPlugInCFGGroup;
Var
  prm: ISymphonyPlugInParam ;
begin
  Result      := TSymphonyPlugInCFGGroup.Create ;
  Result.Name := GroupName ;
  with FReader do
  begin
    Params.ParamValues['GroupName'] := GroupName ;
    Open ;
    First ;
    while not Eof do
    begin
      if VarIsNull(FieldValues['ikoduser']) then
                                         prm  := Result.CommonParams.AddParam
      else
                                         prm := Result.PersonalParams.AddParam ;
      prm.Name        := FieldValues['nvcconst'] ;
      prm.Caption     := Copy(AsStr(FieldValues['nvccomment'], '-'), 1, 100) ;
      prm.Description := AsStr(FieldValues['nvccomment']) ;
      prm.Value       := FieldValues['nvcvalue'] ;
      Next ;
    end;

    Close ;
  end;
end;

function TConstDBOraIO.SaveCFGGroup(Group: ISymphonyPlugInCFGGroup): Boolean;
var
  i: Integer;
begin
  FWriter.Params.ParamValues['GroupName']  := Group.Name ;
  for i := 0 to Group.CommonParams.ParamCount - 1 do
                         SaveConst(Group, Group.CommonParams.Params[i], False) ;
  for i := 0 to Group.PersonalParams.ParamCount - 1 do
                         SaveConst(Group, Group.PersonalParams.Params[i], True) ;
end;

function TConstDBOraIO.SaveConst(Group: ISymphonyPlugInCFGGroup; Param: ISymphonyPlugInParam; IsPersonalParam: Boolean): Boolean;
begin
  with FWriter, Params do
  begin
    if IsPersonalParam then
                            ParamValues['CommonParam']  := 0
                       else
                            ParamValues['CommonParam']  := 1 ;
    ParamValues['nvcconst'] := Param.Name ;
    ParamValues['nvcvalue'] := Param.AsString ;
    ExecSQL ;
  end;
end;

procedure TConstDBOraIO.SetParamType(AQuery: TOraQuery; AParamName: String; AFieldType: TFieldType);
begin
  with AQuery.Params.ParamByName(AParamName) do
  begin
    DataType  := AFieldType ;
    ParamType := ptInput ;
  end;
end;

{$ENDREGION}

end.
