create or replace PACKAGE BODY pk_secret_pass AS
   /*========================================================================*/
   const_num_key_bytes   CONSTANT PLS_INTEGER := 32;
   const_lock_timeout    CONSTANT PLS_INTEGER := 10;
   const_lock_id         CONSTANT PLS_INTEGER := 765602377;--ora_hash('CRYPTO_KEY',1073741823)
   /*========================================================================*/
   e_get_lock_error EXCEPTION;
   e_release_lock_error EXCEPTION;
   /*========================================================================*/
   /**
   * Tries to get a lock to read or change the cryptographic key
   *
   * @param    p_mode   The lock type to be get (should be DBMS_LOCK.SS_MODE or DBMS_LOCK.X_MODE)
   */
   PROCEDURE get_lock (
      p_mode IN INTEGER
   ) IS
   BEGIN
      IF ( dbms_lock.request(
         id                  => const_lock_id,
         lockmode            => p_mode,
         timeout             => const_lock_timeout,
         release_on_commit   => true
      ) NOT IN (
         0,
         4
      ) ) THEN
         RAISE e_get_lock_error;
      END IF;
   END get_lock;
   /*========================================================================*/
   /**
   * Releases the lock used to use the cryptographic key
   */
   PROCEDURE release_lock IS
   BEGIN
      IF ( dbms_lock.release(const_lock_id) NOT IN (
         0,
         4
      ) ) THEN
         RAISE e_release_lock_error;
      END IF;
   END release_lock;
   /*========================================================================*/
   FUNCTION get_pass (
      p_ref_date   IN secret_key.start_date%TYPE DEFAULT SYSDATE
   ) RETURN secret_key.raw_key%TYPE IS
      v_raw_key   secret_key.raw_key%TYPE;
   BEGIN   
      /*Get locking to make sure no one is changing the key right now*/
      get_lock(dbms_lock.ss_mode);
      /*gets the active key on the reference date*/
      SELECT raw_key
      INTO v_raw_key
      FROM secret_key
      WHERE p_ref_date BETWEEN start_date AND nvl(
         end_date,
         p_ref_date
      );
      /*Release the lock*/
      release_lock;
      RETURN v_raw_key;
   EXCEPTION
      WHEN e_get_lock_error THEN
         raise_application_error(
            -20000,
            'Error: Unable to fetch the key while it is being updated. Try again later.'
         );
      WHEN e_release_lock_error THEN
         raise_application_error(
            -20000,
            'Failed to release key lock.'
         );
      WHEN no_data_found THEN
         RETURN NULL;
   END get_pass;
   /*========================================================================*/
   PROCEDURE generate_new_key IS
      v_end_date   DATE;
      v_last_key   secret_key%rowtype;
      v_raw_key    RAW(const_num_key_bytes);
   BEGIN
      /*Get locking to make sure no one is using (reading or changing) the key right now*/
      get_lock(dbms_lock.x_mode);
      /*Gets the last active key and lock the record*/
      BEGIN
         SELECT *
         INTO v_last_key
         FROM secret_key
         WHERE end_date IS NULL
         FOR UPDATE;
      EXCEPTION
         WHEN no_data_found THEN
            v_last_key   := NULL;
      END;
      /*Last key termination date*/
      v_end_date   := SYSDATE;
      /*Avoids consecutive calls that could create 
      more than one record at the same second */
      v_raw_key    := dbms_crypto.randombytes(const_num_key_bytes);
      IF v_last_key.start_date IS NOT NULL THEN
         LOOP
            EXIT WHEN v_end_date > v_last_key.start_date;
            /*dbms_session.SLEEP(1); Oracle 18c*/
            dbms_lock.sleep(1);
            v_end_date   := SYSDATE;
         END LOOP;
         UPDATE secret_key
         SET
            end_date = v_end_date
         WHERE end_date IS NULL;
      END IF;
      INSERT INTO secret_key (
         raw_key,
         start_date
      ) VALUES (
         v_raw_key,
         v_end_date + 1 / 24 / 60 / 60
      );
      /*Commit and relsease the X_mode lock*/
      COMMIT;
   EXCEPTION
      WHEN e_get_lock_error THEN
         raise_application_error(
            -20000,
            'Error: Unable to create a new key when the last one is being used.'
         );
   END generate_new_key;
   /*========================================================================*/
   FUNCTION store_iv (
      p_iv_raw   IN secret_iv.iv_raw%TYPE
   ) RETURN secret_iv.iv_id%TYPE IS
      PRAGMA autonomous_transaction;
      v_iv_id   secret_iv.iv_id%TYPE;
   BEGIN
      INSERT INTO secret_iv ( iv_raw ) VALUES ( p_iv_raw ) RETURNING iv_id INTO v_iv_id;
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