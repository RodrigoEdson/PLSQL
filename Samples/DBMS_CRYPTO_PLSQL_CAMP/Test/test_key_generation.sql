SET SERVEROUTPUT ON

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') Inicio from dual
/
DECLARE
   v_delay   PLS_INTEGER := 0;
   v_key     RAW(32);
   v_dt_base date;
BEGIN

   v_dt_base := sysdate;
   v_key := pk_secret_pass.get_pass(v_dt_base);
   dbms_output.put_line('Key: ' ||to_char(v_dt_base,'ss')||'s ='||substr(v_key,30));
         
   FOR i IN 1..5 LOOP 
      /*Random number between 0 and 3*/
      v_delay   := round(dbms_random.value(2, 6 ) );
      dbms_lock.sleep(v_delay);
      
      /*generate new key*/
      BEGIN
         pk_secret_pass.generate_new_key;
         v_dt_base := sysdate + 1/24/60/60; --Add 1s to get generated key
         v_key := pk_secret_pass.get_pass(v_dt_base);
         dbms_output.put_line('New ' || lpad(i,2,'0') ||'-'|| to_char(v_dt_base,'ss') ||'s = ' || substr(v_key,30));
      EXCEPTION
         WHEN OTHERS THEN
            dbms_output.put_line('Erro ao criar Chave ' || sqlerrm);
      END;
      
   END LOOP;
END;
/
select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') fim from dual
/
/*
SELECT start_date,
       end_date,
       round(( nvl(
          end_date,
          SYSDATE
       ) - start_date ) * 24 * 60 * 60) time_active,
       raw_key
--delete 
FROM secret_key
ORDER BY 1 DESC;
*/