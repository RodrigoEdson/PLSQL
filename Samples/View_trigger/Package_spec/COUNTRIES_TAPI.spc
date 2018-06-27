create or replace PACKAGE countries_tapi IS

   TYPE countries_tapi_rec IS RECORD ( region_id countries.region_id%TYPE,
   country_id countries.country_id%TYPE,
   country_name countries.country_name%TYPE );

   TYPE countries_tapi_tab IS
      TABLE OF countries_tapi_rec;
/* insert*/
   PROCEDURE ins (
      p_region_id      IN countries.region_id%TYPE DEFAULT NULL,
      p_country_id     IN countries.country_id%TYPE,
      p_country_name   IN countries.country_name%TYPE DEFAULT NULL
   );
/* update*/
   PROCEDURE upd (
      p_region_id      IN countries.region_id%TYPE DEFAULT NULL,
      p_country_id     IN countries.country_id%TYPE,
      p_country_name   IN countries.country_name%TYPE DEFAULT NULL
   );
/* delete*/
   PROCEDURE del (
      p_country_id   IN countries.country_id%TYPE
   );
   /*return the region ID of a country*/
   FUNCTION get_region_id (
      p_country_id   IN countries.country_id%TYPE
   ) RETURN countries.region_id%TYPE;

END countries_tapi;