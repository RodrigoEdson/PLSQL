create or replace TYPE to_encrypted_blob_data AUTHID definer AS OBJECT (
   encrypted_data   blob,
   reference_date   DATE,
   iv_id            NUMBER,
    /**
    * Creates an object of to_encrypted_data
    *
    * @param reference_date  The references date used to encrypt the data. If not informed, the default value will be sysdate 
    */
    CONSTRUCTOR FUNCTION to_encrypted_blob_data (
      reference_date IN DATE DEFAULT SYSDATE
    ) RETURN SELF AS RESULT,

    /**/
    MEMBER FUNCTION to_string RETURN VARCHAR2,

    /**/
    member procedure print_line
);