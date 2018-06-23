CREATE     OR REPLACE PACKAGE pk_data_export AUTHID definer AS
   /**
   * Return the TO_CHAR string of a column to be 
   * used into dynamic SQL
   * This function is marked with PRAGMA UDF to 
   * optimize its use into select statements
   *
   * @param p_column_name           Name of table column
   * @param p_column_data_type      The column data type
   * @param p_column_data_precision Precision value of Number columns
   * @param p_column_scale          Scale value of Number columns
   */
   FUNCTION to_char_string (
      p_column_name             IN VARCHAR2,
      p_column_data_type        IN VARCHAR2,
      p_column_data_precision   IN NUMBER,
      p_column_scale            IN NUMBER
   ) RETURN VARCHAR2;
   /**
   * Exports data from a specified table to a text file 
   * delimited by a column separator
   *
   * @param p_owner        Owner of table
   * @param p_table_name   Table name to be exported
   * @param p_delimiter    Delimiter used to separate the columns
   * @param p_file_name    File name to be created (if null assumes P_TABLE_NAME||'.csv')
   */
   PROCEDURE to_delimited_text_file (
      p_owner        IN VARCHAR2 DEFAULT user,
      p_table_name   IN VARCHAR2,
      p_delimiter    IN VARCHAR2 DEFAULT ';',
      p_file_name    IN VARCHAR2 DEFAULT NULL
   );
END pk_data_export;