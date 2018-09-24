DECLARE
   v_lock_return   pls_integer;
BEGIN 
   v_lock_return := dbms_lock.request(
                        id                => 765602377,
                        lockmode          => dbms_lock.ss_mode,--dbms_lock.x_mode
                        timeout           => 10,
                        release_on_commit => true);

   IF ( v_lock_return NOT IN (0, 4) ) THEN
      dbms_output.put_line('LOCK FALHOU:' || v_lock_return);
   ELSE
      dbms_output.put_line('LOCK OK:' || v_lock_return);
   END IF;
END;