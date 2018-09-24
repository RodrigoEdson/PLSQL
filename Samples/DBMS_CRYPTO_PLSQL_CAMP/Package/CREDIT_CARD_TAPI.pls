create or replace PACKAGE credit_card_tapi AUTHID definer IS
   /*========================================================================*/
   /* insert*/
   FUNCTION ins (
      p_card_number   IN VARCHAR2,
      p_signature     IN BLOB
   ) RETURN credit_card.credit_card_id%TYPE;
   /*========================================================================*/
   /* update*/
   PROCEDURE upd (
      p_credit_card_id   IN credit_card.credit_card_id%TYPE,
      p_card_number      IN VARCHAR2
   );
   /*========================================================================*/
   /* delete*/
   PROCEDURE del (
      p_credit_card_id   IN credit_card.credit_card_id%TYPE
   );
   /*========================================================================*/
END credit_card_tapi;