create or replace PACKAGE pk_secret_pass AUTHID definer AS
   /**
   * Project:         SAMPLE FOR DBMS_CRYPTO
   * Description:     Contains the functions and procedures to control the keys and IVs 
   *                  on PK_ENCRYPT and PK_DECRYPT packages. This package should have a 
   *                  very restricted access from database users.
   */
   /*========================================================================*/
   const_encryption_nls_charset CONSTANT VARCHAR2(8) := 'AL32UTF8';
   /*========================================================================*/
   /**
   * Return the password valid in references date
   *
   * @param     p_ref_date     The reference date used to return the active password in that date
   * @return                   The key active into the system in P_REF_DATE
   */
   FUNCTION get_pass (
      p_ref_date   IN secret_key.start_date%TYPE DEFAULT SYSDATE
   ) RETURN secret_key.raw_key%TYPE;
   /*========================================================================*/
   /**
   * Creates a new key starting to be active from sysdate
   * Assumes that always will exist one, and only one, 
   * active key (end_date = null) on the table
   * A new Key always will be active at least for 1s, 
   * so consecutive calls on this function will create keys 
   * with an interval of 1s between then.
   * 
   * WARNING: this function performs a commit
   */
   PROCEDURE generate_new_key;
   /*========================================================================*/
   /**
   * Store the IV into the database and return de ID created for it
   *
   * @param    p_iv_raw       The IV to be stored
   * @return                  The ID created to retrieve the P_IV_RAW
   */
   FUNCTION store_iv (
      p_iv_raw   IN secret_iv.iv_raw%TYPE
   ) RETURN secret_iv.iv_id%TYPE;
   /*========================================================================*/
   /**
   * Return de IV from the database
   *
   * @param    p_iv_id The    ID of IV to be returned
   * @return                  The respective IV stored into the database
   */
   FUNCTION get_iv (
      p_iv_id   IN secret_iv.iv_id%TYPE
   ) RETURN secret_iv.iv_raw%TYPE;
   /*========================================================================*/
END pk_secret_pass;