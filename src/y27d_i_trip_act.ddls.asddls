@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface for Trip Persons'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Y27D_I_TRIP_ACT as select from y27d_t_pla_act
association to parent Y27D_I_TRIP_PLAN as _planDet on $projection.Batchid = _planDet.Batch_Id
{
    key batchid as Batchid,
    key counter as Counter,
    place as Place,
    activity as Activity,
    @Semantics.amount.currencyCode: 'Currency'
    expend as Expend,
    currency as Currency,
    _planDet
}
