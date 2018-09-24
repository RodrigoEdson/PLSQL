create or replace TYPE to_encrypted_raw_data AUTHID definer AS OBJECT (
   encrypted_data   RAW(2000),
   reference_date   DATE,
   iv_id            NUMBER,
    /**
    * Creates an object of to_encrypted_data
    *
    * @param reference_date  The references date used to encrypt the data. If not informed, the default value will be sysdate 
    */
   CONSTRUCTOR FUNCTION to_encrypted_raw_data (
        reference_date IN DATE DEFAULT SYSDATE
     ) RETURN SELF AS RESULT,
     
    /*Just to make tests easier*/
   MEMBER FUNCTION to_string RETURN VARCHAR2,
    
    /*Just to make tests easier*/
   member           procedure print_line
);