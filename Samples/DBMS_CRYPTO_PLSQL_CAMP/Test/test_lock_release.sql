DECLARE
   v_release_return   pls_integer;
BEGIN 
   v_release_return := dbms_lock.release(765602377);

   IF ( v_release_return NOT IN (0, 4) ) THEN
      dbms_output.put_line('RELEASE FALHOU:' || v_release_return);
   ELSE
      dbms_output.put_line('RELEASE OK:' || v_release_return);
   END IF;
END;