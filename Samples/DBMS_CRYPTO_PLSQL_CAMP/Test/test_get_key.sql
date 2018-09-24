SET SERVEROUTPUT ON
/
DECLARE
   v_delay   PLS_INTEGER := 0;
   v_key     RAW(32);
   v_dt_base date;
BEGIN
   FOR i IN 1..15 LOOP
      v_delay   := round(dbms_random.value(1,3) );
      dbms_lock.sleep(v_delay);
      
      begin
         v_dt_base := sysdate;
         v_key     := pk_secret_pass.get_pass(v_dt_base);
         dbms_output.put_line('Key ' || lpad(i,2,'0') ||'-'|| to_char(v_dt_base,'ss') ||'s = ' || substr(v_key,30));
      exception
         when others then
            dbms_output.put_line('Key error: '|| sqlerrm);
      end;
   END LOOP;
END;
/