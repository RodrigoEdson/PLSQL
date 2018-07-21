create or replace PACKAGE BODY pk_secret_pass AS

   const_num_key_bytes   CONSTANT PLS_INTEGER := 32;
   /*========================================================================*/
   FUNCTION get_pass (
      p_ref_date   IN secret_key.start_date%TYPE DEFAULT SYSDATE
   ) RETURN secret_key.raw_key%TYPE IS
      v_raw_key   secret_key.raw_key%TYPE;
   BEGIN
      /*gets the active key on the reference date*/
      SELECT raw_key
        INTO v_raw_key
        FROM secret_key
       WHERE p_ref_date BETWEEN start_date    AND nvl(
         end_date,
         p_ref_date
      );

      RETURN v_raw_key;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN NULL;
   END get_pass;
   /*========================================================================*/
   PROCEDURE generate_new_key IS
      v_end_date   DATE;
      v_last_key   secret_key%rowtype;
      v_raw_key    RAW(const_num_key_bytes);
   BEGIN
   /*Gets the last active key and lock the record*/
      BEGIN
         SELECT *
           INTO v_last_key
           FROM secret_key
          WHERE end_date IS NULL
         FOR UPDATE;
      EXCEPTION
         WHEN no_data_found THEN
            v_last_key := NULL;
      END;
   /*Avoids consecutive calls that could create 
    more than one record at the same second */
      v_raw_key := dbms_crypto.randombytes(const_num_key_bytes);

      v_end_date := SYSDATE;
      IF v_last_key.start_date IS NOT NULL THEN
         LOOP
            EXIT WHEN v_end_date > v_last_key.start_date;
         /*dbms_session.SLEEP(1); Oracle 18c*/
            dbms_lock.sleep(1);
            v_end_date := SYSDATE;
         END LOOP;

         UPDATE secret_key
            SET
            end_date = v_end_date
          WHERE end_date IS NULL;
      END IF;

      INSERT   INTO secret_key (
         raw_key,
         start_date
      ) VALUES (
         v_raw_key,
         v_end_date + 1 / 24 / 60 / 60
      );

   END generate_new_key;
   /*========================================================================*/
   FUNCTION store_iv (
      p_iv_raw   IN secret_iv.iv_raw%TYPE
   ) RETURN secret_iv.iv_id%TYPE IS
      PRAGMA autonomous_transaction;
      v_iv_id   secret_iv.iv_id%TYPE;
   BEGIN
      v_iv_id := secret_iv_seq.nextval;

      INSERT   INTO secret_iv (
         iv_id,
         iv_raw
      ) VALUES (
         v_iv_id,
         p_iv_raw
      );
      COMMIT;
      RETURN v_iv_id;
   END store_iv;
   /*========================================================================*/
   FUNCTION get_iv (
      p_iv_id   IN secret_iv.iv_id%TYPE
   ) RETURN secret_iv.iv_raw%TYPE IS
      v_iv_raw   secret_iv.iv_raw%TYPE;
   BEGIN
      SELECT iv_raw
        INTO v_iv_raw
        FROM secret_iv
       WHERE iv_id = p_iv_id;

      RETURN v_iv_raw;
   END get_iv;
   /*========================================================================*/
END pk_secret_pass;