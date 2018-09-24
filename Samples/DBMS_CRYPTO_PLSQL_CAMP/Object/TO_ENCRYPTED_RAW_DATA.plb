create or replace TYPE BODY to_encrypted_raw_data AS 
   /*========================================================================*/
   CONSTRUCTOR FUNCTION to_encrypted_raw_data (
      reference_date IN DATE DEFAULT SYSDATE
   ) RETURN SELF AS RESULT
      AS
   BEGIN
      self.reference_date := nvl(
         reference_date,
         SYSDATE
      );
      self.encrypted_data := NULL;
      self.iv_id := NULL;
      return;
   END to_encrypted_raw_data;
   /*========================================================================*/
   MEMBER FUNCTION to_string RETURN VARCHAR2 IS
      v_string   VARCHAR2(5000);
   BEGIN
      IF self.encrypted_data IS NOT NULL THEN
         v_string := 'ENCRYPTED_DATA: '
                     || self.encrypted_data
                     || ', REFERENCE_DATE: '
                     || TO_CHAR(
            self.reference_date,
            'dd/mm/yyyy hh24:mi:ss'
         )
                     || ', IV_ID: '
                     || self.iv_id;
      ELSE
         v_string := 'Empty ENCRYPTED DATA';
      END IF;
      RETURN v_string;
   END;
   /*========================================================================*/
   MEMBER PROCEDURE print_line
      IS
   BEGIN
      dbms_output.put_line('ENCRYPTED_DATA: ' || self.encrypted_data);
      dbms_output.put_line('REFERENCE_DATE: '
                             || TO_CHAR(
         self.reference_date,
         'dd/mm/yyyy hh24:mi:ss'
      ) );
      dbms_output.put_line('IV_ID: ' || self.iv_id);
   END;
   /*========================================================================*/
END;