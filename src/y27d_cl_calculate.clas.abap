CLASS y27d_cl_calculate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS y27d_cl_calculate IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA: lt_virtual_ele TYPE STANDARD TABLE OF y27d_c_trip_plan WITH DEFAULT KEY.

    lt_virtual_ele = CORRESPONDING #( it_original_data ).
    CHECK lt_virtual_ele IS NOT INITIAL.
    SELECT FROM y27d_t_pax_det FIELDS Batchid, counter FOR ALL ENTRIES IN
    @lt_virtual_ele WHERE Batchid EQ @lt_virtual_ele-Batch_Id INTO
    TABLE @DATA(lt_data1).

    LOOP AT lt_virtual_ele ASSIGNING FIELD-SYMBOL(<lfs_virtual_el>).
      <lfs_virtual_el>-TotalPax1 = REDUCE y27d_c_trip_plan-TotalPax1( INIT lv_tp TYPE y27d_c_trip_plan-TotalPax1
                                            FOR ls_data IN lt_data1
                                             WHERE ( batchid = <lfs_virtual_el>-Batch_Id )
                                             NEXT lv_tp = lv_tp + 1  ).
    ENDLOOP.
    ct_calculated_data = CORRESPONDING #( lt_virtual_ele ).
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.

ENDCLASS.
