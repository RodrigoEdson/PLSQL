create or replace PACKAGE pk_billing AS
   PROCEDURE invoice (
      p_credit_card_id   IN credit_card.credit_card_id%TYPE
   );
END pk_billing;