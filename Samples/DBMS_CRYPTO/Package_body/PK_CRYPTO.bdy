create or replace PACKAGE BODY pk_crypto AS

   FUNCTION load_text_file (
      p_dir_name    IN VARCHAR2,
      p_file_name   IN VARCHAR2,
      p_file_attr   IN file_attribute
   ) RETURN CLOB IS
      v_file_data      CLOB;
      v_file_locator   BFILE;
   BEGIN
       /*Open file*/
      v_file_locator := bfilename(
         p_dir_name,
         p_file_name
      );
      dbms_lob.fileopen(
         v_file_locator,
         dbms_lob.file_readonly
      );
      /*load data from text file*/
      dbms_lob.createtemporary(
         v_file_data,
         true
      );
      dbms_lob.loadfromfile(
         v_file_data,
         v_file_locator,
         p_file_attr.file_length
      );
      /*Close File*/
      dbms_lob.fileclose(v_file_locator);

      RETURN v_file_data;
   END load_text_file;

   FUNCTION load_binary_file (
      p_dir_name    IN VARCHAR2,
      p_file_name   IN VARCHAR2,
      p_file_attr   IN file_attribute
   ) RETURN BLOB IS
      v_file_data      BLOB;
      v_file_locator   BFILE;
   BEGIN
      /*Open file*/
      v_file_locator := bfilename(
         p_dir_name,
         p_file_name
      );
      dbms_lob.fileopen(
         v_file_locator,
         dbms_lob.file_readonly
      );
      /*load data from text file*/
      dbms_lob.createtemporary(
         v_file_data,
         true
      );
      dbms_lob.loadfromfile(
         v_file_data,
         v_file_locator,
         p_file_attr.file_length
      );
      /*Close File*/
      dbms_lob.fileclose(v_file_locator);

      RETURN v_file_data;
   END load_binary_file;

   FUNCTION calculate_hash (
      p_dir_name    IN VARCHAR2 DEFAULT const_user_default_dir,
      p_file_name   IN VARCHAR2,
      p_hash_type   IN PLS_INTEGER DEFAULT dbms_crypto.hash_md5,
      p_file_type   IN file_type DEFAULT const_text_file_type
   ) RETURN varchar2_hash IS
      v_file_data_clob   CLOB;
      v_file_data_blob   BLOB;
      v_hash             varchar2_hash;
      v_file_attr        file_attribute;
   BEGIN 
      /*get file attributes*/
      utl_file.fgetattr(
         p_dir_name,
         p_file_name,
         v_file_attr.file_exists,
         v_file_attr.file_length,
         v_file_attr.block_size
      );
      IF v_file_attr.file_exists THEN
         CASE
            p_file_type
            WHEN const_text_file_type THEN
               v_file_data_clob := load_text_file(
                  p_dir_name,
                  p_file_name,
                  v_file_attr
               );
               v_hash := calculate_hash(
                  v_file_data_clob,
                  p_hash_type
               );
            WHEN const_binary_file_type THEN
               v_file_data_blob := load_binary_file(
                  p_dir_name,
                  p_file_name,
                  v_file_attr
               );
               v_hash := calculate_hash(
                  v_file_data_blob,
                  p_hash_type
               );
         END CASE;
      END IF;

      RETURN v_hash;
   END calculate_hash;

   FUNCTION calculate_hash (
      p_file_data   IN CLOB,
      p_hash_type   IN PLS_INTEGER DEFAULT dbms_crypto.hash_md5
   ) RETURN varchar2_hash IS
      v_hash   varchar2_hash;
   BEGIN
      v_hash := dbms_crypto.hash(
         src   => p_file_data,
         typ   => p_hash_type
      );
      RETURN v_hash;
   END calculate_hash;
   
   FUNCTION calculate_hash (
      p_file_data   IN BLOB,
      p_hash_type   IN PLS_INTEGER DEFAULT dbms_crypto.hash_md5
   ) RETURN varchar2_hash IS
      v_hash   varchar2_hash;
   BEGIN
      v_hash := dbms_crypto.hash(
         src   => p_file_data,
         typ   => p_hash_type
      );
      RETURN v_hash;
   END calculate_hash;

END pk_crypto;