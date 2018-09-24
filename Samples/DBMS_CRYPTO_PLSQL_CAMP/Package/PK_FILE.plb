create or replace PACKAGE BODY pk_file AS 
   /*========================================================================*/
   FUNCTION read_blob_file (
      p_dir_name       IN VARCHAR2,
      p_file_name      IN VARCHAR2,
      p_number_bytes   IN NUMBER DEFAULT dbms_lob.lobmaxsize
   ) RETURN BLOB AS
      v_file_data      BLOB;
      v_file_locator   BFILE;
   BEGIN
     /*Open file*/
      v_file_locator   := bfilename(
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
         p_number_bytes
      );
      /*Close File*/
      dbms_lob.fileclose(v_file_locator);

      RETURN v_file_data;
   END read_blob_file;
   /*========================================================================*/
END pk_file;