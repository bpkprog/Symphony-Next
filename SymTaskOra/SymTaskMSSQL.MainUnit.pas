unit SymTaskMSSQL.MainUnit;

interface

uses XML.XMLIntf ;

function GetTasks(Session: TObject; UserName: String): IXMLNode; export ;

exports GetTasks ;

implementation

Uses XML.XMLDoc ;

procedure LoadUserInfo(Session: TObject; UserName: String; UserNode: IXMLNode) ;
begin
  UserNode.ChildValues['USERNAME']      := UserName ;
  UserNode.ChildValues['IKODSOTRUDNIK'] := -1          ;
  UserNode.ChildValues['SHORTFIO']      := '-'            ;
  UserNode.ChildValues['IKODDIVISION']  := -1           ;
  UserNode.ChildValues['DIVISION']      := '-'        ;
  UserNode.ChildValues['POST']          := '-' ;

end;

procedure LoadTaskList(Session: TObject; UserName: String; TaskListNode: IXMLNode) ;
begin
  TaskListNode.Attributes['note'] := 'empty task list' ;
end;

function GetTasks(Session: TObject; UserName: String): IXMLNode;
Var
  Doc: IXMLDocument ;
begin
  Doc                 := TXMLDocument.Create(nil);
  Doc.Active          := True ;
  Doc.Encoding        := 'UTF-8' ;
  Doc.DocumentElement := Doc.CreateNode('USERTASKS') ;
  LoadUserInfo(Session, UserName, Doc.DocumentElement.AddChild('USER')) ;
  LoadTaskList(Session, UserName, Doc.DocumentElement.AddChild('TASKS')) ;

  Result  := Doc.DocumentElement ;
end;

end.
