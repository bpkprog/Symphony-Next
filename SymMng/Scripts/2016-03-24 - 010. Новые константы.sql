/*
   Гуров Е.Ю. 24.03.2016
   Ввод новых констант, для хранения параметров Симфонии
   
*/

insert into svm.sconst (nvcconst, nvcvalue, nvccomment, ikoduser, nvcname_application, itype_const)
values ('SYMMNG_UITASK', 'stbCatBut', 'Имя пакета для построения интерфейса пользователя для списка задач', null, 'SymMng.exe', 2) ;

insert into svm.sconst (nvcconst, nvcvalue, nvccomment, ikoduser, nvcname_application, itype_const)
values ('SYMMNG_UIACTION', 'stbdxRibbonH', 'Имя пакета для построения интерфейса пользователя для элементов управления задачи', null, 'SymMng.exe', 2) ;

commit ;