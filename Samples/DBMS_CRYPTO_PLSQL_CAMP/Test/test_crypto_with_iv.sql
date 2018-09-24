DECLARE
   input_string       VARCHAR2 (200) :=  '&inputtext';
   output_string      VARCHAR2 (200);
   encrypted_raw      RAW (2000);             
   decrypted_raw      RAW (2000);             
   key_bytes_raw      RAW (32) := '5D5ED09C0FD41D293F482523799E05453319F9027F61833364DED9C4E4060189';
   encryption_type    PLS_INTEGER :=          -- total encryption type
                            DBMS_CRYPTO.ENCRYPT_AES256
                          + DBMS_CRYPTO.CHAIN_CBC
                          + DBMS_CRYPTO.PAD_PKCS5;
   iv_raw             RAW (16);

BEGIN
   DBMS_OUTPUT.PUT_LINE ( 'Original string: ' || input_string); 
   
   iv_raw        := DBMS_CRYPTO.RANDOMBYTES (16);
   DBMS_OUTPUT.PUT_LINE ( 'IV: ' || rawtohex(iv_raw)); 
   
   encrypted_raw := DBMS_CRYPTO.ENCRYPT
      (
         src => UTL_I18N.STRING_TO_RAW (input_string,  'AL32UTF8'),
         typ => encryption_type,
         key => key_bytes_raw,
         iv  => iv_raw
      );
    
   DBMS_OUTPUT.PUT_LINE ('Encrypted string: ' || rawtohex(encrypted_raw));  

   decrypted_raw := DBMS_CRYPTO.DECRYPT
      (
         src => encrypted_raw,
         typ => encryption_type,
         key => key_bytes_raw,
         iv  => iv_raw
      );
   output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
 
   DBMS_OUTPUT.PUT_LINE ('Decrypted string: ' || output_string); 
 
END;