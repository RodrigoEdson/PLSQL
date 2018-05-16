DECLARE
  vStatus  PLS_INTEGER;
  vMsgText VARCHAR2(100);
  CONST_PIPE_NAME CONSTANT VARCHAR2(9) := 'TEST_PIPE';
  CONST_TIMEOUT   CONSTANT PLS_INTEGER := 5;
  --
  noMoreMessages EXCEPTION;
  PRAGMA EXCEPTION_INIT(noMoreMessages, -6556);
BEGIN
  /*
  Remove the Pipe to avoid problems with old executions
  */
  vStatus := dbms_pipe.remove_pipe(CONST_PIPE_NAME);
  /*
  get Pipe message
  */
  vStatus := dbms_pipe.receive_message(CONST_PIPE_NAME, CONST_TIMEOUT);
  IF vStatus = 1 THEN
    dbms_output.put_line('ERROR: Pipe timeout');
  ELSIF vStatus <> 0 THEN
    dbms_output.put_line('ERROR: Pipe failed');
  ELSE
    /*
    Show messages
    */
    LOOP
      BEGIN
        DBMS_PIPE.UNPACK_MESSAGE(vMsgText);
        dbms_output.put_line(vMsgText);
      EXCEPTION
        WHEN noMoreMessages THEN
          --buffer contains no more messages
          EXIT;
      END;
    END LOOP;
  END IF;
  --
END;
