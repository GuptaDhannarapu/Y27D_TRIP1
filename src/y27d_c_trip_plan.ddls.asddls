@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Trip Details Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity Y27D_C_TRIP_PLAN
  provider contract transactional_query //"provider contract transactional_query
  as projection on Y27D_I_TRIP_PLAN
{
          @Search.defaultSearchElement: true
  key     Batch_Id,
          Place,
          From_date,
          To_date,
          Expend,
          @Semantics.currencyCode: true
          Currency,
          Total_per,
          Status,
          Created_by,
          Comments,
          Status_msg,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:Y27D_CL_CALCULATE'
          @EndUserText.label: 'Total Pax'
  virtual TotalPax1 : abap.numc(3),
          _paxDet : redirected to composition child Y27D_C_TRIP_PAX,
          _plaAct : redirected to composition child Y27D_C_TRIP_ACT
}
