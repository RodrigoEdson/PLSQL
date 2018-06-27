create or replace PACKAGE BODY v_country_region_tapi IS 
/* insert*/
   PROCEDURE ins (
      p_country_id                IN v_country_region.country_id%TYPE,
      p_countries_region_number   IN v_country_region.countries_region_number%TYPE DEFAULT NULL,
      p_region_name               IN v_country_region.region_name%TYPE DEFAULT NULL,
      p_country_name              IN v_country_region.country_name%TYPE DEFAULT NULL
   ) IS
      v_region_id   regions.region_id%TYPE;
   BEGIN

      v_region_id := regions_tapi.get_region_id(p_region_name);
      IF v_region_id IS NULL THEN
         v_region_id := regions_tapi.ins(p_region_name   => p_region_name);
      END IF;

      countries_tapi.ins(
         v_region_id,
         p_country_id,
         p_country_name
      );

   END;
/* update*/
   PROCEDURE upd (
      p_country_id                IN v_country_region.country_id%TYPE,
      p_countries_region_number   IN v_country_region.countries_region_number%TYPE DEFAULT NULL,
      p_region_name               IN v_country_region.region_name%TYPE DEFAULT NULL,
      p_country_name              IN v_country_region.country_name%TYPE DEFAULT NULL
   ) IS
      v_region_id   regions.region_id%TYPE;
   BEGIN

      v_region_id := regions_tapi.get_region_id(p_region_name);
      IF v_region_id IS NULL THEN
         v_region_id := regions_tapi.ins(p_region_name   => p_region_name);
      END IF;

      countries_tapi.upd(
         v_region_id,
         p_country_id,
         p_country_name
      );

   END;
/* del*/
   PROCEDURE del (
      p_country_id   IN v_country_region.country_id%TYPE
   ) IS
      v_region_id   regions.region_id%TYPE;
   BEGIN
      v_region_id := countries_tapi.get_region_id(p_country_id);

      countries_tapi.del(p_country_id);

      IF v_region_id IS NOT NULL THEN
         IF regions_tapi.get_countries_number(v_region_id) = 0 THEN
            regions_tapi.del(v_region_id);
         END IF;
      END IF;
   END;
END v_country_region_tapi;