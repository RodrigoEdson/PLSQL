DECLARE
   input_string    pk_encrypt.sub_t_varchar_data := '&inputtext';
   output_string   pk_encrypt.sub_t_varchar_data;
   encrypted_obj   to_encrypted_raw_data;
BEGIN
   DBMS_OUTPUT.PUT_LINE ( 'Original string: ' || input_string); 
   encrypted_obj := pk_encrypt.encrypt(input_string);
   
   DBMS_OUTPUT.PUT_LINE ( 'Encrypted object: ' || encrypted_obj.to_string()); 
   output_string := pk_decrypt.decrypt(encrypted_obj);
   
   DBMS_OUTPUT.PUT_LINE ('Decrypted string: ' || output_string);    
END;