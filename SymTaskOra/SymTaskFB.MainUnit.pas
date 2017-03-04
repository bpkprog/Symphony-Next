unit SymTaskFB.MainUnit;

interface

uses XMLIntf ;

function GetTasks(Session: TObject; UserName: String): IXMLNode; export ;

exports GetTasks ;

implementation

uses System.SysUtils, System.Classes, XML.XMLDoc, IdCoderMIME, XMLValUtil,
     DB, IBX.IBDatabase ;

function GetTasks(Session: TObject; UserName: String): IXMLNode;
Var
  Doc: IXMLDocument ;
begin
  if not (Session is TIBDatabase) then
    raise Exception.CreateFmt('Не верный тип соединения для формирования списка задач [%s]',
                                                            [Session.ClassName]);

  Doc                 := TXMLDocument.Create(nil);
  Doc.Active          := True ;
  Doc.Encoding        := 'UTF-8' ;
  Doc.DocumentElement := Doc.CreateNode('USERTASKS') ;
{  LoadUserInfo(Session as TOraSession, UserName, Doc.DocumentElement.AddChild('USER')) ;
  LoadTaskList(Session as TOraSession, UserName, Doc.DocumentElement.AddChild('TASKS')) ;

  Doc.SaveToFile('tasks.xml');  }
  Result  := Doc.DocumentElement ;
end;

end.
