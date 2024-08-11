@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for PAX'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true

//@UI.chart: [{ 
//qualifier: 'NvsExpand',
//dimensions: [ 'IdNum' ],
//dimensionAttributes: [{ dimension: 'IdNum',role: #CATEGORY }],
//measures: [ 'IndExp' ],
//measureAttributes: [{ measure: 'IndExp', role: #AXIS_1 }] }]
define view entity Y27D_C_TRIP_PAX
  as projection on Y27D_I_TRIP_PAX
{
  key Batchid,
  key Counter,
      Firstname,
      IdType,
      IdNum,
      IndExp,
      @Semantics.currencyCode: true
      Currency,
      /* Associations */
      _planDet : redirected to parent Y27D_C_TRIP_PLAN,
      _planDoc : redirected to composition child Y27D_C_TRIP_DOCX
}
