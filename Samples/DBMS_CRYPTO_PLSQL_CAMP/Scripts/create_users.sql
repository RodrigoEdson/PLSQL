--
--Create Users and Grants
--
-------------------------------------------------------------
CREATE USER sis_restrito 
    IDENTIFIED BY sis_restrito 
    DEFAULT TABLESPACE users 
    TEMPORARY TABLESPACE temp;
    
GRANT CREATE SESSION        TO sis_restrito;
GRANT CREATE TABLE          TO sis_restrito;
GRANT UNLIMITED TABLESPACE  TO sis_restrito;
GRANT CREATE SEQUENCE       TO sis_restrito;
GRANT CREATE TRIGGER        TO sis_restrito;
GRANT CREATE PROCEDURE      TO sis_restrito;
GRANT CREATE TYPE           TO sis_restrito;
-------------------------------------------------------------
CREATE USER sis_dados
    IDENTIFIED BY sis_dados 
    DEFAULT TABLESPACE users 
    TEMPORARY TABLESPACE temp;

GRANT CREATE SESSION        TO sis_dados;
GRANT CREATE TABLE          TO sis_dados;
GRANT UNLIMITED TABLESPACE  TO sis_dados;
GRANT CREATE SEQUENCE       TO sis_dados;
GRANT CREATE TRIGGER        TO sis_dados;
GRANT CREATE PROCEDURE      TO sis_dados;
GRANT CREATE VIEW           TO sis_dados;
GRANT EXECUTE ON SIS_RESTRITO.TO_ENCRYPTED_RAW_DATA TO sis_dados with grant option; 
GRANT EXECUTE ON SIS_RESTRITO.TO_ENCRYPTED_BLOB_DATA TO sis_dados with grant option; 
GRANT EXECUTE ON SIS_RESTRITO.pk_encrypt TO sis_dados;
GRANT EXECUTE ON SIS_RESTRITO.pk_decrypt TO sis_dados;

-------------------------------------------------------------
CREATE USER sis_cad
    IDENTIFIED BY sis_cad 
    DEFAULT TABLESPACE users 
    TEMPORARY TABLESPACE temp;

GRANT CREATE SESSION        TO sis_cad;
GRANT CREATE SESSION        TO sis_cad;
GRANT SELECT  ON SIS_DADOS.V_CREDIT_CARD    TO sis_cad;
GRANT EXECUTE ON SIS_DADOS.PK_FILE          TO sis_cad;
GRANT EXECUTE ON SIS_DADOS.CREDIT_CARD_TAPI TO sis_cad;

-------------------------------------------------------------
CREATE USER sis_fat
    IDENTIFIED BY sis_fat
    DEFAULT TABLESPACE users 
    TEMPORARY TABLESPACE temp;

GRANT CREATE SESSION        TO sis_fat;
GRANT CREATE SESSION        TO sis_fat;
GRANT EXECUTE ON SIS_DADOS.PK_BILLING TO sis_fat;