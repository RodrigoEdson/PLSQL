CREATE TABLE credit_card (
   credit_card_id   NUMBER(10,0) NOT NULL,
   card_number      hr.to_encrypted_raw_data,
   final_number     VARCHAR2(4 BYTE),
   signature        to_encrypted_blob_data,
   contract         to_encrypted_blob_data,
   CONSTRAINT credit_card_pk PRIMARY KEY ( credit_card_id )
)