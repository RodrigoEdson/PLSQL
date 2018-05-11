CREATE OR REPLACE TYPE to_Month_Info AUTHID DEFINER AS OBJECT
(
  firstDay DATE,
  lastDay  DATE,
  qtdDays  NUMBER(2),
/**
    * Creates an object of TO_MONTH INFO with some informations 
    * about dereference month given in parameter.
    *
    * @param pMonth The month to be detailed
    */
  CONSTRUCTOR FUNCTION to_Month_Info(pMonth IN DATE) RETURN SELF AS RESULT
)
/
