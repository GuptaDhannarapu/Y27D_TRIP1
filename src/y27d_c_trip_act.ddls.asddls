@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View for Activities'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity Y27D_C_TRIP_ACT as projection on Y27D_I_TRIP_ACT
{
    key Batchid,
    key Counter,
    Place,
    Activity,
    Expend,
    @Semantics.currencyCode: true
    Currency,
    /* Associations */
    _planDet: redirected to parent Y27D_C_TRIP_PLAN
}
