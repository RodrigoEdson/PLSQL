create or replace PACKAGE BODY regions_tapi IS
/* insert*/
   FUNCTION ins (
      p_region_name   IN regions.region_name%TYPE DEFAULT NULL
   ) RETURN regions.region_id%TYPE IS
      v_id   regions.region_id%TYPE;
   BEGIN
      v_id := region_seq.nextval;

      INSERT   INTO regions (
         region_id,
         region_name
      ) VALUES (
         v_id,
         p_region_name
      );

      RETURN v_id;
   END;
/* update*/
   PROCEDURE upd (
      p_region_id     IN regions.region_id%TYPE,
      p_region_name   IN regions.region_name%TYPE DEFAULT NULL
   )
      IS
   BEGIN
      UPDATE regions
         SET
         region_name = p_region_name
       WHERE region_id = p_region_id;
   END;
/* del*/
   PROCEDURE del (
      p_region_id   IN regions.region_id%TYPE
   )
      IS
   BEGIN
      DELETE   FROM regions
       WHERE region_id = p_region_id;
   END;
/* get ID*/
   FUNCTION get_region_id (
      p_region_name   IN regions.region_name%TYPE
   ) RETURN regions.region_id%TYPE IS
      v_id   regions.region_id%TYPE;
   BEGIN

      SELECT r.region_id
        INTO v_id
        FROM regions r
       WHERE upper(
         r.region_name
      ) = upper(p_region_name);

      RETURN v_id;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN NULL;
   END;

   FUNCTION get_countries_number (
      p_region_id   IN regions.region_id%TYPE
   ) RETURN st_countries_number IS
      v_countries_number   st_countries_number;
   BEGIN
      SELECT COUNT(*)
        INTO v_countries_number
        FROM countries
       WHERE region_id = p_region_id;

      RETURN v_countries_number;
   END;
END regions_tapi;