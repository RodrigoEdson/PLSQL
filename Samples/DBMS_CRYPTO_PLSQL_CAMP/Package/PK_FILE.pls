create or replace PACKAGE pk_file AUTHID definer AS
   /**
   * Project:         SAMPLE FOR DBMS_CRYPTO
   * Description:     Groups procedures and functions used to read and write files
   */
   /*========================================================================*/
   const_user_default_text_dir CONSTANT VARCHAR2(30) := 'USER_TEXT_FILE_DIR';
   const_user_default_binary_dir CONSTANT VARCHAR2(30) := 'USER_BINARY_FILE_DIR';
   /*========================================================================*/
   /*========================================================================*/
   /**
   * Decrypts the text data encrypted by the package APK ENCRYPT
   *
   * @param  p_dir_name      Path of the directory where the binary file is
   * @param  p_file_name     Binary file name
   * @param  p_number_bytes  Amount of bytes to be read from file
   */
   FUNCTION read_blob_file (
      p_dir_name       IN VARCHAR2,
      p_file_name      IN VARCHAR2,
      p_number_bytes   IN NUMBER DEFAULT dbms_lob.lobmaxsize
   ) RETURN BLOB;
   /*========================================================================*/
END pk_file;