create or replace PACKAGE BODY credit_card_tapi AS
   /*========================================================================*/
   /* insert*/
   FUNCTION ins (
      p_card_number   IN VARCHAR2,
      p_signature     IN BLOB
   ) RETURN credit_card.credit_card_id%TYPE IS
      v_final_number           credit_card.final_card_number%TYPE;
      v_encrypted_credit_card  sis_restrito.to_encrypted_raw_data;
      v_encrypted_signature    sis_restrito.to_encrypted_blob_data;
      v_credit_card_id         credit_card.credit_card_id%TYPE;
   BEGIN
      /*get final number*/
      v_final_number           := substr(
         p_card_number,
         -4
      );
      /*encrypt credt card*/
      v_encrypted_credit_card  := sis_restrito.pk_encrypt.encrypt(p_original_text   => p_card_number);
      v_encrypted_signature    := sis_restrito.pk_encrypt.encrypt(p_original_blob   => p_signature);
      /*insert*/
      INSERT INTO credit_card (
         card_number,
         final_card_number,
         signature
      ) VALUES (
         v_encrypted_credit_card,
         v_final_number,
         v_encrypted_signature
      ) RETURNING credit_card_id INTO v_credit_card_id;
      RETURN v_credit_card_id;
   END;  
   /*========================================================================*/
   /* update*/
   PROCEDURE upd (
      p_credit_card_id   IN credit_card.credit_card_id%TYPE,
      p_card_number      IN VARCHAR2
   ) IS
      v_final_number   credit_card.final_card_number%TYPE;
      v_credi_card     sis_restrito.to_encrypted_raw_data;
   BEGIN
      /*get final number*/
      v_final_number   := substr(
         p_card_number,
         -4
      );
      /*encrypt credt card*/
      v_credi_card     := sis_restrito.pk_encrypt.encrypt(p_card_number);
      /*update*/
      UPDATE credit_card
      SET final_card_number = v_final_number,
          card_number = v_credi_card
      WHERE credit_card_id = p_credit_card_id;
   END;
   /*========================================================================*/
   /* del*/
   PROCEDURE del (
      p_credit_card_id   IN credit_card.credit_card_id%TYPE
   ) IS
   BEGIN
      DELETE FROM credit_card
      WHERE credit_card_id = p_credit_card_id;
   END;
   /*========================================================================*/
END credit_card_tapi;
