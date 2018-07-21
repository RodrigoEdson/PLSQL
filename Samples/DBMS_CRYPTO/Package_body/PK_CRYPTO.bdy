create or replace PACKAGE BODY pk_crypto AS
   /*========================================================================*/
   FUNCTION encrypt (
      p_original_text IN sub_t_varchar_data
   ) RETURN to_encrypted_raw_data IS
      v_key                  sub_t_key;
      v_raw_data             sub_t_raw_data;
      v_encrypted_raw_data   to_encrypted_raw_data := NEW to_encrypted_raw_data ();
      v_iv_raw               secret_iv.iv_raw%type;
   BEGIN
      v_key := pk_secret_pass.get_pass(v_encrypted_raw_data.reference_date);
      v_iv_raw := dbms_crypto.randombytes(16);
      v_encrypted_raw_data.iv_id := pk_secret_pass.store_iv(v_iv_raw);
      
      v_raw_data := utl_i18n.string_to_raw(
         p_original_text,
         pk_crypto.const_encryption_nls_charset
      );
      v_encrypted_raw_data.encrypted_data := dbms_crypto.encrypt(
         src   => v_raw_data,
         typ   => pk_crypto.const_encryption_type,
         key   => v_key,
         iv    => v_iv_raw
      );
      
      RETURN v_encrypted_raw_data;
   END encrypt;
   /*========================================================================*/
   FUNCTION decrypt (
      p_encrypted_data IN to_encrypted_raw_data
   ) RETURN sub_t_varchar_data IS
      v_raw_data            sub_t_raw_data;
      v_key                 sub_t_key;
      v_iv_raw              secret_iv.iv_raw%type;
      v_decrypted_varchar   sub_t_varchar_data;
   BEGIN
      v_key := pk_secret_pass.get_pass(p_encrypted_data.reference_date);
      v_iv_raw := pk_secret_pass.get_iv(p_encrypted_data.iv_id);

      v_raw_data := dbms_crypto.decrypt(
         src   => p_encrypted_data.encrypted_data,
         typ   => pk_crypto.const_encryption_type,
         key   => v_key,
         iv    => v_iv_raw
      );

      v_decrypted_varchar := utl_i18n.raw_to_char(
         v_raw_data,
         'AL32UTF8'
      );

      RETURN v_decrypted_varchar;
   END decrypt;
   /*========================================================================*/
END pk_crypto;