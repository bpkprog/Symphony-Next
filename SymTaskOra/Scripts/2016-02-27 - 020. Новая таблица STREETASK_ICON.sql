CREATE TABLE SVM.STREETASK_ICON
(
  ID_STREETASK_ICON  NUMBER                     NOT NULL,
  CREATEDUSER        VARCHAR2(64 CHAR)          DEFAULT trim(sys_context('USERENV', 'HOST')) || ': ' || USER,
  CREATEDDATE        DATE                       DEFAULT sysdate,
  IKODTREETASK       NUMBER,
  ICOWIDTH           NUMBER,
  ICOPATH            VARCHAR2(256 CHAR),
  IKODDOCS_CONTENT   NUMBER
)
TABLESPACE USERS
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;

COMMENT ON TABLE SVM.STREETASK_ICON IS '������ ������ � ������';

COMMENT ON COLUMN SVM.STREETASK_ICON.ID_STREETASK_ICON IS 'ID';

COMMENT ON COLUMN SVM.STREETASK_ICON.CREATEDUSER IS '��� � ��� ������� ������';

COMMENT ON COLUMN SVM.STREETASK_ICON.CREATEDDATE IS '����� �������� ������';

COMMENT ON COLUMN SVM.STREETASK_ICON.IKODTREETASK IS '������ � ������� �������� ������';

COMMENT ON COLUMN SVM.STREETASK_ICON.ICOWIDTH IS '������ ������ � ��������';

COMMENT ON COLUMN SVM.STREETASK_ICON.ICOPATH IS '���� � ����� � �������';

COMMENT ON COLUMN SVM.STREETASK_ICON.IKODDOCS_CONTENT IS '��� ������ �� ������ � ���� ������';



CREATE INDEX SVM.IDX_STREETASK_ICON_FILE ON SVM.STREETASK_ICON
(IKODDOCS_CONTENT)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


CREATE INDEX SVM.IDX_STREETASK_ICON_TASK ON SVM.STREETASK_ICON
(IKODTREETASK)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;


CREATE UNIQUE INDEX SVM.STREETASK_ICON_PK ON SVM.STREETASK_ICON
(ID_STREETASK_ICON)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            MAXSIZE          UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOPARALLEL;

CREATE SEQUENCE SVM.SQ_STREETASK_ICON
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;


GRANT SELECT ON SVM.SQ_STREETASK_ICON TO TESTDBROLE1;


CREATE OR REPLACE TRIGGER SVM.TR_BI_STREETASK_ICON
BEFORE INSERT
ON SVM.STREETASK_ICON
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
BEGIN
-- For Toad:  Highlight column ID_STREETASK_ICON
   if :new.ID_STREETASK_ICON is null then
      :new.ID_STREETASK_ICON := SQ_STREETASK_ICON.nextval;
   end if ;
END TR_BI_STREETASK_ICON;
/


ALTER TABLE SVM.STREETASK_ICON ADD (
  CONSTRAINT STREETASK_ICON_PK
  PRIMARY KEY
  (ID_STREETASK_ICON)
  USING INDEX SVM.STREETASK_ICON_PK
  ENABLE VALIDATE);

ALTER TABLE SVM.STREETASK_ICON ADD (
  CONSTRAINT FK_STREETASK_ICON_FILE 
  FOREIGN KEY (IKODDOCS_CONTENT) 
  REFERENCES DOCS_KEEP.DOCS_CONTENT (IKODDOCS_CONTENT)
  ENABLE VALIDATE,
  CONSTRAINT FK_STREETASK_ICON_TASK 
  FOREIGN KEY (IKODTREETASK) 
  REFERENCES SVM.STREETASK (IKODTREETASK)
  ON DELETE CASCADE
  ENABLE VALIDATE);

GRANT SELECT ON SVM.STREETASK_ICON TO TESTDBROLE1;
