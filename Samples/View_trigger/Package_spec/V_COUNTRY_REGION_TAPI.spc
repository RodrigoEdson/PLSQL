create or replace PACKAGE v_country_region_tapi AUTHID definer IS

   TYPE v_country_region_tapi_rec IS RECORD ( country_id v_country_region.country_id%TYPE,
   countries_region_number v_country_region.countries_region_number%TYPE,
   region_name v_country_region.region_name%TYPE,
   country_name v_country_region.country_name%TYPE );

   TYPE v_country_region_tapi_tab IS
      TABLE OF v_country_region_tapi_rec;
/* insert*/
   PROCEDURE ins (
      p_country_id                IN v_country_region.country_id%TYPE,
      p_countries_region_number   IN v_country_region.countries_region_number%TYPE DEFAULT NULL,
      p_region_name               IN v_country_region.region_name%TYPE DEFAULT NULL,
      p_country_name              IN v_country_region.country_name%TYPE DEFAULT NULL
   );
/* update*/
   PROCEDURE upd (
      p_country_id                IN v_country_region.country_id%TYPE,
      p_countries_region_number   IN v_country_region.countries_region_number%TYPE DEFAULT NULL,
      p_region_name               IN v_country_region.region_name%TYPE DEFAULT NULL,
      p_country_name              IN v_country_region.country_name%TYPE DEFAULT NULL
   );
/* delete*/
   PROCEDURE del (
      p_country_id   IN v_country_region.country_id%TYPE
   );
END v_country_region_tapi;