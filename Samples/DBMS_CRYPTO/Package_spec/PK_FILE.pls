create or replace PACKAGE pk_file AUTHID definer AS
   /*========================================================================*/
   const_user_default_text_dir CONSTANT VARCHAR2(30) := 'USER_TEXT_FILE_DIR';
   const_user_default_binary_dir CONSTANT VARCHAR2(30) := 'USER_BINARY_FILE_DIR';
   /*========================================================================*/
   FUNCTION read_blob_file (
      p_dir_name       IN VARCHAR2,
      p_file_name      IN VARCHAR2,
      p_number_bytes   IN NUMBER DEFAULT dbms_lob.lobmaxsize
   ) RETURN BLOB;
   /*========================================================================*/
   FUNCTION read_clob_file (
      p_dir_name       IN VARCHAR2,
      p_file_name      IN VARCHAR2,
      p_number_bytes   IN NUMBER DEFAULT dbms_lob.lobmaxsize
   ) RETURN CLOB;
   /*========================================================================*/
   FUNCTION read_text_file (
      p_dir_name       IN VARCHAR2,
      p_file_name      IN VARCHAR2,
      p_number_bytes   IN NUMBER DEFAULT dbms_lob.lobmaxsize
   ) RETURN CLOB;
   /*========================================================================*/
   PROCEDURE write_file (
      p_dir_name    IN VARCHAR2,
      p_file_name   IN VARCHAR2,
      p_blob        IN BLOB
   );
   /*========================================================================*/
   PROCEDURE write_file (
      p_dir_name    IN VARCHAR2,
      p_file_name   IN VARCHAR2,
      p_clob        IN CLOB
   );
   /*========================================================================*/
END pk_file;