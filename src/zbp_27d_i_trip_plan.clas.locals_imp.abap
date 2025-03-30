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
    METHODS expend FOR DETERMINE ON MODIFY
      IMPORTING keys FOR paxdet~expend.

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

  METHOD expend.
    DATA: lt_count_upd TYPE STANDARD TABLE OF y27d_t_pax_det.
    READ ENTITIES OF y27d_i_trip_plan IN LOCAL MODE
         ENTITY paxDet
         FIELDS ( IndExp ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_total_pax).
    IF lt_total_pax IS NOT INITIAL.
      DATA(lv_batch) = lt_total_pax[ 1 ]-%tky.
      DATA(lv_batchid) = |{ lt_total_pax[ 1 ]-Batchid ALPHA = OUT }|.
*      ls_pax-Batchid = |{ ls_pax-Batchid ALPHA = IN }|.
      SELECT FROM y27d_t_pax_det FIELDS batchid, counter, ind_exp WHERE batchid EQ @lv_batchid INTO TABLE @DATA(lt_count).
      IF sy-subrc EQ 0.
        lt_count_upd = VALUE #( FOR ls_count IN lt_count
                                      FOR ls_total_pax IN lt_total_pax
                                      WHERE ( Batchid = ls_count-batchid AND
                                              Counter = ls_count-counter  )
                                              ( batchid = ls_total_pax-batchid
                                                counter = ls_total_pax-counter
                                                ind_exp = ls_total_pax-IndExp  ) ).
        lt_count_upd = VALUE #( BASE lt_count_upd FOR ls_total IN lt_total_pax
                                                  FOR ls_count1 IN lt_count
                                                    WHERE ( batchid NE ls_total-Batchid AND
                                                            counter NE ls_total-Counter )
                                                   ( batchid = ls_count1-batchid
                                                    counter = ls_count1-counter
                                                    ind_exp = ls_count1-ind_exp  ) ).
      ENDIF.
        MODIFY ENTITIES OF y27d_i_trip_plan IN LOCAL MODE
         ENTITY plan_details
         UPDATE
         FIELDS ( Expend ) WITH VALUE #( ( %tky = lv_batch
                                              Batch_Id = lt_total_pax[ 1 ]-Batchid
                                              Expend = REDUCE #( INIT lv_tot TYPE y27d_t_plan_det-expend
                                              FOR ls_data IN lt_count_upd
                                              WHERE ( batchid = lv_batchid )
                                              NEXT lv_tot = lv_tot + ls_data-ind_exp ) ) ).
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
            ENDIF.

          ENDIF.

          IF delete-pladoc IS NOT INITIAL.
            DATA: lr_attach  TYPE RANGE OF y27d_t_pax_docx-attch_id.
            CLEAR: lr_batchid, lr_counter, lr_counter.
            lr_batchid = VALUE #( BASE lr_batchid FOR ls_batchid_doc IN delete-pladoc
                                 ( sign = 'I' option ='EQ' low = ls_batchid_doc-Batchid )  ).
            lr_counter = VALUE #( BASE lr_counter FOR ls_batchid_doc IN delete-pladoc
                                 ( sign = 'I' option ='EQ' low = ls_batchid_doc-Counter )  ).
            lr_attach = VALUE #( BASE lr_attach FOR ls_batchid_doc IN delete-pladoc
                                 ( sign = 'I' option ='EQ' low = ls_batchid_doc-AttchId )  ).

            DELETE FROM y27d_t_pax_docx WHERE batchid IN @lr_batchid AND
                                              counter IN @lr_counter AND
                                              attch_id IN @lr_attach.
          ENDIF.

          IF update-plan_details IS NOT INITIAL.
            lv_fin_vbeln = VALUE #( update-plan_details[ 1 ]-Batch_Id OPTIONAL ).
            SELECT * FROM y27d_t_plan_det WHERE batchid EQ @lv_fin_vbeln INTO TABLE @DATA(lt_plan_all) .
              IF sy-subrc EQ 0.
                DATA: lv_flag_control   TYPE i VALUE 2,
                      lr_structure_desc TYPE REF TO cl_abap_structdescr,
                      lt_structure_desc TYPE  abap_component_tab,
                      l_component       TYPE LINE OF abap_component_tab,
                      lt_control        TYPE y27d_zif_structure=>tt_plan_control,
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
                  DATA(ls_control) = CORRESPONDING y27d_zif_structure=>ts_plan_control(
                                                                <fs_update_det>-%control
                                                                MAPPING currency = Currency
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
                        READ TABLE lt_structure_desc INTO l_component INDEX lv_flag_control.

                        ASSIGN COMPONENT l_component-name OF STRUCTURE <fs_plan_all> TO FIELD-SYMBOL(<fs_db_data>).
                        ASSIGN COMPONENT l_component-name OF STRUCTURE <fs_plan_new> TO FIELD-SYMBOL(<fs_updated>).

                        <fs_db_data> = <fs_updated>.

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

            ENDIF.

            IF update-paxdet IS NOT INITIAL.
              DATA: lt_pax_det_upd   TYPE STANDARD TABLE OF y27d_t_pax_det,
                    lt_pax_det       TYPE STANDARD TABLE OF y27d_t_pax_det,
                    lt_pax_det_upd_x TYPE  y27d_zif_structure=>tt_pax_control.

              lt_pax_det_upd = CORRESPONDING #( update-paxdet MAPPING batchid = Batchid
                                                                      counter = Counter
                                                                      currency = Currency
                                                                      id_num = IdNum
                                                                      id_type = IdType
                                                                      firstname = Firstname
                                                                      ind_exp = IndExp ).
              lt_pax_det_upd_x = VALUE #( FOR ls_pax_det_upd_x IN update-paxdet
                                       LET ls_pax_upd_x = VALUE y27d_zif_structure=>ts_pax_control(
                                                                 batchid = ls_pax_det_upd_x-Batchid
                                                                 counter = ls_pax_det_upd_x-Counter  )
                                       IN (  CORRESPONDING #( BASE ( ls_pax_upd_x )  ls_pax_det_upd_x-%control MAPPING
                                                                 currency = Currency
                                                                 firstname = Firstname
                                                                 id_num = IdNum
                                                                 id_type = IdType
                                                                 ind_exp = IndExp EXCEPT batchid counter  ) ) ).

              CHECK lt_pax_det_upd IS NOT INITIAL.
              SELECT * FROM y27d_t_pax_det
              FOR ALL ENTRIES IN @lt_pax_det_upd WHERE batchid EQ @lt_pax_det_upd-batchid AND
                                                      counter EQ @lt_pax_det_upd-counter
              INTO TABLE @DATA(lt_pax_det_old).
                IF sy-subrc EQ 0.
                  lt_pax_det = VALUE #(
                                  FOR x = 1 WHILE x <= lines( lt_pax_det_upd )
                                  LET ls_control_pax = VALUE #( lt_pax_det_upd_x[ x ] OPTIONAL )
                                      ls_pax_det = VALUE #( lt_pax_det_upd[ x ] OPTIONAL )
                                      ls_pax_det_old = VALUE #( lt_pax_det_old[ batchid = ls_pax_det-batchid
                                                                               counter = ls_pax_det-counter ] OPTIONAL )
                                  IN
                                  (
                                     batchid = ls_pax_det-batchid
                                     counter = ls_pax_det-counter
                                     firstname = COND #( WHEN ls_control_pax-firstname IS NOT INITIAL
                                                         THEN ls_pax_det-firstname
                                                         ELSE ls_pax_det_old-firstname )
                                     id_num = COND #( WHEN ls_control_pax-id_num IS NOT INITIAL
                                                         THEN ls_pax_det-id_num
                                                         ELSE ls_pax_det_old-id_num )
                                     id_type = COND #( WHEN ls_control_pax-id_type IS NOT INITIAL
                                                         THEN ls_pax_det-id_type
                                                         ELSE ls_pax_det_old-id_type )
                                     currency = COND #( WHEN ls_control_pax-currency IS NOT INITIAL
                                                         THEN ls_pax_det-currency
                                                         ELSE ls_pax_det_old-currency )
                                     ind_exp = COND #( WHEN ls_control_pax-ind_exp IS NOT INITIAL
                                                         THEN ls_pax_det-ind_exp
                                                         ELSE ls_pax_det_old-ind_exp )
                                   )

                                 ).
                  IF lt_pax_det IS NOT INITIAL.
                    UPDATE y27d_t_pax_det FROM TABLE @( VALUE #( FOR ls_s_pax IN lt_pax_det
                       LET ls_final_pax = VALUE y27d_t_pax_det( batchid = ls_s_pax-batchid
                                                                counter = ls_s_pax-counter )
                       IN (  CORRESPONDING #( BASE ( ls_final_pax ) ls_s_pax ) ) ) ).
                  ENDIF.
                ENDIF.

              ENDIF.

              IF update-pladoc IS NOT INITIAL.

                DATA: lt_pax_doc_upd   TYPE STANDARD TABLE OF y27d_t_pax_docx,
                      lt_pax_doc       TYPE STANDARD TABLE OF y27d_t_pax_docx,
                      lt_pax_doc_upd_x TYPE  y27d_zif_structure=>tt_pax_docx_control.

                lt_pax_doc_upd = CORRESPONDING #( update-pladoc MAPPING batchid = Batchid
                                                                  counter = Counter
                                                                  attch_id = AttchId
                                                                  document = Document
                                                                  mimetype = Mimetype
                                                                  comments = Comments
                                                                  filename = Filename ).
                lt_pax_doc_upd_x = VALUE #( FOR ls_pax_doc_upd IN update-pladoc
                                         LET ls_pax_docx_upd_x = VALUE y27d_zif_structure=>ts_pax_docx(
                                                                   batchid = ls_pax_doc_upd-Batchid
                                                                   counter = ls_pax_doc_upd-Counter
                                                                   attch_id = ls_pax_doc_upd-AttchId  )
                                         IN (  CORRESPONDING #( BASE ( ls_pax_docx_upd_x )  ls_pax_doc_upd-%control MAPPING
                                                                  document = Document
                                                                  mimetype = Mimetype
                                                                  comments = Comments
                                                                  filename = Filename EXCEPT batchid counter attch_id  ) ) ).
                CHECK lt_pax_doc_upd IS NOT INITIAL.
                SELECT * FROM y27d_t_pax_docx
                FOR ALL ENTRIES IN @lt_pax_doc_upd WHERE batchid EQ @lt_pax_doc_upd-batchid AND
                                                         counter EQ @lt_pax_doc_upd-counter AND
                                                         attch_id EQ @lt_pax_doc_upd-attch_id
                INTO TABLE @DATA(lt_pax_doc_old).
                  IF sy-subrc EQ 0.
                    lt_pax_doc = VALUE #(
                                   FOR x = 1 WHILE x <= lines( lt_pax_doc_upd )
                                   LET ls_control_doc = VALUE #( lt_pax_doc_upd_x[ x ] OPTIONAL )
                                       ls_pax_doc = VALUE #( lt_pax_doc_upd[ x ] OPTIONAL )
                                       ls_pax_doc_old = VALUE #( lt_pax_doc_old[ batchid = ls_pax_doc-batchid
                                                                                 counter = ls_pax_doc-counter
                                                                                 attch_id = ls_pax_doc-attch_id ] OPTIONAL )
                                   IN
                                   (
                                      batchid = ls_pax_doc-batchid
                                      counter = ls_pax_doc-counter
                                      attch_id = ls_pax_doc-attch_id
                                      document = COND #( WHEN ls_control_doc-document IS NOT INITIAL
                                                          THEN ls_pax_doc-document
                                                          ELSE ls_pax_doc_old-document )
                                      mimetype = COND #( WHEN ls_control_doc-mimetype IS NOT INITIAL
                                                          THEN ls_pax_doc-mimetype
                                                          ELSE ls_pax_doc_old-mimetype )
                                      comments = COND #( WHEN ls_control_doc-comments IS NOT INITIAL
                                                          THEN ls_pax_doc-comments
                                                          ELSE ls_pax_doc_old-comments )
                                      filename = COND #( WHEN ls_control_doc-filename IS NOT INITIAL
                                                          THEN ls_pax_doc-filename
                                                          ELSE ls_pax_doc_old-filename ) ) ).
                    IF lt_pax_doc IS NOT INITIAL.
                      UPDATE y27d_t_pax_docx FROM TABLE @( VALUE #( FOR ls_s_doc IN lt_pax_doc
                         LET ls_final_doc = VALUE y27d_t_pax_docx( batchid = ls_s_doc-batchid
                                                                  counter = ls_s_doc-counter
                                                                  attch_id = ls_s_doc-attch_id )
                         IN (  CORRESPONDING #( BASE ( ls_final_doc ) ls_s_doc ) ) ) ).
                    ENDIF.
                  ENDIF.

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

                           %action-YetToConfirm = COND #( WHEN <fs_so_head>-status = '*'
                                                          THEN if_abap_behv=>fc-o-enabled
                                                          WHEN <fs_so_head>-status = 'X'
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
