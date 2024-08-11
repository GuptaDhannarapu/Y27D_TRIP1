CLASS lhc_pladoc DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR plaDoc RESULT result.

ENDCLASS.

CLASS lhc_pladoc IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_plaact DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR plaAct RESULT result.
    METHODS determinetotalexp FOR DETERMINE ON SAVE
      IMPORTING keys FOR plaact~determinetotalexp.
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR plaAct RESULT result.

*    METHODS yettoconfirm FOR MODIFY
*      IMPORTING keys FOR ACTION plaact~yettoconfirm RESULT result.

ENDCLASS.

CLASS lhc_plaact IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

*  METHOD get_instance_authorizations.
*  ENDMETHOD.
*
*  METHOD YetToConfirm.
*
*
*  ENDMETHOD.

  METHOD determineTotalExp.
    READ ENTITIES OF y27d_i_trip_plan IN LOCAL MODE
        ENTITY plaAct
        FIELDS ( Expend ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_total).
    READ ENTITY y27d_i_trip_plan BY \_paxDet  ALL FIELDS
     WITH VALUE #( ( %key-Batch_Id = lt_total[ 1 ]-Batchid  ) )
     RESULT DATA(lt_pax).

    IF lt_total IS NOT INITIAL.
      DATA(lv_total) = lines( lt_pax ).
      DATA(lv_cal) = lt_total[ 1 ]-Expend.
      IF lv_total GT 0.
        DATA(lv_amount) = ( lv_cal / lv_total ).
      ENDIF.
*     MODIFY ENTITIES OF y27d_i_trip_plan IN LOCAL MODE
*     ENTITY paxDet UPDATE FIELDS ( IndExp  )
*     WITH VALUE #( FOR key IN keys ( %tky = key-%tky IndExp = lv_amount  ) ).
*
      LOOP AT lt_pax INTO DATA(ls_pax).
        ls_pax-Batchid = |{ ls_pax-Batchid ALPHA = IN }|.
        MODIFY ENTITIES OF y27d_i_trip_plan IN LOCAL MODE ENTITY
        paxDet
        UPDATE  FIELDS ( IndExp ) WITH VALUE #( (  %tky = CORRESPONDING #( ls_pax-%tky EXCEPT Counter )
                                                   %is_draft = ls_pax-%is_draft
                                                   Batchid = ls_pax-Batchid
                                                   Counter = ls_pax-Counter
                          IndExp = lv_amount ) ).
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc__plandet DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR paxDet RESULT result.
    METHODS determinetotalpax FOR DETERMINE ON MODIFY
      IMPORTING keys FOR paxdet~determinetotalpax.

*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR paxDet RESULT result.

ENDCLASS.

CLASS lhc__plandet IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

*  METHOD get_instance_authorizations.
*  ENDMETHOD.

  METHOD determineTotalPax.

    READ ENTITIES OF y27d_i_trip_plan IN LOCAL MODE
       ENTITY paxDet
       FIELDS ( Counter ) WITH CORRESPONDING #( keys )
       RESULT DATA(lt_total).
    IF lt_total IS NOT INITIAL.
      DATA(lv_batch) = lt_total[ 1 ]-%tky.
      DATA(lv_batchid) = |{ lt_total[ 1 ]-Batchid ALPHA = OUT }|.
*      ls_pax-Batchid = |{ ls_pax-Batchid ALPHA = IN }|.
      SELECT FROM y27d_t_pax_det FIELDS counter WHERE batchid EQ @lv_batchid INTO TABLE @DATA(lt_count).
      DATA(lv_totpax) = lines( lt_count ).
      MODIFY ENTITIES OF y27d_i_trip_plan IN LOCAL MODE
   ENTITY plan_details
   UPDATE
   FIELDS ( Total_per ) WITH VALUE #( ( %tky = lv_batch
                                        Batch_Id = lt_total[ 1 ]-Batchid
                                        Total_per = lv_totpax + 1 ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_y27d_i_trip_plan DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_y27d_i_trip_plan IMPLEMENTATION.

  METHOD save_modified.
    DATA ls_so_head TYPE y27d_t_plan_det.
    DATA lt_so_head TYPE STANDARD TABLE OF y27d_t_plan_det.
    SELECT FROM y27d_t_plan_det FIELDS MAX( batchid ) INTO @DATA(lv_fin_vbeln).
*    GET TIME STAMP FIELD FINAL(lv_time_stamp).
    IF create-plan_details IS NOT INITIAL.
      MODIFY y27d_t_plan_det FROM TABLE @( VALUE #( FOR ls_so IN create-plan_details
                            LET ls_final = VALUE y27d_t_plan_det( status = '*'  )
                            IN (  CORRESPONDING #( BASE ( ls_final ) ls_so MAPPING
                                                         batchid = Batch_Id
                                                         place = Place
                                                         frdate = From_date
                                                         todate = To_date
                                                         expend = Expend
                                                         currency = Currency
                                                         totalpax = Total_per
*                   N                                         status = Status
                                                     EXCEPT status ) ) ) ).
    ENDIF.
    IF create-paxdet IS NOT INITIAL.
      lv_fin_vbeln = VALUE #( create-paxdet[ 1 ]-Batchid OPTIONAL ) .
      SELECT FROM y27d_t_pax_det FIELDS MAX( counter ) WHERE batchid EQ @lv_fin_vbeln INTO @DATA(lv_counter).
*      lv_counter = VALUE #( create-paxdet[ 1 ]-Counter OPTIONAL ).
      lv_counter += 1.
      MODIFY y27d_t_pax_det FROM TABLE @( VALUE #( FOR ls_pax IN create-paxdet
                           LET ls_final_pax = VALUE y27d_t_pax_det( batchid = lv_fin_vbeln
                                                                counter = lv_counter )
                           IN ( CORRESPONDING #( BASE ( ls_final_pax ) ls_pax MAPPING
                                                                id_num = IdNum
                                                                id_type = IdType
                                                                currency = Currency
                                                                ind_exp = IndExp EXCEPT batchid counter ) ) ) ).
    ENDIF.
    IF create-plaact IS NOT INITIAL.
      lv_fin_vbeln = VALUE #( create-plaact[ 1 ]-Batchid OPTIONAL ).
      MODIFY y27d_t_pla_act FROM TABLE @( VALUE #( FOR ls_act IN create-plaact
                           LET ls_final_act = VALUE y27d_t_pla_act( batchid = lv_fin_vbeln )
                           IN ( CORRESPONDING #( BASE ( ls_final_act ) ls_act ) ) ) ).
    ENDIF.
    IF create-pladoc IS NOT INITIAL.
      DATA: lv_counter_at TYPE y27d_t_pax_docx-counter.
      lv_fin_vbeln = VALUE #( create-pladoc[ 1 ]-Batchid OPTIONAL ).
      lv_counter_at = VALUE #( create-pladoc[ 1 ]-Counter OPTIONAL ).
      IF lv_counter_at IS INITIAL.
        lv_counter_at = lv_counter.
      ENDIF.
      SELECT FROM y27d_t_pax_docx FIELDS MAX( attch_id ) WHERE batchid EQ @lv_fin_vbeln AND
                                                               counter EQ @lv_counter_at
                                                         INTO @DATA(lv_attach_id).
      MODIFY y27d_t_pax_docx FROM TABLE @( VALUE #( FOR ls_docx IN create-pladoc
                           LET ls_final_docx = VALUE y27d_t_pax_docx( batchid = lv_fin_vbeln
                                                                      counter = lv_counter_at
                                                                      attch_id = lv_attach_id + 1  )
                           IN ( CORRESPONDING #( BASE ( ls_final_docx ) ls_docx EXCEPT batchid counter attch_id ) ) ) ).
    ENDIF.
    IF delete-plan_details IS NOT INITIAL.
      DATA: lr_batchid TYPE RANGE OF y27d_t_plan_det-batchid.
      lr_batchid = VALUE #( BASE lr_batchid FOR ls_batchid IN delete-plan_details
                           ( sign = 'I' option ='EQ' low = ls_batchid-Batch_Id )  ).

      DELETE FROM y27d_t_plan_det WHERE batchid IN @lr_batchid.

    ENDIF.

    IF delete-paxdet IS NOT INITIAL.
      DATA: lr_counter TYPE RANGE OF y27d_t_pax_det-counter.
      CLEAR: lr_batchid.
      lr_batchid = VALUE #( BASE lr_batchid FOR ls_batch IN delete-paxdet
                     ( sign = 'I' option = 'EQ' low = ls_batch-Batchid )  ).
      lr_counter = VALUE #( BASE lr_counter FOR ls_counter IN delete-paxdet
                           ( sign = 'I' option = 'EQ' low = ls_counter-Counter )  ).

      DELETE FROM y27d_t_pax_det WHERE batchid IN @lr_batchid AND
                                       counter IN @lr_counter.
      IF sy-subrc EQ 0.
        SELECT SINGLE FROM y27d_t_plan_det FIELDS totalpax WHERE batchid IN @lr_batchid INTO @DATA(lv_high).
        SORT lr_counter BY low.
        DELETE ADJACENT DUPLICATES FROM lr_counter COMPARING low.
        DATA(lv_count) = lines( lr_counter ).
        lv_count = lv_high - lv_count.
*        UPDATE y27d_t_plan_det SET totalpax = @lv_count WHERE batchid
*        MODIFY ENTITIES OF y27d_i_trip_plan IN LOCAL MODE
*         ENTITY plan_details UPDATE FIELDS ( Total_per  )
*         WITH VALUE #( FOR key IN delete-paxdet ( Batch_Id = key-Batchid Total_per = lv_count  ) ).
      ENDIF.

    ENDIF.
    IF update-plan_details IS NOT INITIAL.
      lv_fin_vbeln = VALUE #( update-plan_details[ 1 ]-Batch_Id OPTIONAL ).
      SELECT * FROM y27d_t_plan_det WHERE batchid EQ @lv_fin_vbeln INTO TABLE @DATA(lt_plan_all) .
      IF sy-subrc EQ 0.
        DATA: lv_flag_control   TYPE i VALUE 2,
              lr_structure_desc TYPE REF TO cl_abap_structdescr,
              lt_structure_desc TYPE  abap_component_tab,
              l_component       TYPE LINE OF abap_component_tab,
              lt_control        TYPE zif_structure=>tt_plan_control,
              lt_plan_updated   TYPE TABLE OF y27d_t_plan_det,
              lt_plan_new       TYPE TABLE OF y27d_t_plan_det,
              lv_new_timestamp  TYPE timestampl.
        LOOP AT update-plan_details ASSIGNING FIELD-SYMBOL(<fs_update_det>).
          DATA(ls_plan_new) = CORRESPONDING y27d_t_plan_det( <fs_update_det> MAPPING
                                                               frdate = From_date
                                                               todate = To_date
                                                               totalpax = Total_per
                                                               expend = Expend ).
          ls_plan_new-batchid = <fs_update_det>-Batch_Id.
          APPEND ls_plan_new TO lt_plan_new.
          DATA(ls_control) = CORRESPONDING zif_structure=>ts_plan_control(
                                                        <fs_update_det>-%control
                                                        MAPPING "batchid = Batch_Id
                                                                currency = Currency
                                                                expend = Expend
                                                                frdate = From_date
                                                                todate = To_date
                                                                place = Place
                                                                status = Status
                                                                totalpax = Total_per ).
          ls_control-batchid = <fs_update_det>-Batch_Id.
          APPEND ls_control TO lt_control.
        ENDLOOP.
        LOOP AT lt_plan_all ASSIGNING FIELD-SYMBOL(<fs_plan_all>).

          READ TABLE lt_plan_new ASSIGNING FIELD-SYMBOL(<fs_plan_new>) WITH KEY batchid = <fs_plan_all>-batchid.
          IF sy-subrc EQ 0.
            READ TABLE lt_control ASSIGNING FIELD-SYMBOL(<fs_so_control>) WITH KEY batchid = <fs_plan_all>-batchid.
            IF lt_structure_desc IS INITIAL.
              lr_structure_desc ?= cl_abap_typedescr=>describe_by_data( <fs_so_control> ).
              lt_structure_desc = lr_structure_desc->get_components( ).
            ENDIF.
            DO.

              ASSIGN COMPONENT lv_flag_control OF STRUCTURE <fs_so_control> TO FIELD-SYMBOL(<v_flag>).
              IF sy-subrc <> 0.
                EXIT.
              ENDIF.

              IF <v_flag> EQ '01' OR <v_flag> EQ '1'.

                "Col name? of the index
                READ TABLE lt_structure_desc INTO l_component INDEX lv_flag_control.

                ASSIGN COMPONENT l_component-name OF STRUCTURE <fs_plan_all> TO FIELD-SYMBOL(<fs_db_data>).
                ASSIGN COMPONENT l_component-name OF STRUCTURE <fs_plan_new> TO FIELD-SYMBOL(<fs_updated>).

                <fs_db_data> = <fs_updated>.
*                <fs_so_line>-last_changed_timestamp = lv_new_timestamp.

              ENDIF.
              lv_flag_control = lv_flag_control + 1.
            ENDDO.

          ENDIF.
          APPEND <fs_plan_all> TO lt_plan_updated.

        ENDLOOP.

      ENDIF.
      UPDATE y27d_t_plan_det FROM TABLE @( VALUE #( FOR ls_s_so IN lt_plan_updated
                            LET ls_final = VALUE y27d_t_plan_det( batchid = ls_s_so-batchid )
                            IN (  CORRESPONDING #( BASE ( ls_final ) ls_s_so ) ) ) ).
*                                                     "MAPPING
**                                                         place = Place
**                                                         frdate =
**                                                         todate = To_date
**                                                         expend = Expend
**                                                         currency = Currency
**                                                         totalpax = Total_per
**                                                         status = Status
**                                                     EXCEPT batchid
*                                                                                                        )
*                                                     ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Y27D_I_TRIP_PLAN DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR y27d_i_trip_plan RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR plan_details RESULT result.
    METHODS confirmed FOR MODIFY
      IMPORTING keys FOR ACTION plan_details~confirmed RESULT result.

    METHODS yettoconfirm FOR MODIFY
      IMPORTING keys FOR ACTION plan_details~yettoconfirm RESULT result.
    METHODS validate_to_date FOR VALIDATE ON SAVE
      IMPORTING keys FOR plan_details~validate_to_date.
*    METHODS earlynumbering_cba_paxdet FOR NUMBERING
*      IMPORTING entities FOR CREATE plan_details\_paxdet.
    METHODS earlynumbering_cba_plaact FOR NUMBERING
      IMPORTING entities FOR CREATE plan_details\_plaact.
*    METHODS earlynumbering_create FOR NUMBERING
*      IMPORTING entities FOR CREATE plan_details.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE plan_details.


ENDCLASS.

CLASS lhc_Y27D_I_TRIP_PLAN IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    DATA lt_result LIKE LINE OF result.

    SELECT * FROM y27d_t_plan_det
    FOR ALL ENTRIES IN @keys
    WHERE batchid = @keys-Batch_Id
    INTO TABLE @FINAL(lt_t_plan).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_t_plan ASSIGNING FIELD-SYMBOL(<fs_so_head>).
      lt_Result = VALUE #( Batch_Id        = <fs_so_head>-batchid

                           %update             = COND #( WHEN <fs_so_head>-status = ' '
                                                          THEN if_abap_behv=>fc-f-read_only
                                                          WHEN <fs_so_head>-status = 'X'
                                                          THEN if_abap_behv=>fc-f-read_only
                                                          ELSE if_abap_behv=>fc-f-unrestricted )
*
                           %delete              = COND #( WHEN <fs_so_head>-status = '*'
                                                          THEN if_abap_behv=>fc-f-read_only
                                                          WHEN <fs_so_head>-status = 'X'
                                                          THEN if_abap_behv=>fc-f-read_only
                                                          ELSE if_abap_behv=>fc-f-unrestricted )

                           %assoc-_paxDet      = COND #( WHEN <fs_so_head>-status = 'X'
                                                          THEN if_abap_behv=>fc-f-read_only
                                                          ELSE if_abap_behv=>fc-f-unrestricted )

                           %action-Confirmed   = COND #( WHEN <fs_so_head>-status = 'X'
                                                          THEN if_abap_behv=>fc-o-disabled
                                                         WHEN <fs_so_head>-status = '*'
                                                          THEN if_abap_behv=>fc-o-disabled
                                                          ELSE if_abap_behv=>fc-o-enabled )

                           %action-YetToConfirm = COND #( WHEN <fs_so_head>-status = 'X'
                                                          THEN if_abap_behv=>fc-o-enabled
                                                          WHEN <fs_so_head>-status = '*'
                                                          THEN if_abap_behv=>fc-o-enabled
                                                          ELSE if_abap_behv=>fc-o-disabled ) ).

      APPEND lt_result TO result.
    ENDLOOP.
  ENDMETHOD.



  METHOD Confirmed.
    MODIFY ENTITIES OF y27d_i_trip_plan IN LOCAL MODE
     ENTITY plan_details UPDATE FIELDS ( Status  )
     WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = abap_true  ) )

     FAILED failed
     REPORTED reported.

    READ ENTITIES OF y27d_i_trip_plan IN LOCAL MODE
    ENTITY plan_details
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(plandata).
    result = VALUE #( FOR ls_plan IN plandata ( %tky = ls_plan-%tky %param = ls_plan ) ).
  ENDMETHOD.

  METHOD YetToConfirm.
    MODIFY ENTITIES OF y27d_i_trip_plan IN LOCAL MODE
     ENTITY plan_details UPDATE FIELDS ( Status  )
     WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = abap_false  ) )

     FAILED failed
     REPORTED reported.

    READ ENTITIES OF y27d_i_trip_plan IN LOCAL MODE
    ENTITY plan_details
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(plandata).
    result = VALUE #( FOR ls_plan IN plandata ( %tky = ls_plan-%tky %param = ls_plan ) ).

  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lt_entities) = entities.
    SELECT FROM y27d_t_plan_det FIELDS MAX( batchid ) INTO @DATA(lv_fin_vbeln).
    LOOP AT lt_entities INTO DATA(ls_entity).
      APPEND VALUE #( %cid = ls_entity-%cid
                      %is_draft = ls_entity-%is_draft
                      batch_id = lv_fin_vbeln + 1 ) TO mapped-plan_details.
*      APPEND VALUE #( %cid = ls_entity-%cid
*                      %key = ls_entity-%key
*                      batch_id = lv_fin_vbeln + 1 ) TO failed-plan_details.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_to_date.

    READ ENTITIES OF y27d_i_trip_plan IN LOCAL MODE
    ENTITY plan_details
    FIELDS ( To_date  ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_plan).

    LOOP AT lt_plan INTO DATA(ls_plan).
      IF  ls_plan-From_date GE ls_plan-To_date.
        APPEND  VALUE #( %tky = ls_plan-%tky ) TO Failed-plan_details.
        APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = 'To Date Should be Greater than From Date' ) ) TO reported-plan_details.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Plaact.
    DATA(lt_entities) = entities.
    DATA(lt_target) = lt_entities[ 1 ]-%target.
    DATA(lv_fin_bat) = lt_entities[ 1 ]-Batch_Id.
    SELECT FROM y27d_t_pla_act FIELDS MAX( counter ) WHERE batchid EQ @lv_fin_bat INTO @DATA(lv_fin_counter).
    LOOP AT lt_entities INTO DATA(ls_entity_act).
      APPEND VALUE #( %cid = lt_target[ 1 ]-%cid
                      %is_draft = ls_entity_act-%is_draft
                      batchid = lv_fin_bat
                      counter = lv_fin_counter + 1 ) TO mapped-plaact.

    ENDLOOP.

  ENDMETHOD.

*  METHOD earlynumbering_cba_Paxdet.
*  DATA(lt_entities_pax) = entities.
*  ENDMETHOD.

ENDCLASS.
