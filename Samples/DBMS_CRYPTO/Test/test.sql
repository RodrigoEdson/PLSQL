DECLARE
   p_dir_name    VARCHAR2(200);
   p_file_name   VARCHAR2(200);
   v_return      VARCHAR2(1024);
BEGIN
   p_dir_name := pk_crypto.const_user_default_dir;
  /* p_file_name := 'employees.csv';*/
   p_file_name := 'install.exe';

   v_return := pk_crypto.calculate_hash(
      p_file_name   => p_file_name,
      p_hash_type   => dbms_crypto.hash_md5,
      p_file_type   => pk_crypto.const_binary_file_type
   );
  /* Legacy output: */
   dbms_output.put_line(p_file_name||' hash = ' || v_return);
   
   
  p_file_name := 'employees.csv'; 

   v_return := pk_crypto.calculate_hash(
      p_file_name   => p_file_name,
      p_hash_type   => dbms_crypto.hash_md5,
      p_file_type   => pk_crypto.const_text_file_type
   );
  /* Legacy output: */
   dbms_output.put_line(p_file_name||' hash = '  || v_return);

END;