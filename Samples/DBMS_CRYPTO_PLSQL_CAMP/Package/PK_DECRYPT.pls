create or replace PACKAGE pk_decrypt AUTHID definer /*ACCESSIBLE BY ( sist_fat.pk_billing )*/  AS 
   /**
   * Project:         SAMPLE FOR DBMS_CRYPTO
   * Description:     Contains the functions to decrypt data. (Only data encrypted by PK_ENCRYPT)
   */
   /*========================================================================*/
   /**
   * Decrypts the text data encrypted by the package APK ENCRYPT
   *
   * @param  p_encrypted_data  Object with data to be decrypted
   * @return                   The decrypted text.
   */
   FUNCTION decrypt (
      p_encrypted_data IN to_encrypted_raw_data
   ) RETURN pk_encrypt.sub_t_varchar_data;
   /*========================================================================*/
   /**
   * Decrypts the BLOB data encrypted by the package APK ENCRYPT
   *
   * @param  p_encrypted_data  Object with data to be decrypted
   * @return                   The decrypted BLOB.
   */
   FUNCTION decrypt (
      p_encrypted_data IN to_encrypted_blob_data
   ) RETURN blob;
   /*========================================================================*/
END pk_decrypt;