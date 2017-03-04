unit TemplateOraSymPlugInInfo;

interface

function GetPlugInFramesClassNames: String ; export ;

implementation

// «десь требуетс€ вернуть имена классов всех фреймов экспортируемых из пакета.
// имена раздел€ютс€ зап€тыми
function GetPlugInFramesClassNames: String ;
begin
  Result  := '*' ;
end;

exports GetPlugInFramesClassNames ;

end.
