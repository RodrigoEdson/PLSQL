DECLARE
  CONST_ALERT_NAME CONSTANT VARCHAR2(10) := 'TEST_ALERT';
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
