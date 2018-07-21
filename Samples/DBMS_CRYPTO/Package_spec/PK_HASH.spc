create or replace PACKAGE pk_hash AUTHID definer AS

   SUBTYPE varchar2_hash IS VARCHAR2(1024);
   SUBTYPE file_type IS PLS_INTEGER RANGE 1..2;

   TYPE file_attribute IS RECORD ( file_exists BOOLEAN,
   file_length NUMBER,
   block_size BINARY_INTEGER );

   const_user_default_dir CONSTANT VARCHAR2(30) := 'USER_TEXT_FILE_DIR';
   const_binary_file_type CONSTANT file_type := 1;
   const_text_file_type CONSTANT file_type := 2;
   /**
   *Calulates a hash value
   *
   *@param p_dir_name Directory name
   *@param p_file_name File Name
   *@param p_hash_type Type of algorithm to be used
   *@param p_file_type Type of file
   */
   FUNCTION calculate_hash (
      p_dir_name    IN VARCHAR2 DEFAULT const_user_default_dir,
      p_file_name   IN VARCHAR2,
      p_hash_type   IN PLS_INTEGER DEFAULT dbms_crypto.hash_md5,
      p_file_type   IN file_type DEFAULT const_text_file_type
   ) RETURN varchar2_hash;
   /**
   *Calulates a hash value
   *
   *@param p_file_data LOB data
   *@param p_hash_type Type of algorithm to be used
   */
   FUNCTION calculate_hash (
      p_file_data   IN CLOB,
      p_hash_type   IN PLS_INTEGER DEFAULT dbms_crypto.hash_md5
   ) RETURN varchar2_hash;
   /**
   *Calulates a hash value
   *
   *@param p_file_data LOB data
   *@param p_hash_type Type of algorithm to be used
   */
   FUNCTION calculate_hash (
      p_file_data   IN BLOB,
      p_hash_type   IN PLS_INTEGER DEFAULT dbms_crypto.hash_md5
   ) RETURN varchar2_hash;


END pk_hash;