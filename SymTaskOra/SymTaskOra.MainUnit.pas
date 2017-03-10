unit SymTaskOra.MainUnit;

interface

uses XML.XMLIntf ;

function GetTasks(Session: TObject; UserName: String): IXMLNode; export ;

exports GetTasks ;

implementation

uses System.SysUtils, System.Classes, XML.XMLDoc, XMLValUtil, DB, Ora, IdCoderMIME ;

Var
  OldSymphony: String ;

Const
  S7StartPlugIn = 's7exec' ;

function GetParentTask(TaskList: IXMLNode; ParentID: Integer): IXMLNode ;
var
  i: Integer;
begin
  if ParentID = 0 then
  begin
    Result  := TaskList ;
    Exit ;
  end;

  for i := 0 to TaskList.ChildNodes.Count - 1 do
  begin
    if TaskList.ChildNodes.Nodes[i].ChildValues['ID'] = ParentID then
    begin
      Result  := TaskList.ChildNodes.Nodes[i].ChildNodes.Nodes['CHILDREN'] ;
      Break ;
    end
    else
    begin
      Result  := GetParentTask(TaskList.ChildNodes.Nodes[i].ChildNodes.Nodes['CHILDREN'], ParentID) ;
      if Assigned(Result) and (AsInt(Result.ChildValues['ID']) = ParentID) then
                                                                          Break ;
    end;
  end;
end;

function GetPathOldSymphony(Session: TOraSession): String ;
Var
  Qr: TOraQuery ;
begin
  Result  := EmptyStr ;
  Qr      := TOraQuery.Create(nil) ;
  Try
    Qr.Session  := Session ;
    Qr.SQL.Text := 'select nvcvalue from svm.sconst where nvcconst = ''SYMPHONY_PATH_OLD''' ;
    Qr.Open ;
    Result  := AsStr(Qr.FieldValues['nvcvalue']) ;
    Qr.Close ;
  Finally
    Qr.Free ;
  End;
end;

procedure LoadTask(ParentNode: IXMLNode; Query, QueryIco: TOraQuery) ;
Var
  Node, ParamNode, ICOList, ICO, ICOBody: IXMLNode ;
  Enc: TIdEncoderMIME ;
  ms: TMemoryStream ;
  fl: TBlobField ;
  Buffer: String ;
begin
  Node  := ParentNode.AddChild('TASK') ;
  Node.ChildValues['ID']        := Query.FieldValues['ikodtreetask'] ;
  Node.ChildValues['CAPTION']   := Query.FieldValues['nvcnaimtask'] ;
  Node.ChildValues['HINT']      := Query.FieldValues['nvchint'] ;
  Node.ChildValues['ITASKTYPE'] := Query.FieldValues['itasktype'] ;
  Node.ChildValues['FILENAME']  := AsStr(Query.FieldValues['nvcfilename'], S7StartPlugIn) ;
  Node.ChildValues['READONLY']  := Query.FieldValues['i_read_only'] ;
  ParamNode := Node.AddChild('PARAMS') ;
  ParamNode.ChildValues['TASK_PARAMS'] := Query.FieldValues['nvcparams'] ;

  IcoList := Node.AddChild('ICONS') ;
  Enc     := TIdEncoderMIME.Create(nil) ;
  Try
    with QueryIco do
    begin
      Fl    := FindField('content') as TBlobField ;
      First ;
      while not Eof do
      begin
        ICO := ICOList.AddChild('ICON') ;
        ICO.ChildValues['SIZE']     := FieldValues['icowidth'] ;
        ICO.ChildValues['ICONPATH'] := FieldValues['icopath']  ;

        ms  := TMemoryStream.Create ;
        Try
          Fl.SaveToStream(ms);
          ms.Position             := 0 ;
          Buffer                  := Enc.EncodeStream(ms) ;
          ICOBody                 := ICO.AddChild('BODY') ;
          ICOBody.NodeValue       := Buffer ;
        Finally
          ms.Free ;
        End;

        Next ;
      end;
    end;
  Finally
    Enc.Free ;
  End;
end;

procedure LoadTaskList(Session: TOraSession; UserName: String; TaskList: IXMLNode) ;
Var
  Qr, QrIco: TOraQuery ;
  ds: TDataSource ;
  ParentFld: TField ;
begin
  Qr      := TOraQuery.Create(nil);
  QrIco   := TOraQuery.Create(nil);
  ds      := TDataSource.Create(nil);
  Try
    Qr.Session  := Session ;
    Qr.SQL.Text := 'with tsk (ikodtreetask, ikodparentnode, nvcnaimtask, itasktype, nvcfilename, nvchint, nvcparams, i_read_only) as ( ' +
                   'select tt.ikodtreetask, tt.ikodparentnode, tt.nvcnaimtask, tt.itasktype, tt.nvcfilename, tt.nvchint, tt.nvcparams, utt.i_read_only ' +
                   'from svm.streetask tt  join svm.usertreetask utt on utt.ikodtreetask = tt.ikodtreetask join svm.suser usr on usr.ikoduser = utt.ikoduser ' +
                   'where upper(usr.nvclogin) = upper(''' + UserName + ''') ' +
                   ' union all ' +
                   'select tt.ikodtreetask, tt.ikodparentnode, tt.nvcnaimtask, tt.itasktype, tt.nvcfilename, tt.nvchint, tt.nvcparams, tsk.i_read_only ' +
                   'from svm.streetask tt join tsk on tsk.ikodtreetask = tt.ikodparentnode ) ' +
                   'select ikodtreetask, ikodparentnode, nvcnaimtask, itasktype, nvcfilename, nvchint, ' +
                   '(case when nvcparams is null then ''ikodtreetask='' || to_char(ikodtreetask) else nvcparams end) nvcparams, i_read_only from tsk order by ikodparentnode nulls first, itasktype, ikodtreetask' ;

    ds.DataSet    := Qr ;

    QrIco.Session := Session ;
    QrIco.SQL.Text:= 'select tti.icowidth, tti.icopath, dc.content from svm.streetask_icon tti ' +
                     'left join docs_keep.docs_content dc on dc.ikoddocs_content = tti.ikoddocs_content ' +
                     'where ikodtreetask = :ikodtreetask ' ;
    with QrIco.Params.ParamByName('ikodtreetask') do
    begin
      DataType  := ftInteger ;
      ParamType := ptInput ;
    end;
    QrIco.MasterSource  := ds ;

    OldSymphony := GetPathOldSymphony(Qr.Session) ;

    Qr.Open ;
    QrIco.Open ;
    ParentFld := Qr.FindField('ikodparentnode') ;
    Qr.First ;
    while not Qr.Eof do
    begin
      LoadTask(GetParentTask(TaskList, ParentFld.AsInteger), Qr, QrIco);
      Qr.Next ;
    end;
    QrIco.Close ;
    Qr.Close ;
  Finally
    ds.Free ;
    QrIco.Free ;
    Qr.Free ;
  End;
end;

procedure LoadUserInfo(Session: TOraSession; UserName: String; User: IXMLNode) ;
Var
  Qr: TOraQuery ;
begin
  Qr      := TOraQuery.Create(nil);
  Try
    Qr.Session  := Session ;
    Qr.SQL.Text := 'select emp.ikodsotrudnik, emp.nvcShortFIO, st.ikoddivision, dv.nvcnamedivision, ep.nvcnameestablishedpost ' +
                   'from svm.suser usr ' +
                   'left join svm.ssotrudnik emp on emp.ikodsotrudnik = usr.ikodsotrudnik ' +
                   'left join svm.staff st on st.ikodsotrudnik = emp.ikodsotrudnik ' +
                   'left join svm.sdivision dv on dv.ikoddivision = st.ikoddivision ' +
                   'left join svm.sestablishedpost ep on ep.ikodestablishedpost = st.ikodestablishedpost ' +
                   'where upper(usr.nvclogin) = upper(''' + UserName + ''') ' +
                   'order by st.dtdate_begin desc, st.dtdate_end desc nulls first ' ;
    Qr.Open ;
    Qr.First ;

    User.ChildValues['USERNAME']      := UserName ;
    User.ChildValues['IKODSOTRUDNIK'] := Qr.FieldValues['ikodsotrudnik']          ;
    User.ChildValues['SHORTFIO']      := Qr.FieldValues['nvcShortFIO']            ;
    User.ChildValues['IKODDIVISION']  := Qr.FieldValues['ikoddivision']           ;
    User.ChildValues['DIVISION']      := Qr.FieldValues['nvcnamedivision']        ;
    User.ChildValues['POST']          := Qr.FieldValues['nvcnameestablishedpost'] ;

    Qr.Close ;
  Finally
    Qr.Free ;
  End;
end;

function GetTasks(Session: TObject; UserName: String): IXMLNode;
Var
  Doc: IXMLDocument ;
begin
  if not (Session is TOraSession) then
    raise Exception.CreateFmt('Не верный тип соединения для формирования списка задач [%s]',
                                                            [Session.ClassName]);

  Doc                 := TXMLDocument.Create(nil);
  Doc.Active          := True ;
  Doc.Encoding        := 'UTF-8' ;
  Doc.DocumentElement := Doc.CreateNode('USERTASKS') ;
  LoadUserInfo(Session as TOraSession, UserName, Doc.DocumentElement.AddChild('USER')) ;
  LoadTaskList(Session as TOraSession, UserName, Doc.DocumentElement.AddChild('TASKS')) ;

  Result  := Doc.DocumentElement ;
end;

end.
