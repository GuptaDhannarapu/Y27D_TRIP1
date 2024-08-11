@EndUserText.label: 'Consumption View of Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity Y27D_C_TRIP_SINGLE1
  provider contract transactional_query as projection on Y27D_I_TRIP_SINGLE1
{
    key SingletonID,
    LastChangedAt,
    /* Associations */
    _TripPlan: redirected to composition child Y27D_C_TRIP_TMG_1
}
