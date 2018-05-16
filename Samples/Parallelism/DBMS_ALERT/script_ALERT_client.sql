DECLARE
  vStatus  PLS_INTEGER;
  vMsgText VARCHAR2(100);
  CONST_ALERT_NAME CONSTANT VARCHAR2(10) := 'TEST_ALERT';
  CONST_TIMEOUT    CONSTANT PLS_INTEGER := 5;
  --
  noMoreMessages EXCEPTION;
  PRAGMA EXCEPTION_INIT(noMoreMessages, -6556);
BEGIN
  /*
  Send the alert signal
  */
  DBMS_ALERT.SIGNAL(CONST_ALERT_NAME, 'CLIENT 01 - MSG 001'); 
  /*
  The signal wait the transaction to be finished
  */
  dbms_lock.sleep(2);
  commit;
  --
END;
