CREATE VIEW V_CREDIT_CARD
AS SELECT c.credit_card_id,
          c.final_card_number
   FROM credit_card c;
