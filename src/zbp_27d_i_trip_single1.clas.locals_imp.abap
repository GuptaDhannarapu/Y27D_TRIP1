CLASS lhc_Y27D_I_TRIP_SINGLE1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR y27d_i_trip_single1 RESULT result.
*    METHODS earlynumbering_cba_tripplan FOR NUMBERING
*      IMPORTING entities FOR CREATE y27d_i_trip_single1\_tripplan.

ENDCLASS.

CLASS lhc_Y27D_I_TRIP_SINGLE1 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.



*  METHOD earlynumbering_cba_Tripplan.
*     DATA(lt_entities) = entities.
*      SELECT FROM y27d_t_plan_det FIELDS MAX( batchid ) INTO @DATA(lv_fin_vbeln).
*    LOOP AT lt_entities INTO DATA(ls_entity).
*      APPEND VALUE #( %cid = ls_entity-%cid_ref
*                      %is_draft = ls_entity-%is_draft
*                       batchid = lv_fin_vbeln + 1 ) TO mapped-y27d_i_trip_tmg_1.
*    ENDLOOP.
*  ENDMETHOD.

ENDCLASS.

CLASS lsc_Y27D_I_TRIP_SINGLE1 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Y27D_I_TRIP_SINGLE1 IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
