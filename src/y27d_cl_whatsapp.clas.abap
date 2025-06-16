CLASS y27d_cl_whatsapp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Y27D_CL_WHATSAPP IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA: lt_virtual_ele TYPE STANDARD TABLE OF y27d_c_trip_plan WITH DEFAULT KEY.

    lt_virtual_ele = CORRESPONDING #( it_original_data ).
    lt_virtual_ele[ 1 ]-WhatsApp = 'https://wa.me/918754422319'.
    ct_calculated_data = CORRESPONDING #( lt_virtual_ele ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.
ENDCLASS.
