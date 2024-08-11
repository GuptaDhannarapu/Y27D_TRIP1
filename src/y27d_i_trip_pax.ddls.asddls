@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface for Trip Persons'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@UI.chart: [{
qualifier: 'PrjVsTs',
chartType: #COLUMN,
dimensions: [ 'IdNum' ],
dimensionAttributes: [{ dimension: 'IdNum', role: #CATEGORY }],
measures: [ 'IndExp' ],
measureAttributes: [{ measure: 'IndExp',role: #AXIS_1 }] }]
define view entity Y27D_I_TRIP_PAX
  as select from y27d_t_pax_det
  association to parent Y27D_I_TRIP_PLAN as _planDet on $projection.Batchid = _planDet.Batch_Id
  composition [0..*] of Y27D_I_TRIP_DOCX as _planDoc
  association[0..1] to ZCDS_VALUE_DROP as _currencyValueHelp
   on $projection.Currency = _currencyValueHelp.Currency
  
{
  key batchid  as Batchid,
  key counter  as Counter,
      firstname as Firstname,
      id_type  as IdType,
      id_num   as IdNum,
      @Semantics.amount.currencyCode: 'Currency'
      ind_exp  as IndExp,
      currency as Currency,
      _planDet,
      _planDoc,
      _currencyValueHelp
}
