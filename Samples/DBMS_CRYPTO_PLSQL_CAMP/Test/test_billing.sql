SET SERVEROUTPUT ON

DECLARE
  P_CREDIT_CARD_ID NUMBER;
BEGIN
  P_CREDIT_CARD_ID := 58;

  sis_dados.PK_BILLING.INVOICE(
    P_CREDIT_CARD_ID => P_CREDIT_CARD_ID
  );
--rollback; 
END;
/