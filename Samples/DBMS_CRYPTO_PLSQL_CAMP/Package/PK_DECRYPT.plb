CREATE OR REPLACE PACKAGE BODY pk_decrypt AS
  /*========================================================================*/
   FUNCTION decrypt (
      p_encrypted_data IN to_encrypted_raw_data
   ) RETURN pk_encrypt.sub_t_varchar_data IS
      v_raw_data            pk_encrypt.sub_t_raw_data;
      v_key                 pk_encrypt.sub_t_key;
      v_iv_raw              pk_encrypt.sub_t_raw_iv;
      v_decrypted_varchar   pk_encrypt.sub_t_varchar_data;
   BEGIN
      v_key                 := pk_secret_pass.get_pass(p_encrypted_data.reference_date);
      v_iv_raw              := pk_secret_pass.get_iv(p_encrypted_data.iv_id);
      v_raw_data            := dbms_crypto.decrypt(
         src   => p_encrypted_data.encrypted_data,
         typ   => pk_encrypt.const_encryption_type,
         key   => v_key,
         iv    => v_iv_raw
      );
      v_decrypted_varchar   := utl_i18n.raw_to_char(
         v_raw_data,
         pk_encrypt.const_encryption_nls_charset
      );
      RETURN v_decrypted_varchar;
   END decrypt;
   /*========================================================================*/
   FUNCTION decrypt (
      p_encrypted_data IN to_encrypted_blob_data
   ) RETURN BLOB IS
      v_blob_data           BLOB;
      v_key                 pk_encrypt.sub_t_key;
      v_iv_raw              pk_encrypt.sub_t_raw_iv;
      v_decrypted_varchar   pk_encrypt.sub_t_varchar_data;
   BEGIN
      v_key      := pk_secret_pass.get_pass(p_encrypted_data.reference_date);
      v_iv_raw   := pk_secret_pass.get_iv(p_encrypted_data.iv_id);

      dbms_lob.createtemporary(
         v_blob_data,
         true,
         dbms_lob.call
      );

      dbms_crypto.decrypt(
         dst   => v_blob_data,
         src   => p_encrypted_data.encrypted_data,
         typ   => pk_encrypt.const_encryption_type,
         key   => v_key,
         iv    => v_iv_raw
      );
      RETURN v_blob_data;
   END decrypt;
   /*========================================================================*/
END pk_decrypt;