DECLARE
   v_signature               BLOB;
   v_contract                NCLOB;
   v_encrypted_credit_card   to_encrypted_raw_data;
   v_encrypted_signature     to_encrypted_blob_data;
BEGIN
   v_signature   := pk_file.read_blob_file(
      p_dir_name    => pk_file.const_user_default_binary_dir,
      p_file_name   => 'signature.png'
   );

   v_contract    := pk_file.read_clob_file(
      p_dir_name    => pk_file.const_user_default_text_dir,
      p_file_name   => 'JOBS_FILE.csv'
   );

   credit_card_tapi.ins(
      p_credit_card_id   =>6,
      p_card_number      => '1234 4321 1234 4321',
      p_signature        => v_signature,
      p_contract         => v_contract
   );
END;
/*
select a.signature.encrypted_data , PK_DECRYPT.DECRYPT(
    P_ENCRYPTED_DATA => a.signature
  ) from credit_card a;
  
pk_file.write_file(
      p_dir_name    => pk_file.const_user_default_binary_dir,
      p_file_name   => 'signature_c.png',
      p_blob        => v_encrypted_signature.encrypted_data
   );

   v_decrypted_signature     := pk_decrypt.decrypt(v_encrypted_signature);

   pk_file.write_file(
      p_dir_name    => pk_file.const_user_default_binary_dir,
      p_file_name   => 'signature_n.png',
      p_blob        => v_decrypted_signature
   );
   
   DECLARE
   vclobarq          cLOB;
   varqlocalizador   BFILE;
   buf               RAW(1000);
   amt               BINARY_INTEGER := 100;
   varc varchar2(2000);
BEGIN
   varqlocalizador   := bfilename(
      pk_file.const_user_default_text_dir,
      'teste.txt'
   );
   dbms_lob.createtemporary(
      vclobarq,
      true
   );

   dbms_lob.fileopen(
      varqlocalizador,
      dbms_lob.file_readonly
   );
   dbms_lob.loadfromfile(
      vclobarq,
      varqlocalizador,
      dbms_lob.lobmaxsize
   );

   dbms_lob.read(
      vclobarq,
      amt,
      1,
      buf
   );

   dbms_lob.fileclose(varqlocalizador);
   dbms_output.put_line(varc);
END;


DECLARE
   v_contract   CLOB;
   buf RAW(1000);
     amt BINARY_INTEGER := 100;
BEGIN

   v_contract   := pk_file.read_clob_file(
      p_dir_name    => pk_file.const_user_default_text_dir,
      p_file_name   => 'JOBS_FILE.csv'
   );
   
   dbms_lob.read(v_contract, amt , 1, buf);
   
   dbms_output.put_line(dbms_lob.getlength(v_contract) );
   --dbms_output.put_line(utl_raw.cast_to_varchar2(buf));

   /*pk_file.write_file(
      p_dir_name    => pk_file.const_user_default_text_dir,
      p_file_name   => 'JOBS_FILE2.csv',
      p_clob        => v_contract
   );

END;
   */