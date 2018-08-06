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
   FUNCTION read_clob_file (
      p_dir_name       IN VARCHAR2,
      p_file_name      IN VARCHAR2,
      p_number_bytes   IN NUMBER DEFAULT dbms_lob.lobmaxsize
   ) RETURN CLOB AS
      v_file_data      CLOB;
      v_file_locator   BFILE;
   BEGIN   
      /*load data from text file*/
      dbms_lob.createtemporary(
         v_file_data,
         true
      );
     /*Load File*/
      v_file_locator   := bfilename(
         p_dir_name,
         p_file_name
      );
      dbms_lob.fileopen(
         v_file_locator,
         dbms_lob.file_readonly
      );
      dbms_lob.loadfromfile(
         v_file_data,
         v_file_locator,
         403
      ); 
      dbms_lob.fileclose(v_file_locator);

      RETURN v_file_data;
   END read_clob_file;
   /*========================================================================*/
   FUNCTION read_text_file (
      p_dir_name       IN VARCHAR2,
      p_file_name      IN VARCHAR2,
      p_number_bytes   IN NUMBER DEFAULT dbms_lob.lobmaxsize
   ) RETURN CLOB AS
      v_file_data      CLOB;
      v_file_locator   utl_file.file_type;
      v_line           VARCHAR2(32767);
   BEGIN
     /*Open file*/
      v_file_locator   := utl_file.fopen(
         p_dir_name,
         p_file_name,
         'R'
      ); 
      /*load data from text file*/
      dbms_lob.createtemporary(
         v_file_data,
         true
      );

      LOOP
         BEGIN
            utl_file.get_line(
               v_file_locator,
               v_line
            );
            dbms_lob.append(
               v_file_data,
               v_line
            );
         EXCEPTION
            WHEN no_data_found THEN
               EXIT;
         END;
      END LOOP;
      utl_file.fclose(v_file_locator);

      RETURN v_file_data;
   END read_text_file;
   /*========================================================================*/
   PROCEDURE write_file (
      p_dir_name    IN VARCHAR2,
      p_file_name   IN VARCHAR2,
      p_blob        IN BLOB
   ) AS
      v_buffer_size    CONSTANT INTEGER := 15 * 1024;
      v_file_locator   utl_file.file_type;
      v_blob_length    INTEGER;
      v_amount         INTEGER := v_buffer_size;
      v_offset         INTEGER := 1;
      v_buffer         RAW(v_buffer_size);
   BEGIN
      v_blob_length   := dbms_lob.getlength(p_blob);

      IF v_blob_length > 0 THEN

         v_file_locator   := utl_file.fopen(
            location       => p_dir_name,
            filename       => p_file_name,
            open_mode      => 'wb',
            max_linesize   => v_buffer_size
         );

         LOOP
            dbms_lob.read(
               lob_loc   => p_blob,
               amount    => v_amount,
               offset    => v_offset,
               buffer    => v_buffer
            );

            utl_file.put_raw(
               v_file_locator,
               v_buffer
            );

            v_offset   := v_offset + v_amount;
            EXIT WHEN v_offset >= v_blob_length;
         END LOOP;

         utl_file.fclose(v_file_locator);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF utl_file.is_open(v_file_locator) THEN
            utl_file.fclose(v_file_locator);
         END IF;
         RAISE;
   END write_file;
   /*========================================================================*/
   PROCEDURE write_file (
      p_dir_name    IN VARCHAR2,
      p_file_name   IN VARCHAR2,
      p_clob        IN CLOB
   ) AS
      v_buffer_size    CONSTANT INTEGER := 15 * 1024;
      v_file_locator   utl_file.file_type;
      v_blob_length    INTEGER;
      v_amount         INTEGER := v_buffer_size;
      v_offset         INTEGER := 1;
      v_buffer         RAW(v_buffer_size);
   BEGIN
      v_blob_length   := dbms_lob.getlength(p_clob);

      IF v_blob_length > 0 THEN

         v_file_locator   := utl_file.fopen(
            location       => p_dir_name,
            filename       => 'C' || p_file_name,
            open_mode      => 'wb',
            max_linesize   => v_buffer_size
         );

         LOOP
            dbms_lob.read(
               lob_loc   => p_clob,
               amount    => v_amount,
               offset    => v_offset,
               buffer    => v_buffer
            );

            utl_file.put_raw(
               v_file_locator,
               v_buffer
            );

            v_offset   := v_offset + v_amount;
            EXIT WHEN true;/*v_offset >= v_blob_length;*/
         END LOOP;
         utl_file.fclose(v_file_locator);

      END IF;
      /*dbms_xslprocessor.clob2file(
         cl          => p_clob,
         flocation   => p_dir_name,
         fname       => p_file_name,
         csid        => 0
      );*/

   EXCEPTION
      WHEN OTHERS THEN
         IF utl_file.is_open(v_file_locator) THEN
            utl_file.fclose(v_file_locator);
         END IF;
         RAISE;
   END write_file;
   /*========================================================================*/
END pk_file;