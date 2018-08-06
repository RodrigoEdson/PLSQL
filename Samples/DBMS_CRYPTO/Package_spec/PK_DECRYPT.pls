create or replace PACKAGE pk_decrypt AUTHID definer AS 
   /*========================================================================*/
   /**
   *
   *
   */
   FUNCTION decrypt (
      p_encrypted_data IN to_encrypted_raw_data
   ) RETURN pk_encrypt.sub_t_varchar_data;
   /*========================================================================*/
   /**
   *
   *
   */
   FUNCTION decrypt (
      p_encrypted_data IN to_encrypted_blob_data
   ) RETURN blob;
   /*========================================================================*/
END pk_decrypt;