create or replace PACKAGE BODY pk_billing AS
   PROCEDURE invoice (
      p_credit_card_id   IN credit_card.credit_card_id%TYPE
   ) AS
      v_card   credit_card%rowtype;
   BEGIN
      SELECT *
      INTO v_card
      FROM credit_card
      WHERE credit_card_id = p_credit_card_id;
      dbms_output.put_line('=============== I N V O I C E ===============');
      dbms_output.put_line('CARD NUMBER');
      dbms_output.put_line('  ENCRYPTED: ' || v_card.card_number.encrypted_data);
      dbms_output.put_line('  DECRYPTED: ' ||
      sis_restrito.pk_decrypt.decrypt(v_card.card_number) );
   EXCEPTION
      WHEN no_data_found THEN
         dbms_output.put_line('Credit Card not found.');
   END invoice;
END pk_billing;