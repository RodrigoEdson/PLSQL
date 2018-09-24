CREATE OR REPLACE PACKAGE BODY pk_encrypt AS 
   /*========================================================================*/
   FUNCTION encrypt (
      p_original_text IN sub_t_varchar_data
   ) RETURN to_encrypted_raw_data IS
      v_key                  sub_t_key;
      v_raw_data             sub_t_raw_data;
      v_encrypted_raw_data   to_encrypted_raw_data := NEW to_encrypted_raw_data ();
      v_iv_raw               sub_t_raw_iv;
   BEGIN
      v_key                                 := pk_secret_pass.get_pass(v_encrypted_raw_data.reference_date);
      v_iv_raw                              := dbms_crypto.randombytes(16);
      v_encrypted_raw_data.iv_id            := pk_secret_pass.store_iv(v_iv_raw);
      v_raw_data                            := utl_i18n.string_to_raw(
         p_original_text,
         pk_encrypt.const_encryption_nls_charset
      );
      v_encrypted_raw_data.encrypted_data   := dbms_crypto.encrypt(
         src   => v_raw_data,
         typ   => pk_encrypt.const_encryption_type,
         key   => v_key,
         iv    => v_iv_raw
      );
      RETURN v_encrypted_raw_data;
   END encrypt;
   /*========================================================================*/
   FUNCTION encrypt (
      p_original_blob IN BLOB
   ) RETURN to_encrypted_blob_data IS
      v_key                   sub_t_key;
      v_encrypted_blob_data   to_encrypted_blob_data := NEW to_encrypted_blob_data ();
      v_iv_raw                sub_t_raw_iv;
   BEGIN
      v_key                         := pk_secret_pass.get_pass(v_encrypted_blob_data.reference_date);
      v_iv_raw                      := dbms_crypto.randombytes(16);
      v_encrypted_blob_data.iv_id   := pk_secret_pass.store_iv(v_iv_raw);

      dbms_lob.createtemporary(
         v_encrypted_blob_data.encrypted_data,
         true,
         dbms_lob.call
      );

      dbms_crypto.encrypt(
         dst   => v_encrypted_blob_data.encrypted_data,
         src   => p_original_blob,
         typ   => pk_encrypt.const_encryption_type,
         key   => v_key,
         iv    => v_iv_raw
      );
      RETURN v_encrypted_blob_data;
   END encrypt;
   /*========================================================================*/
END pk_encrypt;