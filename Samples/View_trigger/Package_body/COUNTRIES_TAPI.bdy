create or replace PACKAGE BODY countries_tapi IS
/* insert*/
   PROCEDURE ins (
      p_region_id      IN countries.region_id%TYPE DEFAULT NULL,
      p_country_id     IN countries.country_id%TYPE,
      p_country_name   IN countries.country_name%TYPE DEFAULT NULL
   )
      IS
   BEGIN
      INSERT   INTO countries (
         region_id,
         country_id,
         country_name
      ) VALUES (
         p_region_id,
         p_country_id,
         p_country_name
      );
   END;
/* update*/
   PROCEDURE upd (
      p_region_id      IN countries.region_id%TYPE DEFAULT NULL,
      p_country_id     IN countries.country_id%TYPE,
      p_country_name   IN countries.country_name%TYPE DEFAULT NULL
   )
      IS
   BEGIN
      UPDATE countries
         SET region_id = p_region_id,
             country_name = p_country_name
       WHERE country_id = p_country_id;
   END;
/* del*/
   PROCEDURE del (
      p_country_id   IN countries.country_id%TYPE
   )
      IS
   BEGIN
      DELETE   FROM countries
       WHERE country_id = p_country_id;
   END;
   /*get regiuon ID*/
   FUNCTION get_region_id (
      p_country_id   IN countries.country_id%TYPE
   ) RETURN countries.region_id%TYPE IS
      v_region_id   countries.region_id%TYPE;
   BEGIN
      SELECT region_id
        INTO v_region_id
        FROM countries
       WHERE country_id = p_country_id;
      RETURN v_region_id;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN NULL;
   END;

END countries_tapi;