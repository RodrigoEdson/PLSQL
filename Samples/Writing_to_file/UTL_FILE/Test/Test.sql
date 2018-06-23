BEGIN
   pk_data_export.to_delimited_text_file(
      p_owner        => 'hr',
      p_table_name   => 'employees'
   );

   pk_data_export.to_delimited_text_file(
      p_owner        => 'HR',
      p_table_name   => 'COUNTRIES',
      p_delimiter    => '#'
   );

   pk_data_export.to_delimited_text_file(
      p_owner        => 'HR',
      p_table_name   => 'DEPARTMENTS',
      p_delimiter    => ';'
   );

   pk_data_export.to_delimited_text_file(
      p_owner        => 'hr',
      p_table_name   => 'Locations',
      p_file_name    => 'Locations.txt'
   );
   
   pk_data_export.to_delimited_text_file(
      p_owner        => 'hr',
      p_table_name   => 'JOBS',
      p_delimiter    => '/',
      p_file_name    => 'JOBS_FILE.csv'
   );
END;