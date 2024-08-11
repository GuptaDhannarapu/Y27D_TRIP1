CLASS lhc_Y27D_I_TRIP_ATTACH DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR y27d_i_trip_attach RESULT result.

ENDCLASS.

CLASS lhc_Y27D_I_TRIP_ATTACH IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.
