CREATE OR REPLACE package SVM.p_USAGESTATISTICTASK as

-- ������ ����������. ���������� ����������
procedure OnExecute(p_ikodtreetask in number) ;

end ;
/

create package body p_USAGESTATISTICTASK as

-- ������ ����������. ���������� ����������
procedure OnExecute(p_ikodtreetask in number) as
begin
   insert into svm.usagestatistictask (ikodtreetask) values (p_ikodtreetask) ;
end OnExecute;

end ;