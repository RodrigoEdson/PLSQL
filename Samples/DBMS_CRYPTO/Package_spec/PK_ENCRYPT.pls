create or replace PACKAGE pk_encrypt AUTHID definer AS 
   /*========================================================================*/
   SUBTYPE sub_t_key IS VARCHAR2(256);
   SUBTYPE sub_t_varchar_data IS VARCHAR2(1000);
   SUBTYPE sub_t_raw_data IS RAW(2000);
   /*========================================================================*/
   const_encryption_type CONSTANT PLS_INTEGER := dbms_crypto.encrypt_aes256 + dbms_crypto.chain_cbc + dbms_crypto.pad_pkcs5;
   const_encryption_nls_charset CONSTANT VARCHAR2(8) := 'AL32UTF8';
   /*========================================================================*/
   /**
   *
   *
   * @return          parameter value
   */
   FUNCTION encrypt (
      p_original_text IN sub_t_varchar_data
   ) RETURN to_encrypted_raw_data;
   /*========================================================================*/
   /**
   *
   *
   * @return          parameter value
   */
   FUNCTION encrypt (
      p_original_blob IN BLOB
   ) RETURN to_encrypted_blob_data;
   /*========================================================================*/
   /**
   *
   *
   * @return          parameter value
   */
   FUNCTION encrypt (
      p_original_clob IN CLOB
   ) RETURN to_encrypted_blob_data;
   /*========================================================================*/
END pk_encrypt;