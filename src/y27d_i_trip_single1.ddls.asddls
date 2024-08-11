@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'TMG Singleton interface'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity Y27D_I_TRIP_SINGLE1 as select from I_Language
left outer join y27d_t_plan_det as Trip on 0 = 0
composition [0..*] of Y27D_I_TRIP_TMG_1 as _TripPlan
//composition [0..*] of Y27D_I_TRIP_DOCX as _TripAttach
{
    key 1 as SingletonID,
    _TripPlan,
//    _TripAttach,
    max( Trip.last_changed_at ) as LastChangedAt
}
