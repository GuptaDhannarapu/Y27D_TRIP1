@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Table Maintenance interface'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Y27D_I_TRIP_TMG_1 as select from y27d_t_plan_det
association to parent Y27D_I_TRIP_SINGLE1 as _Singleton on $projection.SingletonID = _Singleton.SingletonID
{
    key batchid as Batchid,
    1 as SingletonID,
    place as Place,
    frdate as Frdate,
    todate as Todate,
    @Semantics.amount.currencyCode: 'Currency'
    expend as Expend,
    currency as Currency,
    totalpax as Totalpax,
    status as Status,
    local_created_by as LocalCreatedBy,
    last_changed_at as LastChangedAt,
    configdeprecationcode as Configdeprecationcode,
    _Singleton
}
