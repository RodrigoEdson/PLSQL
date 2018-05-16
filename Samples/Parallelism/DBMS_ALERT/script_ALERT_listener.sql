DECLARE
  vStatus  PLS_INTEGER;
  vMsgText VARCHAR2(100);
  CONST_ALERT_NAME CONSTANT VARCHAR2(10) := 'TEST_ALERT';
  CONST_TIMEOUT    CONSTANT PLS_INTEGER := 5;
BEGIN
  /*
  Register interest in an alert.
  */
  dbms_alert.register(CONST_ALERT_NAME);
  /*
  get Pipe message
  */
  dbms_alert.waitone(NAME    => CONST_ALERT_NAME,
                     message => vMsgText,
                     status  => vStatus,
                     timeout => CONST_TIMEOUT);
  IF vStatus = 1 THEN
    dbms_output.put_line('ERROR: Alert timeout');
  ELSE
    /*
    Show message
    */
    dbms_output.put_line(vMsgText);
  END IF;
  /*
  Remove alert from registration list.
  */
  dbms_alert.register(CONST_ALERT_NAME);
  --
END;
