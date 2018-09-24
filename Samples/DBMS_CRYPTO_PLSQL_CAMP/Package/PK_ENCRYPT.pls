create or replace PACKAGE pk_encrypt AUTHID definer AS 
   /**
   * Project:         SAMPLE FOR DBMS_CRYPTO
   * Description:     Contains the functions to encrypt data (Text and Blob)
   */
   /*========================================================================*/
   SUBTYPE sub_t_key IS VARCHAR2(256);
   SUBTYPE sub_t_varchar_data IS VARCHAR2(1000);
   SUBTYPE sub_t_raw_iv IS RAW(16);
   SUBTYPE sub_t_raw_data IS RAW(2000);
   /*========================================================================*/
   const_encryption_type CONSTANT PLS_INTEGER := dbms_crypto.encrypt_aes256 + dbms_crypto.chain_cbc + dbms_crypto.pad_pkcs5;
   const_encryption_nls_charset CONSTANT VARCHAR2(8) := 'AL32UTF8';
   /*========================================================================*/
   /**
   * Encrypts the text and return the object that should be used to decrypt it later.
   *
   * @param  p_original_text  Text to be encrypted
   * @return                  The object with encrypted data, reference date and IV id.
   */
   FUNCTION encrypt (
      p_original_text IN sub_t_varchar_data
   ) RETURN to_encrypted_raw_data;
   /*========================================================================*/
   /**
   * Encrypts the BLOB and return the object that should be used to decrypt it later.
   *
   * @param  p_original_blob  BLOB to be encrypted
   * @return                  The object with encrypted data, reference date and IV id.
   */
   FUNCTION encrypt (
      p_original_blob IN BLOB
   ) RETURN to_encrypted_blob_data;
   /*========================================================================*/
END pk_encrypt;