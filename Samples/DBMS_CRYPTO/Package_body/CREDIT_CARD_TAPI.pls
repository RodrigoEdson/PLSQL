create or replace PACKAGE BODY credit_card_tapi IS
   /*========================================================================*/
   /* insert*/
   PROCEDURE ins (
      p_credit_card_id   IN credit_card.credit_card_id%TYPE,
      p_card_number      IN VARCHAR2,
      p_signature        IN BLOB,
      p_contract         IN CLOB
   ) IS
      v_final_number           credit_card.final_number%TYPE;
      v_encrypted_credi_card   to_encrypted_raw_data;
      v_encrypted_signature    to_encrypted_blob_data;
      v_encrypted_contract     to_encrypted_blob_data;
   BEGIN
      /*get final number*/
      v_final_number           := substr(
         p_card_number,
         -4
      );
      /*encrypt credt card*/
      v_encrypted_credi_card   := pk_encrypt.encrypt(p_original_text   => p_card_number);
      v_encrypted_signature    := pk_encrypt.encrypt(p_original_blob   => p_signature);
      v_encrypted_contract     := pk_encrypt.encrypt(p_original_clob   => p_contract);
      /*insert*/
      INSERT   INTO credit_card (
         final_number,
         credit_card_id,
         card_number,
         signature,
         contract
      ) VALUES (
         v_final_number,
         p_credit_card_id,
         v_encrypted_credi_card,
         v_encrypted_signature,
         v_encrypted_contract
      );
   END;
   /*========================================================================*/
   /* update*/
   PROCEDURE upd (
      p_credit_card_id   IN credit_card.credit_card_id%TYPE,
      p_card_number      IN VARCHAR2
   ) IS
      v_final_number   credit_card.final_number%TYPE;
      v_credi_card     to_encrypted_raw_data;
   BEGIN
      /*get final number*/
      v_final_number   := substr(
         p_card_number,
         -4
      );
      /*encrypt credt card*/
      v_credi_card     := pk_encrypt.encrypt(p_card_number);
      /*update*/
      UPDATE credit_card
         SET final_number = v_final_number,
             card_number = v_credi_card
       WHERE credit_card_id = p_credit_card_id;
   END;
   /*========================================================================*/
   /* del*/
   PROCEDURE del (
      p_credit_card_id   IN credit_card.credit_card_id%TYPE
   )
      IS
   BEGIN
      DELETE   FROM credit_card
       WHERE credit_card_id = p_credit_card_id;
   END;
   /*========================================================================*/
END credit_card_tapi;