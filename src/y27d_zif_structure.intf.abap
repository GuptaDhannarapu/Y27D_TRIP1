INTERFACE y27d_zif_structure
  PUBLIC .
  TYPES: BEGIN OF ts_plan_control,
*          client    TYPE abp_behv_flag,
           batchid  TYPE abp_behv_flag,
           place    TYPE abp_behv_flag,
           frdate   TYPE abp_behv_flag,
           todate   TYPE abp_behv_flag,
*          @Semantics.amount.currencyCode : 'y27d_t_plan_det.currency'
           expend   TYPE abp_behv_flag,
           currency TYPE abp_behv_flag,
           totalpax TYPE abp_behv_flag,
           status   TYPE abp_behv_flag,
         END OF ts_plan_control.
  TYPES: BEGIN OF ts_pax_control,
           batchid   TYPE zbatchid,
           counter   TYPE string,
           firstname TYPE abp_behv_flag,
           id_type   TYPE abp_behv_flag,
           id_num    TYPE abp_behv_flag,
*  @Semantics.amount.currencyCode : 'y27d_t_pax_det.currency'
           ind_exp   TYPE abp_behv_flag,
           currency  TYPE abp_behv_flag,
         END OF ts_pax_control.
  TYPES: BEGIN OF ts_pax_docx,
           batchid  TYPE zbatchid,
           counter  TYPE  string,
           attch_id TYPE char32,
           document TYPE abp_behv_flag,
           mimetype TYPE abp_behv_flag,
           filename TYPE abp_behv_flag,
           comments TYPE abp_behv_flag,
         END OF ts_pax_docx.
  TYPES: tt_plan_control TYPE TABLE OF ts_plan_control,
         tt_pax_control  TYPE TABLE OF ts_pax_control,
         tt_pax_docx_control TYPE TABLE OF ts_pax_docx.

ENDINTERFACE.
