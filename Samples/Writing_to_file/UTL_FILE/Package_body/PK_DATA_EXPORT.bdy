CREATE     OR REPLACE PACKAGE BODY pk_data_export AS
/*Number format most common in Brazil */
   const_nls_numeric_character   CONSTANT VARCHAR2(30) := 'nls_numeric_characters=,.';
   const_default_date_format     CONSTANT VARCHAR2(30) := 'dd/mm/yyyy hh24:mi:ss';
   /**
   * The cursor with the table data formatted 
   * into a single column
   *
   * @param p_owner      Table owner
   * @param p_table_name Table name
   * @param p_delimiter  Delimiter used to separate columns
   */
   CURSOR c_table_data_lines (
      p_owner        IN VARCHAR2,
      p_table_name   IN VARCHAR2,
      p_delimiter    IN VARCHAR2
   ) IS SELECT LISTAGG(pk_data_export.to_char_string(
      column_name,
      data_type,
      data_precision,
      data_scale
   ),
                         '||'''
                         || p_delimiter
                         || '''||') WITHIN  GROUP(
       ORDER BY column_id
   ) sql
          FROM all_tab_columns c
         WHERE c.owner = upper(p_owner)    AND c.table_name = upper(p_table_name)
    ORDER BY c.column_id; 
 /*=============================================================================================*/
  /**
  * Check if table exists
  *
  * @param p_owner      Table owner
  * @param p_table_name Table name
  */
   FUNCTION table_exists (
      p_owner        IN VARCHAR2,
      p_table_name   IN VARCHAR2
   ) RETURN BOOLEAN IS
      v_exists   CHAR;
   BEGIN

      SELECT 'Y'
        INTO v_exists
        FROM all_tables tab
       WHERE owner = upper(p_owner)    AND table_name = upper(p_table_name);

      RETURN true;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN false;
   END;
 /*=============================================================================================*/
  /**
  * Returns a string with all column names in 
  * the table separated by the P_DELIMITER parameter
  *
  * @param p_owner      Table owner
  * @param p_table_name Table name
  * @param p_delimiter  Delimiter used to separate columns
  */
   FUNCTION file_header_line (
      p_owner        IN VARCHAR2,
      p_table_name   IN VARCHAR2,
      p_delimiter    IN VARCHAR2
   ) RETURN VARCHAR2 IS
      v_file_header_line   VARCHAR2(32767);
      v_sql                VARCHAR2(500);
   BEGIN

      v_sql := ' SELECT LISTAGG(c.COLUMN_NAME,:delimiter)WITHIN GROUP(ORDER BY column_id) colunas '
               || ' FROM all_tab_columns c  '
               || ' WHERE c.table_name = upper(:tab_name) '
               || ' AND c.owner = upper(:owner) ';

      EXECUTE IMMEDIATE v_sql
        INTO v_file_header_line
         USING p_delimiter,p_table_name,p_owner;

      RETURN v_file_header_line;
   EXCEPTION
      WHEN OTHERS THEN
         dbms_output.put_line(v_sql);
         dbms_output.put_line(dbms_utility.format_error_backtrace);
         RAISE;
   END;
  /*=============================================================================================*/
  /**
  * Returns a SYS_REFCURSOR with all table columns 
  * values concatenated
  *
  * @param p_delimiter  Delimiter used to separate columns
  * @param p_owner      Table owner
  * @param p_table_name Table name
  */
   FUNCTION table_lines_refcursor (
      p_delimiter    IN VARCHAR2,
      p_owner        IN VARCHAR2,
      p_table_name   IN VARCHAR2
   ) RETURN SYS_REFCURSOR IS
      v_lines_refcursor   SYS_REFCURSOR;
      v_sql               VARCHAR2(32767);
   BEGIN

      OPEN c_table_data_lines(
         p_owner,
         p_table_name,
         p_delimiter
      );
      FETCH c_table_data_lines   INTO v_sql;
      CLOSE c_table_data_lines;

      v_sql := 'SELECT '
               || v_sql
               || ' FROM '
               || p_owner
               || '.'
               || p_table_name;

      OPEN v_lines_refcursor FOR v_sql;

      RETURN v_lines_refcursor;
   END;   
 /*=============================================================================================*/
  /**
  * It writes the table data into the file.
  * First, insert the line with data header, 
  *        based on columns of the table
  * Second, insert the table data using a REFCURSOR
  *
  * @param p_file       File handler
  * @param p_delimiter  Delimiter used to separate columns
  * @param p_owner      Table owner
  * @param p_table_name Table name
  */
   PROCEDURE export_delimited_data (
      p_file         IN utl_file.file_type,
      p_delimiter    IN VARCHAR2,
      p_owner        IN VARCHAR2,
      p_table_name   IN VARCHAR2
   ) IS
      v_line        VARCHAR2(32767);
      v_cur_lines   SYS_REFCURSOR;
   BEGIN
     /*header line*/
      v_line := file_header_line(
         p_owner,
         p_table_name,
         p_delimiter
      );
      utl_file.put_line(
         p_file,
         v_line
      );
      /*Data table lines*/
      v_cur_lines := table_lines_refcursor(
         p_delimiter,
         p_owner,
         p_table_name
      );
      LOOP
         FETCH v_cur_lines   INTO v_line;
         EXIT WHEN v_cur_lines%notfound;
         utl_file.put_line(
            p_file,
            v_line
         );
      END LOOP;

   END;
 /*=============================================================================================*/
   /**
   * Close the file
   *
   * @param p_file File handler
   */
   PROCEDURE close_file (
      p_file   IN OUT NOCOPY utl_file.file_type
   )
      IS
   BEGIN
      IF utl_file.is_open(p_file) THEN
         utl_file.fclose(p_file);
      END IF;
   END;
/*=============================================================================================*/
   FUNCTION to_char_string (
      p_column_name             IN VARCHAR2,
      p_column_data_type        IN VARCHAR2,
      p_column_data_precision   IN NUMBER,
      p_column_scale            IN NUMBER
   ) RETURN VARCHAR2 IS
      PRAGMA udf;
      v_col_string   VARCHAR2(300);
   BEGIN
      CASE
         p_column_data_type
         WHEN 'DATE' THEN
            v_col_string := ' to_char( '
                            || p_column_name
                            || ', '''
                            || const_default_date_format
                            || ''') ';

         WHEN 'NUMBER' THEN
            v_col_string := ' trim( to_char( '
                            || p_column_name
                            || ','''
                            || lpad(
               '0',
               nvl(
                  p_column_data_precision,
                  10
               ) - nvl(
                  p_column_scale,
                  0
               ),
               '9'
            )
                            || 'D'
                            || lpad(
               '0',
               nvl(
                  p_column_scale,
                  0
               ),
               '0'
            )
                            || ''','''
                            || const_nls_numeric_character
                            || '''))';

         ELSE
            v_col_string := p_column_name;
      END CASE;
      /**/
      RETURN v_col_string;
   END;
 /*=============================================================================================*/
   PROCEDURE to_delimited_text_file (
      p_owner        IN VARCHAR2 DEFAULT user,
      p_table_name   IN VARCHAR2,
      p_delimiter    IN VARCHAR2 DEFAULT ';',
      p_file_name    IN VARCHAR2 DEFAULT NULL
   ) IS
      v_file   utl_file.file_type;
   BEGIN
   /* Check if the table exists and 
   *  the user has privileges to access it*/
      IF table_exists(
            p_owner,
            p_table_name
         ) THEN

         v_file := utl_file.fopen(
            location    => 'USER_TEXT_FILE_DIR',
            filename    => nvl(
               p_file_name,
               p_table_name || '.csv'
            ),
            open_mode   => 'W'
         );

         export_delimited_data(
            v_file,
            p_delimiter,
            p_owner,
            p_table_name
         );

         close_file(v_file);
      ELSE
         dbms_output.put_line('Invalid table '
                                || upper(p_owner)
                                || '.'
                                || upper(p_table_name)
                                || '!!');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         close_file(v_file);
         dbms_output.put_line(dbms_utility.format_error_backtrace);
         RAISE;
   END;
   /**/
END pk_data_export;