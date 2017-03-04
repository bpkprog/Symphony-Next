unit SymphonyPlugIn.ActionInterface;

interface

uses VCL.Graphics, VCL.Forms, Generics.Collections,
     SymphonyPlugIn.ParamInterface ;

Type
  ISymphonyPlugInAction = interface ;

  // Функции для получения контекста запуска акции:
  //    Handle пакета плагина; Форма, на которую натягивается фрейм плагина;
  //    Соединение с базой данных и дополнительные параметры
  TSymphonyPlugInGetHandleFunc = function (Source: ISymphonyPlugInAction): NativeUInt of object ;
  TSymphonyPlugInGetOwnerFormFunc = function (Source: ISymphonyPlugInAction): TForm of object ;
  TSymphonyPlugInGetSessionFunc = function (Source: ISymphonyPlugInAction): TObject of object ;
  TSymphonyPlugInGetParamFunc = function (Source: ISymphonyPlugInAction): ISymphonyPlugInCommand of object ;

  TFormList = TList<TForm> ;

  ISymphonyPlugInAction = interface
    ['{B39489C5-978C-4957-8AA0-6AA60FE21308}']
    // Функции доступа к значениям свойств интерфейса акции
    function  GetCaption: String ;
    function  GetCommand: ISymphonyPlugInCommand ;
    function  GetFrameClassName: String ;
    function  GetPlugInMethodName: String ;
    function  GetIconCount: Integer ;
    function  GetIcon(Index: Integer): VCL.Graphics.TBitmap ;
    function  GetName: String ;
    function  GetBeginGroup: Boolean ;
    function  GetBar: String ;
    function  GetAutoStart: Boolean ;
    function  GetVisible: Boolean ;
    function  GetContextName: String ;
    function  GetTabCaption: String ;
    function  GetTabIndex: Integer ;
    function  GetFormCaption: String ;
    function  GetForms: TFormList ;

    // Процедуры для установки функций получения контекста запуска акции
    procedure SetGetHandleFunc(AFunc: TSymphonyPlugInGetHandleFunc) ;
    procedure SetGetOwnerFormFunc(AFunc: TSymphonyPlugInGetOwnerFormFunc) ;
    procedure SetGetSessionFunc(AFunc: TSymphonyPlugInGetSessionFunc) ;
    procedure SetGetParamFunc(AFunc: TSymphonyPlugInGetParamFunc) ;

    // свойство с параметрами пользователя
    procedure SetTunerParams(const Value: ISymphonyPlugInCFGGroup);
    function  GetTunerParams: ISymphonyPlugInCFGGroup;

    // Удаление иконок после передачи данных в главную форму, для освобождения памяти
    procedure ClearIcons ;
    function  Execute(CmdLine: String = ''): Boolean ;   // Запуск акции на выполнение
    procedure ShowForms ;                           // Показывает формы акции
    function  IndexOfForm(AForm: TForm): Integer ;  // Возвращает индекс формы в списке загруженных для акции форм

    property AutoStart: Boolean read GetAutoStart;  // Акция стартует автоматически при загрузке плагина

    // свойства определяющие расположение контролов пользовательского интерфейса
    property Bar: String read GetBar ;                          // Заголовок панели инструментов
    property BeginGroup: Boolean read GetBeginGroup ;           // Контрол этой акции является началом группы контролов
    property Caption: String  read GetCaption ;                 // Заголовок контрола
    property ContextName: String read GetContextName ;          // Контекст при котором становятся виден контрол акции
    property IconCount: Integer read GetIconCount ;             // Количество иконок приляпанных к акции
    property Icon[Index: Integer]: VCL.Graphics.TBitmap read GetIcon;          // Иконка для контрола
    property TabCaption: String read GetTabCaption ;            // Заголовок закладки для контролов располагаемых на TdxRibbon
    property TabIndex: Integer read GetTabIndex ;               // Индекс закладки для контролов располагаемых на TdxRibbon
    property Visible: Boolean read GetVisible ;                 // Видимость контролов акции

    // Свойства отвечающие за формы, на которых будет располагаться плагин
    property FormCaption: String read GetFormCaption ;          // заголовок формы, на которой располагается плагин
    property Forms: TFormList read GetForms ;                   // список форм, на которых расположен плагин

    // Свойства отвечающие за выполнение акции
    property FrameClassName: String read GetFrameClassName  ;   // Имя класса фрейма, который будет создан и размещен на форме из Forms
    property PlugInMethodName: String read GetPlugInMethodName ;// Имя метода плагина, который будет выполнен
    property Command: ISymphonyPlugInCommand read GetCommand  ; // Параметры передаваемые методу или экземпляру фрейма

    property Name: String read GetName ;                        // Имя акции. Используется при формировании имени контрола
    property TunerParams: ISymphonyPlugInCFGGroup  read GetTunerParams write SetTunerParams;
  end;

  ISymphonyPlugInActionList = interface
    ['{8FC2541D-58A6-42DC-BF30-242C2AEAAC2B}']
    // Функции доступа к значениям свойств интерфейса акции
    function GetCaption: String ;
    function GetCount: Integer ;
    function GetBarCount: Integer ;
    function GetAction(Index: Integer): ISymphonyPlugInAction ;
    function FindAction(ActionName: String): ISymphonyPlugInAction ;
    function GetBar(Index: Integer): String ;

    // Процедуры для установки функций получения контекста запуска акции для всего списка акций
    procedure SetGetHandleFunc(AFunc: TSymphonyPlugInGetHandleFunc) ;
    procedure SetGetOwnerFormFunc(AFunc: TSymphonyPlugInGetOwnerFormFunc) ;
    procedure SetGetSessionFunc(AFunc: TSymphonyPlugInGetSessionFunc) ;
    procedure SetGetParamFunc(AFunc: TSymphonyPlugInGetParamFunc) ;

    // свойство с параметрами пользователя
    procedure SetTunerParams(const Value: ISymphonyPlugInCFGGroup);
    function  GetTunerParams: ISymphonyPlugInCFGGroup;

    function  ExecAutoRun: Boolean ;                         // запуск автозагрузки
    function  Execute(CmdLine: String): Boolean ;
    procedure ShowForms ;                           // Показывает формы акции

    property Caption: String read GetCaption ;
    property Count: Integer read GetCount ;
    property Action[Index: Integer]: ISymphonyPlugInAction read GetAction ;
    property BarCount: Integer read GetBarCount ;
    property Bar[Index: Integer]: String read GetBar ;
    property TunerParams: ISymphonyPlugInCFGGroup  read GetTunerParams write SetTunerParams;
  end;

  //TSymphonyPlugInActionListProc = function: ISymphonyPlugInActionList ;
  TSymphonyPlugInProc = function(ASession: TObject; AData: ISymphonyPlugInCommand): boolean ;

implementation

end.
