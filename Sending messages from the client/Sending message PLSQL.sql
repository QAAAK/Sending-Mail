CREATE OR REPLACE PACKAGE BODY CORE.PKG$MN as
/*  Автор: Санталов Д.
    Назначение: Для функций компонента Monitoring and Notification  */
  C_bVERSION CONSTANT NUMBER(10,2) := '20220411.18';
  C_MAIL_SENDER CONSTANT VARCHAR2(100) := 'oracle@FF-LINUX.com';
  G_LOG   TYPE$OPER_LOG;
------------------------------------------------------------------------------------------------------------------------------
-- Возвращает версию спецификации и пакета
Function GET_VERSION return VARCHAR2 is
begin
  return 'SPEC: '||C_pVERSION||' BODY: '||C_bVERSION;
end GET_VERSION;
------------------------------------------------------------------------------------------------------------------------------
--репликация списка оповещения в системную таблицу MN_MD_MAILING_LIST
procedure copy_mailing_list as
  l_MN_MD_MAILING_LIST MN_MD_MAILING_LIST%ROWTYPE; --объявление переменной
  --l_id mn_md_mailing_list.id%type;
  TYPE CurTyp IS REF CURSOR;
  cur   CurTyp;
  l_qnt PLS_INTEGER := 0;
begin

--  l_LOG := TYPE$OPER_LOG('MAILING_LIST','COPY','RUN_PROCESS','DDS->CORE');
  G_LOG.APND('start copy');


  OPEN cur FOR 'select null ID, ''Дорогой Друг'' DESTINATION_NAME, EMAIL, '''' ALT_ADDRESS, '''' NOTIFICATION_METHOD, '''' DESTINATION_TYPE, to_date(null) LAST_DATE, (1-W#ISDEL) IS_ACTIVE, SYSDATE CRT_DATE, NOTIFICATION_GROUP
              from dds.notification_list n where (W#ENDATE = GET_MAX_ENDATE OR W#ISDEL = 1)';
  loop
    --заполнение переменной атрибутами согласно описанию таблицы
    FETCH cur INTO l_MN_MD_MAILING_LIST;
    EXIT WHEN  cur%NOTFOUND;
    l_qnt := l_qnt + 1;
    --вызов метода
    PKG$MN.SET_MAILING_LIST(l_MN_MD_MAILING_LIST);
  end loop;
  G_LOG.APND('Реплицировано записей: '||l_qnt);
  G_LOG.APND('end copy');

  commit;
--  l_LOG.SET_LOG;
exception
  when OTHERS then
    G_LOG.APND('ERROR: '||SQLERRM);
    G_LOG.APND('end copy');
    RAISE;
end copy_mailing_list;


Procedure CHECK_CODES(P_MN_CODES VARCHAR2)
AS
  l_invalid_col VARCHAR2(50);
BEGIN
  select min(col) into l_invalid_col FROM
  (
  select regexp_substr(str2, '[^,]+',1,level) as col
    from (select P_MN_CODES as str2 from dual) t
        connect by instr(str2, ',', 1, level -1)>0)
  where col not in (select CODE from MN_MD_MONITORING_NOTIFICATION)
  ;
  IF l_invalid_col is not null then
    raise_application_error(-20000,'Код '||l_invalid_col||' отсутсвует в таблице MN_MD_MONITORING_NOTIFICATION');
  END IF;
END;
------------------------------------------------------------------------------------------------------------------------------
-- Настройка адресата получения уведомлений мониторинга
Procedure SET_MAILING_LIST(X_REC IN OUT MN_MD_MAILING_LIST%ROWTYPE) is
--  l_LOG   TYPE$OPER_LOG := TYPE$OPER_LOG('SETTINGS','MANUAL','MN_MD_MAILING_LIST','SET_MAILING_LIST');
  l_ERROR VARCHAR2(4000);
  l_needed_set_log BOOLEAN := FALSE;
begin
  if G_LOG IS NULL then
    G_LOG  := TYPE$OPER_LOG('SETTINGS','MANUAL','MN_MD_MAILING_LIST','PKG$MN.SET_MAILING_LIST');
    l_needed_set_log := TRUE;
  else
    G_LOG.APND ('Начало SET_MAILING_LIST');
  end if;
  
  G_LOG.APND ('Обработка X_REC.EMAIL='||X_REC.EMAIL||', X_REC.NOTIFICATION_GROUP='||X_REC.NOTIFICATION_GROUP);
  
  X_REC.EMAIL := lower(X_REC.EMAIL);
  --Подстановка значений по умолчанию
  IF X_REC.NOTIFICATION_METHOD IS NULL THEN
    X_REC.NOTIFICATION_METHOD := 'EMAIL';
  END IF;
  IF X_REC.DESTINATION_TYPE IS NULL THEN
    X_REC.DESTINATION_TYPE := 'TECHNICAN';
  END IF;
  IF X_REC.IS_ACTIVE IS NULL THEN
    X_REC.IS_ACTIVE := 1;
  END IF;

  -- Проверяем, это новая запись или модификация существующей
  -->>2022.04.11
  -- select MAX(ID) into X_REC.ID from MN_MD_MAILING_LIST ml where (ml.ID=X_REC.ID OR ml.EMAIL = X_REC.EMAIL);
  select MAX(ID) into X_REC.ID from MN_MD_MAILING_LIST ml where ml.EMAIL = X_REC.EMAIL and ml.NOTIFICATION_GROUP=X_REC.NOTIFICATION_GROUP;
  --<< 2022.04.11
  
  if X_REC.ID IS NULL then
     IF X_REC.CRT_DATE IS NULL THEN
        X_REC.CRT_DATE := SYSDATE;
     END IF;
-- Вставка новой записи
     INSERT INTO MN_MD_MAILING_LIST values X_REC returning ID into X_REC.ID;
     G_LOG.ADD_TAB_ROW ('MN_MD_MAILING_LIST', 'ID', X_REC.ID);
  else
-- Модификация существующей записи
    update MN_MD_MAILING_LIST set ROW=X_REC WHERE ID=X_REC.ID;
    G_LOG.ADD_TAB_ROW ('MN_MD_MAILING_LIST', 'ID', X_REC.ID);
  end if;
  COMMIT;
  IF l_needed_set_log = TRUE THEN
    G_LOG.SET_LOG;
  else
    G_LOG.APND ('Завершение SET_MAILING_LIST');
  END IF;
exception
  when user_exception then
    G_LOG.APND(l_ERROR);
    IF l_needed_set_log = TRUE THEN
        G_LOG.SET_ERROR;
    else
        G_LOG.APND ('Завершение SET_MAILING_LIST');
    END IF;
    raise_application_error(-20000,l_ERROR);
  when OTHERS then
    G_LOG.APND(sqlerrm);
    IF l_needed_set_log = TRUE THEN
        G_LOG.SET_ERROR;
    else
        G_LOG.APND ('Завершение SET_MAILING_LIST');
    END IF;
    raise;
end SET_MAILING_LIST;
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
-- Настройка уведомлений мониторинга
Procedure SET_NOTIFICATION_GROUP(X_REC IN OUT MN_MD_NOTIFICATION_GROUP%ROWTYPE) is
  l_LOG   TYPE$OPER_LOG := TYPE$OPER_LOG('SETTINGS','MANUAL','MN_MD_NOTIFICATION_GROUP','SET_NOTIFICATION_GROUP');
  l_N     NUMBER;
  l_ERROR VARCHAR2(4000);
begin
-- Проверяем, это новая запись или модификация существующей
  select count(1) into l_N from MN_MD_NOTIFICATION_GROUP where ID=X_REC.ID;

  IF X_REC.IS_ACTIVE IS NULL THEN
    X_REC.IS_ACTIVE := 1;
  END IF;
    CHECK_CODES(X_REC.NOTIFICATION_CODE_LIST);
--  CHECK_LINK(X_REC.MAILING_ID,'MN_MD_MAILING_LIST');
--  CHECK_LINK(X_REC.NOTIFICATION_ID,'MN_MD_MONITORING_NOTIFICATION');
  if l_N = 0 then
    IF X_REC.CRT_DATE IS NULL THEN
        X_REC.CRT_DATE := sysdate;
    END IF;
-- Вставка новой записи
    INSERT INTO MN_MD_NOTIFICATION_GROUP values X_REC returning ID into X_REC.ID;
    l_LOG.ADD_TAB_ROW ('MN_MD_NOTIFICATION_GROUP', 'ID', X_REC.ID);
  else
-- Модификация существующей записи
    update MN_MD_NOTIFICATION_GROUP set ROW=X_REC WHERE ID=X_REC.ID;
    l_LOG.ADD_TAB_ROW ('MN_MD_NOTIFICATION_GROUP', 'ID', X_REC.ID);
  end if;
  COMMIT;
  l_LOG.SET_LOG;
exception
  when user_exception then
    l_LOG.APND(l_ERROR);
    l_LOG.SET_ERROR;
    raise_application_error(-20000,l_ERROR);
  when OTHERS then
    l_LOG.APND(sqlerrm);
    l_LOG.SET_ERROR;
    raise;
end SET_NOTIFICATION_GROUP;
------------------------------------------------------------------------------------------------------------------------------
-- Настройка связей уведомлений мониторинга с адресатами
Procedure SET_MONITORING_NOTIFICATION(X_REC IN OUT MN_MD_MONITORING_NOTIFICATION%ROWTYPE) is
  l_LOG   TYPE$OPER_LOG := TYPE$OPER_LOG('SETTINGS','MANUAL','MN_MD_MONITORING_NOTIFICATION','SET_MONITORING_NOTIFICATION');
  l_N     NUMBER;
  l_ERROR VARCHAR2(4000);
begin
-- Проверяем, это новая запись или модификация существующей
  select count(1) into l_N from MN_MD_MONITORING_NOTIFICATION where ID=X_REC.ID;

  X_REC.CODE := upper(X_REC.CODE);

  IF X_REC.IS_ACTIVE IS NULL THEN
    X_REC.IS_ACTIVE := 1;
  END IF;
  IF X_REC.STATUS IS NULL THEN
    X_REC.STATUS := 0;
  END IF;
  IF X_REC.MSCN IS NULL THEN
    X_REC.MSCN := 0;
  END IF;

  if l_N = 0 then
    IF X_REC.CRT_DATE IS NULL THEN
        X_REC.CRT_DATE := sysdate;
    END IF;

    INSERT INTO MN_MD_MONITORING_NOTIFICATION values X_REC returning ID into X_REC.ID;
    l_LOG.ADD_TAB_ROW ('MN_MD_MONITORING_NOTIFICATION', 'ID', X_REC.ID);
  else
-- Модификация существующей записи
    update MN_MD_MONITORING_NOTIFICATION set ROW=X_REC WHERE ID=X_REC.ID;
    l_LOG.ADD_TAB_ROW ('MN_MD_MONITORING_NOTIFICATION', 'ID', X_REC.ID);
  end if;
  COMMIT;
  l_LOG.SET_LOG;
exception
  when user_exception then
    l_LOG.APND(l_ERROR);
    l_LOG.SET_ERROR;
    raise_application_error(-20000,l_ERROR);
  when OTHERS then
    l_LOG.APND(sqlerrm);
    l_LOG.SET_ERROR;
    raise;
end SET_MONITORING_NOTIFICATION;
------------------------------------------------------------------------------------------------------------------------------
-- Вспомогательная функция кодировки темы
FUNCTION SUBJ_ENCODE(p_SUBJ_STR in VARCHAR2) RETURN VARCHAR2 is
  l_a varchar2(1000);
  l_b varchar2(24);
  l_result varchar2(4000);
BEGIN
  l_a := p_subj_str;
  WHILE LENGTH(l_a)>0
  LOOP
    l_b := SUBSTR(l_a, 1, 24);
    l_a := SUBSTR(l_a, 25);
    l_RESULT := l_RESULT || '=?UTF-8?B?' || UTL_RAW.cast_to_varchar2(UTL_ENCODE.base64_encode(UTL_RAW.cast_to_raw(CONVERT(l_b, 'utf8')))) || '?=';
  END LOOP;
  RETURN l_RESULT;
END;


/* Отправка CLOB по почте */
PROCEDURE SEND_CLOB_THROUGH_EMAIL(
  p_SENDER    IN VARCHAR2,                          -- Отправитель
  p_RECIPIENT IN VARCHAR2,                          -- Получатель
  p_SUBJECT   IN VARCHAR2 DEFAULT NULL,             -- Тема письма
  p_MESSAGE   IN CLOB,                              -- Текст сообщения
  p_MAILHOST  IN VARCHAR2 DEFAULT C_MAILHOST)       -- Почтовый сервер
IS
  l_MAIL_CONN         UTL_SMTP.connection;
  --p_CRLF              CONSTANT VARCHAR2(2) := CHR(13)||CHR(10);
  l_SMTP_TCPIP_PORT   CONSTANT PLS_INTEGER := 25;
  l_POS               PLS_INTEGER := 1;
  l_BYTES_O_DATA      CONSTANT PLS_INTEGER := 10000;
  l_OFFSET            PLS_INTEGER := l_BYTES_O_DATA;
  l_MSG_LENGTH        CONSTANT PLS_INTEGER := DBMS_LOB.getlength(p_MESSAGE);
BEGIN
  l_MAIL_CONN := UTL_SMTP.OPEN_CONNECTION(p_MAILHOST, l_SMTP_TCPIP_PORT);
  UTL_SMTP.HELO(l_MAIL_CONN,p_MAILHOST);
  UTL_SMTP.MAIL(l_MAIL_CONN,p_SENDER);
  UTL_SMTP.RCPT(l_MAIL_CONN,p_RECIPIENT);
  UTL_SMTP.OPEN_DATA(l_MAIL_CONN);
  UTL_SMTP.WRITE_DATA(l_MAIL_CONN,'MIME-Version: 1.0'||UTL_TCP.CRLF);
  --UTL_SMTP.WRITE_DATA(l_MAIL_CONN,'Content-Type: text/plain; charset="koi8-r"'||UTL_TCP.CRLF);
  UTL_SMTP.WRITE_DATA(l_MAIL_CONN,'Content-Type: text/plain; charset="UTF-8"'||UTL_TCP.CRLF);
  UTL_SMTP.WRITE_DATA(l_MAIL_CONN,'Content-Transfer-Encoding: quoted-printable'||UTL_TCP.CRLF);
  UTL_SMTP.WRITE_DATA(l_MAIL_CONN,'Date: '||TO_CHAR(SYSTIMESTAMP, 'Dy, dd Mon YYYY HH24:MI:SS TZHTZM')||UTL_TCP.CRLF);
  UTL_SMTP.WRITE_DATA(l_MAIL_CONN,'From: '||p_SENDER||UTL_TCP.CRLF);
  UTL_SMTP.WRITE_DATA(l_MAIL_CONN,'To: <'||p_RECIPIENT||'>'||UTL_TCP.CRLF);
  UTL_SMTP.WRITE_DATA(l_MAIL_CONN,'Subject: '||SUBJ_ENCODE(p_SUBJECT)||UTL_TCP.CRLF||UTL_TCP.CRLF);
  WHILE l_POS < l_MSG_LENGTH
  LOOP
    --UTL_SMTP.WRITE_RAW_DATA(l_MAIL_CONN,UTL_RAW.CAST_TO_RAW(CONVERT(DBMS_LOB.SUBSTR(p_MESSAGE, l_OFFSET, l_POS),'CL8KOI8R')));
    UTL_SMTP.WRITE_DATA(l_MAIL_CONN, UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.QUOTED_PRINTABLE_ENCODE(UTL_RAW.CAST_TO_RAW(DBMS_LOB.SUBSTR(p_MESSAGE, l_OFFSET, l_POS)))) );
    l_POS := l_POS + l_OFFSET;
    l_OFFSET := LEAST(l_BYTES_O_DATA, l_MSG_LENGTH - l_OFFSET);
  END LOOP;
    
  UTL_SMTP.close_data(l_MAIL_CONN);
  UTL_SMTP.quit(l_MAIL_CONN);
END SEND_CLOB_THROUGH_EMAIL;


PROCEDURE SEND_MAIL 
    (
    p_RECIPIENT IN VARCHAR2,
    p_SENDER IN VARCHAR2,
    p_subject IN VARCHAR2,
    p_MESSAGE IN CLOB,
    p_attach_name IN VARCHAR2 DEFAULT NULL,
    p_attach_mime IN VARCHAR2 DEFAULT 'text/plain',
    p_attach_clob IN CLOB DEFAULT NULL,
    p_MAILHOST IN VARCHAR2 DEFAULT C_MAILHOST,
    p_smtp_port IN NUMBER DEFAULT 25)
AS
    l_mail_conn UTL_SMTP.connection;
    l_boundary VARCHAR2(50) := '---###!!!@@@---';
    l_step PLS_INTEGER := 24573;
    
    l_POS               PLS_INTEGER := 1;
    l_BYTES_O_DATA      CONSTANT PLS_INTEGER := 10000;
    l_OFFSET            PLS_INTEGER := l_BYTES_O_DATA;
    l_MSG_LENGTH        PLS_INTEGER;    
BEGIN
    l_mail_conn := UTL_SMTP.open_connection(p_MAILHOST, p_smtp_port);
    UTL_SMTP.helo(l_mail_conn, p_MAILHOST);
    UTL_SMTP.mail(l_mail_conn, p_SENDER);
    UTL_SMTP.rcpt(l_mail_conn, p_RECIPIENT);
    UTL_SMTP.open_data(l_mail_conn);
    UTL_SMTP.write_data(l_mail_conn, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, 'To: ' || p_RECIPIENT || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, 'From: ' || p_SENDER || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, 'Subject: ' || SUBJ_ENCODE(p_SUBJECT) || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, 'Reply-To: ' || p_SENDER || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, 'MIME-Version: 1.0' || UTL_TCP.crlf);
    UTL_SMTP.write_data(l_mail_conn, 'Content-Type: multipart/mixed; boundary="' || l_boundary || '"' || UTL_TCP.crlf || UTL_TCP.crlf);
          
    IF DBMS_LOB.getlength(p_MESSAGE) > 0  THEN
        UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || UTL_TCP.crlf);
        UTL_SMTP.WRITE_DATA(l_MAIL_CONN,'Content-Transfer-Encoding: quoted-printable'||UTL_TCP.CRLF);
        UTL_SMTP.write_data(l_mail_conn, 'Content-Type: text/plain; charset="UTF-8"' || UTL_TCP.crlf || UTL_TCP.crlf);--koi8-r
       -- UTL_SMTP.write_data(l_mail_conn, 'Content-Type: text/plain; charset="windows-1251' || UTL_TCP.crlf || UTL_TCP.crlf);
        l_MSG_LENGTH  := DBMS_LOB.getlength(p_MESSAGE);  
        WHILE l_POS < l_MSG_LENGTH
        LOOP
            UTL_SMTP.WRITE_DATA(l_MAIL_CONN, UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.QUOTED_PRINTABLE_ENCODE(UTL_RAW.CAST_TO_RAW(DBMS_LOB.SUBSTR(p_MESSAGE, l_OFFSET, l_POS)))) );
            l_POS := l_POS + l_OFFSET;
            l_OFFSET := LEAST(l_BYTES_O_DATA, l_MSG_LENGTH - l_OFFSET);
        END LOOP;
        UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);  
    END IF;

    
    IF p_attach_name IS NOT NULL THEN
        l_POS := 1;
        l_OFFSET := l_BYTES_O_DATA;
       --!!! p_attach_clob := utl_encode.TEXT_ENCODE(p_attach_clob,'CL8KOI8R');
        l_MSG_LENGTH  := DBMS_LOB.getlength(p_attach_clob);  
        UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || UTL_TCP.crlf);
        
       ---!!! utl_smtp.write_data (l_mail_conn, 'Content-Type: text/plain; charset="windows-1251"'||utl_tcp.crlf); ---!!!
       ---!!! UTL_SMTP.write_data(l_mail_conn, 'Content-Type: charset="UTF-8";' || p_attach_mime || '; name="' || p_attach_name || '"' || UTL_TCP.crlf); ---!!!
        ---!!! UTL_SMTP.write_data(l_mail_conn, 'Content-Type: text/plain; charset="UTF-8";' || p_attach_mime || '; name="' || p_attach_name || '"' || UTL_TCP.crlf);
        UTL_SMTP.write_data(l_mail_conn, 'Content-Type: charset="koi8-r";' || p_attach_mime || '; name="' || p_attach_name || '"' || UTL_TCP.crlf);

        UTL_SMTP.WRITE_DATA(l_MAIL_CONN, 'Content-Transfer-Encoding: quoted-printable'||UTL_TCP.CRLF);
        ---!!!!UTL_SMTP.WRITE_DATA(l_MAIL_CONN, 'Content-Transfer-Encoding: 8bit'||UTL_TCP.CRLF);
      
        UTL_SMTP.write_data(l_mail_conn, 'Content-Disposition: attachment; filename="' || p_attach_name || '"' || UTL_TCP.crlf || UTL_TCP.crlf);

        WHILE l_POS < l_MSG_LENGTH
        LOOP
            UTL_SMTP.WRITE_DATA(l_MAIL_CONN, UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.QUOTED_PRINTABLE_ENCODE(UTL_RAW.CAST_TO_RAW(DBMS_LOB.SUBSTR(p_attach_clob, l_OFFSET, l_POS)))) );
            
            --!!!UTL_SMTP.WRITE_DATA(l_MAIL_CONN, utl_encode.TEXT_ENCODE(UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.QUOTED_PRINTABLE_ENCODE(UTL_RAW.CAST_TO_RAW(DBMS_LOB.SUBSTR(p_attach_clob, l_OFFSET, l_POS)))),'CL8KOI8R') );---!!!
            --!!!UTL_SMTP.WRITE_DATA(l_MAIL_CONN,convert(UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.QUOTED_PRINTABLE_ENCODE(UTL_RAW.CAST_TO_RAW(DBMS_LOB.SUBSTR(p_attach_clob, l_OFFSET, l_POS)))),'cl8mswin1251', 'utf8') );---!!!            
            --!!!UTL_SMTP.WRITE_DATA(l_MAIL_CONN, UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.QUOTED_PRINTABLE_ENCODE(utl_encode.base64_encode(UTL_RAW.CAST_TO_RAW(DBMS_LOB.SUBSTR(p_attach_clob, l_OFFSET, l_POS))))) ); --!!!
            l_POS := l_POS + l_OFFSET;
            l_OFFSET := LEAST(l_BYTES_O_DATA, l_MSG_LENGTH - l_OFFSET);
        END LOOP;

        UTL_SMTP.write_data(l_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
    END IF;
    UTL_SMTP.write_data(l_mail_conn, '--' || l_boundary || '--' || UTL_TCP.crlf);
    UTL_SMTP.close_data(l_mail_conn);
    UTL_SMTP.quit(l_mail_conn);
END SEND_MAIL;

------------------------------------------------------------------------------------------------------------------------------
/* Процедура отправки уведомлений по триггеру
   - Получает на вход ID записи из MN_MD_MONITORING_NOTIFICATION
   - Получает список адресатов из MN_MD_MAILING_LIST
   - Формирует сообщение, для отправки для каждого адресата на основе метаданных, учитывая шаблоны и тип адресата
   - Производит отправку сообщения на основе способа оповещения в MN_MD_MAILING_LIST.NOTIFICATION_METHOD,
     регистрирует уведомление в журнале MN_NOTIFICATION */
Procedure NOTIFY(p_ID NUMBER, p_TRGR_DIRECT NUMBER DEFAULT 1) is
  l_NOTIF      MN_MD_MONITORING_NOTIFICATION%ROWTYPE;
  l_SQL        VARCHAR2(4000); -- Текст выполняемого SQL
--  l_TXT        VARCHAR2(4000);
  l_ADDRESS    VARCHAR2(100);
--  l_GOOD_COUNT PLS_INTEGER := 0; -- количество успешных оповещений
--  l_ERR_COUNT  PLS_INTEGER := 0; -- количество неуспешных оповещений
  l_CODE       VARCHAR2(30);     -- Код оповещения
  l_MSCN       NUMBER;      -- Номер текущего смены состояния оповещения на момент отправки сообщения (срабатывания триггера)
  l_NOTIFICATION_TYPE   VARCHAR2(30);   -- Тип оповещения: ‘CRITICAL_PROBLEM’, ‘PROBLEM’, ‘PROBLEM_RESOLVED’, ‘INFORMING’
  l_NOTIFICATION_SUBJET VARCHAR2(4000); -- Заголовок сообщения
  l_NOTIFICATION_TEXT   CLOB;           -- Текст сообщения
  l_SENDING_STATUS      NUMBER;         -- Статус отправки сообщения: 0-не отправлено, 1-отправлено, -1 – ошибка отправки
  --l_ERR_MESSAGE         VARCHAR2(1000); -- Текст ошибки отправки сообщения
  l_TRIGGER_DATE        DATE;           -- Время срабатывания триггера
  --l_SENDING_DATE        DATE;           -- Время отправки сообщения
  l_ERROR               VARCHAR2(1000); -- Текст сообщения об ошибке
  l_MN_SENSOR           VARCHAR2(10000); -- Результат функции, текст которой в поле SENSOR
  --l_MN_SQL_DETAIL       VARCHAR2(32767); -- Результат функции, текст которой в поле SQL_DETAIL
  l_PIECE               VARCHAR2(32767); -- Результат строки функции, текст которой в поле SQL_DETAIL
  l_SYSRC               SYS_REFCURSOR;
  L_ERROR_QNT PLS_INTEGER := 0;
begin
  G_LOG  := TYPE$OPER_LOG('NOTIFICATION_DEF','NOTIFICATION','UNKNOWN','PKG$MN.NOTIFY');

  select * into l_NOTIF from MN_MD_MONITORING_NOTIFICATION where id=p_ID;
    l_CODE := l_NOTIF.CODE;
  -- Если для формирования шаблонов используется функция SENSOR, выполняем функцию в этом поле
--  if instr(l_NOTIF.SUBJECT_TEMPLATE,'[SENSOR]')>0 or instr(l_NOTIF.MESSAGE_TEMPLATE,'[SENSOR]')>0 then
-- !!! Результат функции SENSOR нужен для определения типа оповещения !!!
    l_NOTIF.SENSOR := replace(l_NOTIF.SENSOR,'[ID]',p_ID);
    execute immediate l_NOTIF.SENSOR into l_MN_SENSOR;
--  end if;
  if p_TRGR_DIRECT = 1 then
    l_NOTIFICATION_TYPE := l_NOTIF.DIRECT_TRIGGER_TYPE;
    l_NOTIFICATION_TEXT := l_NOTIF.MESSAGE_TEMPLATE;
    --l_TRIGGER_DATE := l_NOTIF.LAST_DT_DATE;
    G_LOG.APND('Сработал прямой триггер');
  else
    l_NOTIFICATION_TYPE := l_NOTIF.REVERSE_TRIGGER_TYPE;
    l_NOTIFICATION_TEXT := l_NOTIF.REVERSE_MESSAGE_TEMPLATE;
    --l_TRIGGER_DATE := l_NOTIF.LAST_RT_DATE;
    G_LOG.APND('Сработал обратный триггер');
  end if;
  l_TRIGGER_DATE := SYSDATE; 
  -- Если для формирования шаблонов используется функция SQL_DETAIL, выполняем функцию в этом поле
  -- Учитываем, что функция может возвращать несколько строк
  --if instr(l_NOTIF.SUBJECT_TEMPLATE,'[SQL_DETAIL]')>0 or instr(l_NOTIF.MESSAGE_TEMPLATE,'[SQL_DETAIL]')>0 then
 
  -- Формируем заголовок сообщения
  l_NOTIFICATION_SUBJET := l_NOTIF.SUBJECT_TEMPLATE;
  l_NOTIFICATION_SUBJET := replace(l_NOTIFICATION_SUBJET,'[SENSOR]',l_MN_SENSOR);
--  l_NOTIFICATION_SUBJET := replace(l_NOTIFICATION_SUBJET,'[SQL_DETAIL]',l_MN_SQL_DETAIL);

  l_NOTIFICATION_SUBJET := replace(l_NOTIFICATION_SUBJET,'[CODE]',l_NOTIF.CODE);
  l_NOTIFICATION_SUBJET := replace(l_NOTIFICATION_SUBJET,'[DIRECT_TRIGGER]',l_NOTIF.DIRECT_TRIGGER);
  l_NOTIFICATION_SUBJET := replace(l_NOTIFICATION_SUBJET,'[REVERSE_TRIGGER]',l_NOTIF.REVERSE_TRIGGER);
  l_NOTIFICATION_SUBJET := replace(l_NOTIFICATION_SUBJET,'[DIRECT_TRIGGER_TYPE]',l_NOTIF.DIRECT_TRIGGER_TYPE);
  l_NOTIFICATION_SUBJET := replace(l_NOTIFICATION_SUBJET,'[REVERSE_TRIGGER_TYPE]',l_NOTIF.REVERSE_TRIGGER_TYPE);
  l_NOTIFICATION_SUBJET := replace(l_NOTIFICATION_SUBJET,'[ERR_MESSAGE]',l_NOTIF.ERR_MESSAGE);
  --l_NOTIFICATION_SUBJET := replace(l_NOTIFICATION_SUBJET,'[MSCN]',to_char(l_NOTIF.MSCN));
  --l_NOTIFICATION_SUBJET := replace(l_NOTIFICATION_SUBJET,'[LAST_DT_DATE]',to_char(l_NOTIF.LAST_DT_DATE,'DD.MM.YYYY HH24:MI:SS'));
  --l_NOTIFICATION_SUBJET := replace(l_NOTIFICATION_SUBJET,'[LAST_RT_DATE]',to_char(l_NOTIF.LAST_DT_DATE,'DD.MM.YYYY HH24:MI:SS'));
  l_NOTIFICATION_SUBJET := replace(l_NOTIFICATION_SUBJET,'[LAST_SENSOR_VALUE]',l_NOTIF.LAST_SENSOR_VALUE);
  G_LOG.APND('NOTIFICATION_SUBJET: "'||l_NOTIFICATION_SUBJET||'"');
  -- Формируем сообщение, для отправки для каждого адресата на основе метаданных, учитывая шаблоны и тип адресата
  --l_NOTIFICATION_TEXT := l_NOTIF.MESSAGE_TEMPLATE;
  l_NOTIFICATION_TEXT := replace(l_NOTIFICATION_TEXT,'[SENSOR]',l_MN_SENSOR);
--  l_NOTIFICATION_TEXT := replace(l_NOTIFICATION_TEXT,'[SQL_DETAIL]',l_MN_SQL_DETAIL);            -- Уже заполнено ранее
  l_NOTIFICATION_TEXT := replace(l_NOTIFICATION_TEXT,'[CODE]',l_NOTIF.CODE);
  l_NOTIFICATION_TEXT := replace(l_NOTIFICATION_TEXT,'[DIRECT_TRIGGER]',l_NOTIF.DIRECT_TRIGGER);
  l_NOTIFICATION_TEXT := replace(l_NOTIFICATION_TEXT,'[REVERSE_TRIGGER]',l_NOTIF.REVERSE_TRIGGER);
  l_NOTIFICATION_TEXT := replace(l_NOTIFICATION_TEXT,'[DIRECT_TRIGGER_TYPE]',l_NOTIF.DIRECT_TRIGGER_TYPE);
  l_NOTIFICATION_TEXT := replace(l_NOTIFICATION_TEXT,'[REVERSE_TRIGGER_TYPE]',l_NOTIF.REVERSE_TRIGGER_TYPE);
  l_NOTIFICATION_TEXT := replace(l_NOTIFICATION_TEXT,'[ERR_MESSAGE]',l_NOTIF.ERR_MESSAGE);
  --l_NOTIFICATION_TEXT := replace(l_NOTIFICATION_TEXT,'[MSCN]',to_char(l_NOTIF.MSCN));
  --l_NOTIFICATION_TEXT := replace(l_NOTIFICATION_TEXT,'[LAST_DT_DATE]',to_char(l_NOTIF.LAST_DT_DATE,'DD.MM.YYYY HH24:MI:SS'));
  --l_NOTIFICATION_TEXT := replace(l_NOTIFICATION_TEXT,'[LAST_RT_DATE]',to_char(l_NOTIF.LAST_DT_DATE,'DD.MM.YYYY HH24:MI:SS'));
  l_NOTIFICATION_TEXT := replace(l_NOTIFICATION_TEXT,'[LAST_SENSOR_VALUE]',l_NOTIF.LAST_SENSOR_VALUE);
  
   --G_LOG.APND('NOTIFICATION_TEXT_WITHOUT_DETAIL: "'||l_NOTIFICATION_TEXT||'"');
   if instr(l_NOTIFICATION_TEXT,'[SQL_DETAIL]')>0 then
    --l_MN_SQL_DETAIL := NULL;
    --G_LOG.APND('SQL_DETAIL: "'||l_NOTIF.SQL_DETAIL||'"');
    open l_SYSRC for l_NOTIF.SQL_DETAIL;
    loop
      fetch l_SYSRC into l_PIECE;
      exit when l_SYSRC%NOTFOUND;

      --G_LOG.APND('Piece: "'||substr(l_PIECE,1,200)||'"');
      l_NOTIFICATION_TEXT := replace(l_NOTIFICATION_TEXT,'[SQL_DETAIL]',chr(13)||chr(10)||l_PIECE||'[SQL_DETAIL]');
    end loop;
    G_LOG.APND('l_SYSRC ROWCOUNT: '||l_SYSRC%ROWCOUNT);
    close l_SYSRC;
    l_NOTIFICATION_TEXT := replace(l_NOTIFICATION_TEXT,'[SQL_DETAIL]','');
  end if;
  G_LOG.APND('______________________________________________________________________');
  --G_LOG.APND('NOTIFICATION_TEXT: "'||SUBSTR(l_NOTIFICATION_TEXT,1,4000)||'"');

  -- Получаем список адресатов из MN_MD_MAILING_LIST
  for cur_MAIL_LIST in (select *
                          from MN_MD_MAILING_LIST
                         where IS_ACTIVE=1
                           and NOTIFICATION_GROUP in (select GROUP_NUM
                                        from MN_MD_NOTIFICATION_GROUP
                                       where IS_ACTIVE=1
                                         and INSTR(','||REPLACE(NOTIFICATION_CODE_LIST,' ','')||',',','||l_NOTIF.CODE||',') > 0)) loop
--    begin
-- Производим отправку сообщения на основе способа оповещения в MN_MD_MAILING_LIST.NOTIFICATION_METHOD, регистрирует уведомление в журнале MN_NOTIFICATION */
      G_LOG.APND('cur_MAIL_LIST.EMAIL: '||cur_MAIL_LIST.EMAIL);
      BEGIN
      case cur_MAIL_LIST.NOTIFICATION_METHOD
      when 'EMAIL' then
        G_LOG.APND(cur_MAIL_LIST.NOTIFICATION_METHOD||': "'||cur_MAIL_LIST.EMAIL||'"');
        l_ADDRESS := cur_MAIL_LIST.EMAIL;
--        SEND_EMAIL_WITH_ATTACH(p_SENDER    => C_MAIL_SENDER,
--                                p_RECIPIENT => l_ADDRESS,
--                                p_SUBJECT   => l_NOTIFICATION_SUBJET,
--                                p_MESSAGE   => l_NOTIFICATION_TEXT,
--                                p_ATTACH_NAME   => l_NOTIF.ATTACH_NAME);
                                
--        SEND_CLOB_THROUGH_EMAIL(p_SENDER    => C_MAIL_SENDER,
--                                p_RECIPIENT => l_ADDRESS,
--                                p_SUBJECT   => l_NOTIFICATION_SUBJET,
--                                p_MESSAGE   => l_NOTIFICATION_TEXT);
        
            IF l_NOTIF.ATTACH_NAME IS NOT NULL THEN    
                send_mail(p_RECIPIENT => l_ADDRESS,
                    p_SENDER => C_MAIL_SENDER,
                    p_subject => l_NOTIFICATION_SUBJET,
                    p_MESSAGE => l_NOTIFICATION_SUBJET||chr(13)||chr(10)||'Отчет во вложении',
                    p_attach_name => l_NOTIF.ATTACH_NAME,
                    p_attach_clob => l_NOTIFICATION_TEXT);
            ELSE                               
                send_mail(p_RECIPIENT => l_ADDRESS,
                    p_SENDER => C_MAIL_SENDER,
                    p_subject => l_NOTIFICATION_SUBJET,
                    p_MESSAGE => l_NOTIFICATION_TEXT);
            END IF;

         G_LOG.APND('Отправлено сообщение:');
         G_LOG.WRITE('Адрес: '||l_ADDRESS);
         G_LOG.WRITE('Заголовок: '||l_NOTIFICATION_SUBJET);
         G_LOG.WRITE('Текст (до 1000 символов): '||substr(l_NOTIFICATION_TEXT,1,1000));
      when 'SYSTEM' then
        G_LOG.APND(cur_MAIL_LIST.NOTIFICATION_METHOD||': "'||cur_MAIL_LIST.ALT_ADDRESS||'"');
        l_ADDRESS := cur_MAIL_LIST.ALT_ADDRESS;
      else
        RAISE_APPLICATION_ERROR(-20001, 'Unknown NOTIFICATION METHOD: "'||cur_MAIL_LIST.NOTIFICATION_METHOD||'"');
      end case;
      l_MSCN := l_NOTIF.MSCN;
      l_SENDING_STATUS := 1;
      insert into MN_NOTIFICATION(CODE,  MSCN,              NOTIFICATION_METHOD,  NOTIFICATION_TYPE,  NOTIFICATION_SUBJET,  NOTIFICATION_TEXT,
                                  ADDRESS,  SENDING_STATUS,  ERR_MESSAGE,  TRIGGER_DATE,  SENDING_DATE, CRT_DATE, ATTACH_NAME)
      values                   (l_CODE,l_MSCN,cur_MAIL_LIST.NOTIFICATION_METHOD,l_NOTIFICATION_TYPE,l_NOTIFICATION_SUBJET,substr(l_NOTIFICATION_TEXT,1,4000),
                                l_ADDRESS,l_SENDING_STATUS,l_NOTIF.ERR_MESSAGE,l_TRIGGER_DATE,SYSDATE, SYSDATE, l_NOTIF.ATTACH_NAME);
      COMMIT;
      EXCEPTION WHEN OTHERS THEN
            G_LOG.APND('Ошибка отправки уведомления: '||SQLERRM);
            L_ERROR_QNT := L_ERROR_QNT + 1;
      END;
  end loop;
  IF L_ERROR_QNT > 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Ошибки отправки уведомлений в количестве: '||L_ERROR_QNT);
  END IF;
  G_LOG.SET_LOG;
EXCEPTION WHEN OTHERS THEN
    G_LOG.SET_ERROR;
    RAISE;
end NOTIFY;

/* Процедура проверки новых оповещений
   Сканирует активные записи таблицы MN_MD_MONITORING_NOTIFICATION */
Function SCAN_ACTIVE_NOTIFICATION return varchar2 is
  --l_LOG        TYPE$OPER_LOG := TYPE$OPER_LOG('SCAN_ACTIVE_NOTIFICATION','REGLAMENT','UNKNOWN','UNKNOWN');
  l_SQL        VARCHAR2(4000); -- Текст выполняемого SQL
  l_RESULT     VARCHAR2(4000); -- Результат запроса в поле SENSOR
  l_GOOD_COUNT PLS_INTEGER := 0; -- количество успешно проверенных активных записей таблицы MN_MD_MONITORING_NOTIFICATION
  l_ERR_COUNT  PLS_INTEGER := 0; -- количество ошибок
  l_TXT        VARCHAR2(4000);
  l_ERROR      VARCHAR2(1000); -- Текст сообщения об ошибке
  l_TRIGGER_DIRECTION NUMBER; -- 1 - прямой триггер, 2 - обратный триггер
  l_return_text VARCHAR2(200);
  l_needed_set_log BOOLEAN := FALSE;
begin
  if G_LOG IS NULL then
    G_LOG  := TYPE$OPER_LOG('MANUAL','NOTIFICATION','UNKNOWN','PKG$MN.SCAN_ACTIVE_NOTIFICATION');
    l_needed_set_log := TRUE;
  end if;
-- Регламентный процесс мониторинга системы (например, раз в пять минут) сканирует активные записи таблицы MN_MD_MONITORING_NOTIFICATION
  for curMN in (select * from MN_MD_MONITORING_NOTIFICATION where IS_ACTIVE = 1 order by ID) loop
    l_TRIGGER_DIRECTION := 0;
    begin
-- Для каждой записи, выполняет запрос из поля SENSOR
      l_SQL := curMN.SENSOR;
-- Запрос в поле SENSOR работает с таблицей MN_MD_MONITORING_NOTIFICATION и представлениями V$MN_MONITORING и V$MN_WARNING
-- Запрос должен вернуть одну строку и один столбец (одно поле), иначе ошибка настройки сенсора.
      l_SQL := replace(l_SQL,'[ID]',curMN.ID);
      G_LOG.APND('l_SQL='||l_SQL);
      execute immediate l_SQL into l_RESULT;
      G_LOG.APND('l_RESULT='||l_RESULT);
-- В случае если текущий результат отличается от предыдущего в поле LAST_SENSOR_VALUE:
      if (l_RESULT is NOT NULL and curMN.LAST_SENSOR_VALUE is NULL) or
         (l_RESULT is NULL and curMN.LAST_SENSOR_VALUE is NOT NULL) or
         (l_RESULT != curMN.LAST_SENSOR_VALUE) then
-- Проверяется возможность срабатывания триггера
        if l_RESULT is NOT NULL then
-- При значении отличном от NULL, срабатывает триггер DIRECT_TRIGGER, выполняется стандартная процедура PKG$MN.NOTIFY, которой на вход подается ID записи.
          l_TRIGGER_DIRECTION := 1;
          G_LOG.APND('Прямой триггер');
          
          l_SQL := replace(curMN.DIRECT_TRIGGER,'[ID]',to_char(curMN.ID));
          G_LOG.APND('DIRECT_TRIGGER: '||l_SQL);
          
           update MN_MD_MONITORING_NOTIFICATION
          -- Новое значение записывается в поле LAST_SENSOR_VALUE
             set LAST_SENSOR_VALUE=l_RESULT,
                 STATUS=1,                      -- сработал прямой триггер
                 ERR_MESSAGE=NULL,              -- Очистка сообщения об ошибке, если ранее была
                 MSCN=curMN.MSCN+1             -- MSCN увеличивается на 1
          where ID=curMN.ID;
          
          
          execute immediate l_SQL;
          
          update MN_MD_MONITORING_NOTIFICATION
-- Новое значение записывается в поле LAST_SENSOR_VALUE
             set LAST_DT_DATE=SYSDATE           -- В поле LAST_DT_DATE устанавливается текущая дата и время, после того как сообщение отправлено
          where ID=curMN.ID;
                     
        else
          l_TRIGGER_DIRECTION := 2;
          G_LOG.APND('Обратный триггер');
-- При значении NULL, срабатывает триггер REVERSE_TRIGGER, если значение REVERSE_TRIGGER_TYPE заполнено, выполняется стандартная процедура PKG$MN.NOTIFY,
-- которой на вход подается ID записи. В поле LAST_RT_DATE устанавливается текущая дата и время (даже если значение REVERSE_TRIGGER пустое).
          
           update MN_MD_MONITORING_NOTIFICATION
-- Новое значение записывается в поле LAST_SENSOR_VALUE
             set LAST_SENSOR_VALUE=l_RESULT,
                 STATUS=2,                      -- сработал обратный триггер
                 ERR_MESSAGE=NULL,              -- Очистка сообщения об ошибке, если ранее была
                 MSCN=curMN.MSCN+1              -- MSCN увеличивается на 1
           where ID=curMN.ID;

           if curMN.REVERSE_TRIGGER_TYPE is not NULL then
             l_SQL := replace(curMN.REVERSE_TRIGGER,'[ID]',to_char(curMN.ID));
             G_LOG.APND('REVERSE_TRIGGER: '||l_SQL);
             execute immediate l_SQL;             
            
--            NOTIFY(curMN.ID,l_RESULT,l_LOG);  -- вызов производится из шаблона при необходимости
           end if; -- curMN.REVERSE_TRIGGER_TYPE is not NULL
           update MN_MD_MONITORING_NOTIFICATION
-- Новое значение записывается в поле LAST_SENSOR_VALUE
             set LAST_RT_DATE=SYSDATE           -- В поле LAST_RT_DATE устанавливается текущая дата и время, после того как сообщение отправлено
           where ID=curMN.ID;
        end if; -- l_RESULT is NULL
      else
        update MN_MD_MONITORING_NOTIFICATION
           set STATUS=0,                        -- триггер не сработал
               ERR_MESSAGE=NULL,                -- Очистка сообщения об ошибке, если ранее была
               LAST_RT_DATE=SYSDATE             -- В поле LAST_RT_DATE устанавливается текущая дата и время
         where ID=curMN.ID;
      end if;
      COMMIT;
      l_GOOD_COUNT:=l_GOOD_COUNT+1;
    exception
      when user_exception then
        l_ERR_COUNT := l_ERR_COUNT + 1;
        G_LOG.APND('ERROR: '||l_ERROR);
        update MN_MD_MONITORING_NOTIFICATION
           set STATUS=0-l_TRIGGER_DIRECTION,    -- триггер сработал с ошибкой ( -1 - прямой, -2 - обратный)
               ERR_MESSAGE=l_ERROR,             -- Сообщение об ошибке триггера
               LAST_RT_DATE=SYSDATE             -- В поле LAST_RT_DATE устанавливается текущая дата и время    -- Уточнить у Василия, надо ли менять дату !!!
         where ID=curMN.ID;
        COMMIT;
      when others then
        l_ERR_COUNT := l_ERR_COUNT + 1;
        l_TXT := replace(sqlerrm,'''','"');
        G_LOG.APND('ERROR: '||l_TXT);
        update MN_MD_MONITORING_NOTIFICATION
           set STATUS=0-l_TRIGGER_DIRECTION,    -- триггер сработал с ошибкой ( -1 - прямой, -2 - обратный)
               ERR_MESSAGE=l_TXT,               -- Сообщение об ошибке триггера
               LAST_RT_DATE=SYSDATE             -- В поле LAST_RT_DATE устанавливается текущая дата и время    -- Уточнить у Василия, надо ли менять дату !!!
         where ID=curMN.ID;
        COMMIT;
    end;
  end loop; -- MN_MD_MONITORING_NOTIFICATION

  if l_ERR_COUNT = 0 then
    l_return_text := 'Успешно обработано: '||to_char(l_GOOD_COUNT);
    G_LOG.APND(l_return_text);
    IF l_needed_set_log = TRUE THEN
        G_LOG.SET_LOG;
    END IF;
  else
    l_return_text := 'Успешно обработано: '||to_char(l_GOOD_COUNT)||' Количество ошибок: '||to_char(l_ERR_COUNT);
    G_LOG.APND(l_return_text);
    IF l_needed_set_log = TRUE THEN
        G_LOG.SET_ERROR;
    END IF;
  end if;

  RETURN l_return_text;
end SCAN_ACTIVE_NOTIFICATION;

-- Процедура для регламентного процесса мониторинга системы
Procedure RUN_PROCESS(P_PROCESS_TYPE IN VARCHAR2, P_PROCESS_CODE IN VARCHAR2) is
  --l_LOG   TYPE$OPER_LOG := TYPE$OPER_LOG(P_PROCESS_CODE,P_PROCESS_TYPE,'RUN_PROCESS','PKG$MN');
  l_TXT   VARCHAR2(2000);
  l_stat VARCHAR2(1000);
begin
  G_LOG := TYPE$OPER_LOG(P_PROCESS_CODE,P_PROCESS_TYPE,'RUN_PROCESS','PKG$MN');
  CORE.PKG$CM.UPDATE_PROCESS_STATUS(p_PROCESS_TYPE, P_PROCESS_CODE, CORE.PKG$CM.C_STATUS_RUNNING, '');
  if P_PROCESS_TYPE='NOTIFICATION' and P_PROCESS_CODE='NOTIFICATION_DEF' then
    copy_mailing_list;
    l_stat := SCAN_ACTIVE_NOTIFICATION;
    CORE.PKG$CM.UPDATE_PROCESS_STATUS(p_PROCESS_TYPE, p_PROCESS_CODE, CORE.PKG$CM.C_STATUS_FINISHED, l_stat);
    G_LOG.SET_LOG;
  else
    CORE.PKG$CM.UPDATE_PROCESS_STATUS(p_PROCESS_TYPE, p_PROCESS_CODE, CORE.PKG$CM.C_STATUS_INTERRUPTED, 'ERROR');
    G_LOG.APND('ERROR: Неверный тип процесса или процесс');
    G_LOG.SET_ERROR;
  end if;

exception
  when OTHERS then
    CORE.PKG$CM.UPDATE_PROCESS_STATUS(p_PROCESS_TYPE, p_PROCESS_CODE, CORE.PKG$CM.C_STATUS_INTERRUPTED, 'ERROR: '||sqlerrm);
    l_TXT := sqlerrm;
    G_LOG.SET_ERROR;
    --dbms_output.put_line('ERROR: '||l_TXT);
    RAISE;
end RUN_PROCESS;

FUNCTION GET_LAST_TRG_DATE (p_id NUMBER) RETURN DATE DETERMINISTIC
as
   l_last_date DATE;
   pragma autonomous_transaction;
   pragma UDF;
BEGIN
   select MAX(LEAST (
          COALESCE (n.LAST_DT_DATE,
                    n.LAST_RT_DATE,
                    DATE '2000-01-01'),
          COALESCE (n.LAST_RT_DATE,
                    n.LAST_DT_DATE,
                    DATE '2000-01-01'))) into l_last_date from MN_MD_MONITORING_NOTIFICATION n where n.id = p_id;
   RETURN l_last_date;
END GET_LAST_TRG_DATE;
end PKG$MN;
/

